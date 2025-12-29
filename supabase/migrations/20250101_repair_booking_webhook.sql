-- Migration: 20250101_repair_booking_webhook.sql
-- Description: Restores webhook tables and RPC for handling Chargily payment callbacks.

BEGIN;

-- ============================================================================
-- 1. WEBHOOK TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS "public"."payment_events" (
    "id" bigserial PRIMARY KEY,
    "event_id" text UNIQUE NOT NULL,
    "event_type" text NOT NULL,
    "payload" jsonb NOT NULL,
    "status" text NOT NULL DEFAULT 'pending',
    "error_message" text,
    "processed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "idx_payment_events_event_id" ON "public"."payment_events" ("event_id");
CREATE INDEX IF NOT EXISTS "idx_payment_events_status" ON "public"."payment_events" ("status");

CREATE TABLE IF NOT EXISTS "public"."manual_resolution_queue" (
    "id" bigserial PRIMARY KEY,
    "payment_event_id" bigint,
    "reason" text NOT NULL,
    "payment_transaction_id" text NOT NULL,
    "amount_paid" numeric(10,2) NOT NULL,
    "customer_id" text,
    "metadata" jsonb,
    "resolved" boolean DEFAULT false,
    "resolved_at" timestamp with time zone,
    "resolved_by" uuid,
    "resolution_notes" text,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "idx_manual_resolution_resolved" ON "public"."manual_resolution_queue" ("resolved");

-- ============================================================================
-- 2. WEBHOOK RPC
-- ============================================================================

CREATE OR REPLACE FUNCTION "public"."process_chargily_webhook"(
    "signature_header" text,
    "payload" jsonb
) RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    secret_key text;
    calculated_signature text;
    event_id text;
    event_type text;
    checkout_status text;
    transaction_id text;
    amount_paid numeric;
    metadata_json jsonb;
    user_id uuid;
    partner_id uuid;
    appointment_time timestamptz;
    target_time timestamptz;
    case_description text;
    patient_location text;
    payment_event_id bigint;
    new_appointment_id bigint;
    time_offset int := 0;
BEGIN
    event_id := payload->>'id';
    event_type := payload->>'type';
    
    -- Idempotency Check
    IF EXISTS (SELECT 1 FROM public.payment_events WHERE event_id = event_id) THEN
        RETURN json_build_object('success', true, 'message', 'Event already processed');
    END IF;

    INSERT INTO public.payment_events (event_id, event_type, payload, status)
    VALUES (event_id, event_type, payload, 'pending')
    RETURNING id INTO payment_event_id;

    SELECT value INTO secret_key FROM public.app_config WHERE key = 'chargily_secret_key';

    IF secret_key IS NULL THEN
        UPDATE public.payment_events SET status = 'failed', error_message = 'Secret key not configured' WHERE id = payment_event_id;
        RAISE EXCEPTION 'Chargily secret key not configured';
    END IF;

    -- Verify Signature (HMAC SHA256)
    calculated_signature := encode(extensions.hmac(payload::text, secret_key, 'sha256'), 'hex');

    IF signature_header IS NULL OR calculated_signature != signature_header THEN
        UPDATE public.payment_events SET status = 'failed', error_message = 'Invalid signature' WHERE id = payment_event_id;
        RAISE EXCEPTION 'Invalid webhook signature';
    END IF;

    -- Only process checkout.paid
    IF event_type != 'checkout.paid' THEN
        UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Event type not handled');
    END IF;

    checkout_status := payload->'data'->>'status';
    transaction_id := payload->'data'->>'id';
    amount_paid := (payload->'data'->>'amount')::numeric / 100; -- Convert from cents
    metadata_json := payload->'data'->'metadata';

    IF checkout_status != 'paid' THEN
        UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Checkout not paid');
    END IF;

    user_id := (metadata_json->>'user_id')::uuid;
    partner_id := (metadata_json->>'partner_id')::uuid;
    appointment_time := (metadata_json->>'appointment_time')::timestamptz;
    case_description := metadata_json->>'case_description';
    patient_location := metadata_json->>'patient_location';

    -- Avoid duplicate appointments for same transaction
    IF EXISTS (SELECT 1 FROM public.appointments WHERE payment_transaction_id = transaction_id) THEN
        UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Appointment already exists');
    END IF;

    target_time := appointment_time;
    
    -- Retry logic for slot conflict (simple +1 minute shift up to 10 times)
    FOR time_offset IN 0..9 LOOP
        BEGIN
            INSERT INTO public.appointments (
                partner_id, booking_user_id, appointment_time, status, case_description, patient_location,
                payment_status, payment_transaction_id, amount_paid
            ) VALUES (
                partner_id, user_id, target_time, 'Confirmed', case_description, patient_location,
                'paid', transaction_id, amount_paid
            )
            RETURNING id INTO new_appointment_id;
            EXIT; -- Success
        EXCEPTION 
            WHEN unique_violation THEN
                target_time := appointment_time + (time_offset + 1) * INTERVAL '1 minute';
                IF time_offset = 9 THEN RAISE; END IF;
        END;
    END LOOP;

    UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
    RETURN json_build_object('success', true, 'appointment_id', new_appointment_id);

EXCEPTION 
    WHEN OTHERS THEN
        -- Fallback to manual queue
        INSERT INTO public.manual_resolution_queue (payment_event_id, reason, payment_transaction_id, amount_paid, customer_id, metadata)
        VALUES (payment_event_id, SQLERRM, transaction_id, amount_paid, user_id::text, metadata_json);
        UPDATE public.payment_events SET status = 'failed', error_message = SQLERRM, processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Queued for manual resolution');
END;
$$;

GRANT EXECUTE ON FUNCTION "public"."process_chargily_webhook" TO service_role;

COMMIT;
