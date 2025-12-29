-- Consolidated Payment Integration Migration
-- Date: 2025-12-29
-- Purpose: Complete Chargily payment integration with webhook support

-- ============================================================================
-- PART 1: PAYMENT COLUMNS & ENUMS
-- ============================================================================

-- Create payment status enum (skip if exists)
DO $$ BEGIN
    CREATE TYPE "public"."payment_status_enum" AS ENUM ('unpaid', 'pending', 'paid', 'failed', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Add payment columns to appointments (skip if exist)
DO $$ BEGIN
    ALTER TABLE "public"."appointments" ADD COLUMN "payment_status" "public"."payment_status_enum" DEFAULT 'unpaid';
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "public"."appointments" ADD COLUMN "payment_transaction_id" text;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "public"."appointments" ADD COLUMN "amount_paid" numeric(10,2) DEFAULT 0;
EXCEPTION
    WHEN duplicate_column THEN null;
END $$;

-- Create index (skip if exists)
CREATE INDEX IF NOT EXISTS "idx_appointments_payment_status" ON "public"."appointments" ("payment_status");

-- ============================================================================
-- PART 2: UPDATE book_appointment RPC WITH PAYMENT SUPPORT
-- ============================================================================

CREATE OR REPLACE FUNCTION "public"."book_appointment"(
    "partner_id_arg" "uuid", 
    "appointment_time_arg" timestamp with time zone, 
    "on_behalf_of_name_arg" "text", 
    "on_behalf_of_phone_arg" "text", 
    "is_partner_override" boolean, 
    "case_description_arg" "text", 
    "patient_location_arg" "text",
    "payment_status_arg" "public"."payment_status_enum" DEFAULT 'unpaid',
    "payment_transaction_id_arg" "text" DEFAULT NULL,
    "amount_paid_arg" numeric(10,2) DEFAULT 0
) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  booking_user_id_arg UUID := auth.uid();
  partner_data RECORD;
  has_existing_appointment BOOLEAN;
  new_appointment_number INT;
  new_appointment_status TEXT;
  day_of_week_arg TEXT;
  is_within_working_hours BOOLEAN := FALSE;
  time_range TEXT;
BEGIN
  SELECT is_active, category, confirmation_mode, booking_system_type, daily_booking_limit, working_hours, closed_days
  INTO partner_data
  FROM public.medical_partners WHERE id = partner_id_arg;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Medical partner not found.';
  END IF;

  IF appointment_time_arg::date < current_date AND NOT is_partner_override THEN
      RAISE EXCEPTION 'You cannot book an appointment for a past date.';
  END IF;

  IF appointment_time_arg <= now() AND NOT is_partner_override AND partner_data.booking_system_type = 'time_based' THEN
      RAISE EXCEPTION 'You cannot book an appointment in the past.';
  END IF;

  IF partner_data.category = 'Charities' THEN
    RAISE EXCEPTION 'Booking is not available for this type of partner.';
  END IF;

  IF NOT partner_data.is_active AND NOT is_partner_override THEN
    RAISE EXCEPTION 'This partner is not currently accepting appointments.';
  END IF;

  IF appointment_time_arg::date = ANY(partner_data.closed_days) THEN
      RAISE EXCEPTION 'This partner is closed on the selected date.';
  END IF;

  IF partner_data.working_hours IS NOT NULL THEN
    day_of_week_arg := EXTRACT(ISODOW FROM appointment_time_arg)::TEXT;
    IF NOT (partner_data.working_hours ? day_of_week_arg) THEN
      RAISE EXCEPTION 'This provider does not work on the selected day.';
    END IF;

    IF partner_data.booking_system_type = 'time_based' THEN
      FOR time_range IN SELECT * FROM jsonb_array_elements_text(partner_data.working_hours -> day_of_week_arg)
      LOOP
        IF appointment_time_arg::TIME >= split_part(time_range, '-', 1)::TIME AND
           appointment_time_arg::TIME < split_part(time_range, '-', 2)::TIME THEN
          is_within_working_hours := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF NOT is_within_working_hours THEN
        RAISE EXCEPTION 'The selected time is outside of the provider''s working hours.';
      END IF;
    ELSE
        is_within_working_hours := TRUE;
    END IF;
  ELSE
      RAISE EXCEPTION 'This provider has not set up their working hours.';
  END IF;
  
  IF partner_data.category = 'Homecare' THEN
    new_appointment_status := 'Pending';
  ELSE
    IF partner_data.confirmation_mode = 'auto' THEN
      new_appointment_status := 'Confirmed';
    ELSE
      new_appointment_status := 'Pending';
    END IF;
  END IF;

  IF NOT is_partner_override THEN
    IF partner_data.booking_system_type = 'number_based' THEN
      SELECT EXISTS (
        SELECT 1 FROM public.appointments
        WHERE
          booking_user_id = booking_user_id_arg AND
          partner_id = partner_id_arg AND
          DATE(appointment_time AT TIME ZONE 'utc') = DATE(appointment_time_arg AT TIME ZONE 'utc') AND
          status IN ('Pending', 'Confirmed', 'Rescheduled')
      ) INTO has_existing_appointment;
      IF has_existing_appointment THEN
        RAISE EXCEPTION 'You already have an active appointment with this partner for today.';
      END IF;
    ELSE
      SELECT EXISTS (
        SELECT 1 FROM public.appointments
        WHERE
          partner_id = partner_id_arg AND
          appointment_time = appointment_time_arg AND
          status IN ('Pending', 'Confirmed', 'Rescheduled')
      ) INTO has_existing_appointment;
      IF has_existing_appointment THEN
        RAISE EXCEPTION 'This time slot has already been booked.';
      END IF;
    END IF;
  END IF;
  
  IF partner_data.booking_system_type = 'time_based' THEN
    INSERT INTO public.appointments (
      partner_id, booking_user_id, appointment_time, on_behalf_of_patient_name, on_behalf_of_patient_phone, 
      status, case_description, patient_location, payment_status, payment_transaction_id, amount_paid
    )
    VALUES (
      partner_id_arg, booking_user_id_arg, appointment_time_arg, on_behalf_of_name_arg, on_behalf_of_phone_arg, 
      new_appointment_status, case_description_arg, patient_location_arg, payment_status_arg, payment_transaction_id_arg, amount_paid_arg
    );
  ELSIF partner_data.booking_system_type = 'number_based' THEN
    SELECT COALESCE(MAX(appointment_number), 0) + 1
    INTO new_appointment_number
    FROM public.appointments
    WHERE
      partner_id = partner_id_arg AND
      DATE(appointment_time AT TIME ZONE 'utc') = DATE(appointment_time_arg AT TIME ZONE 'utc') AND
      status IN ('Pending', 'Confirmed', 'Rescheduled');
    
    IF partner_data.daily_booking_limit IS NOT NULL AND new_appointment_number > partner_data.daily_booking_limit THEN
      RAISE EXCEPTION 'This partner is fully booked on this day.';
    END IF;
    
    INSERT INTO public.appointments (
      partner_id, booking_user_id, appointment_time, on_behalf_of_patient_name, on_behalf_of_patient_phone, 
      status, appointment_number, case_description, patient_location, payment_status, payment_transaction_id, amount_paid
    )
    VALUES (
      partner_id_arg, booking_user_id_arg, appointment_time_arg, on_behalf_of_name_arg, on_behalf_of_phone_arg, 
      new_appointment_status, new_appointment_number, case_description_arg, patient_location_arg, payment_status_arg, payment_transaction_id_arg, amount_paid_arg
    );
  END IF;
END;
$$;

-- ============================================================================
-- PART 3: CHARGILY RPC & APP_CONFIG
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE TABLE IF NOT EXISTS "public"."app_config" (
    "key" text PRIMARY KEY,
    "value" text NOT NULL,
    "description" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists, then create it
DROP POLICY IF EXISTS "Service role can read app_config" ON "public"."app_config";

CREATE POLICY "Service role can read app_config" ON "public"."app_config"
    FOR SELECT
    USING (auth.role() = 'service_role');

INSERT INTO "public"."app_config" ("key", "value", "description")
VALUES 
    ('chargily_secret_key', 'test_pk_YOUR_KEY_HERE', 'Chargily API Secret Key'),
    ('chargily_mode', 'test', 'Chargily mode: test or live')
ON CONFLICT ("key") DO NOTHING;

CREATE OR REPLACE FUNCTION "public"."create_chargily_checkout"(
    "amount_arg" numeric,
    "currency_arg" text,
    "user_id_arg" text,
    "partner_id_arg" text,
    "appointment_time_arg" text
) RETURNS json
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    secret_key text;
    chargily_mode text;
    api_url text;
    request_payload json;
    response extensions.http_response;
    response_json json;
    checkout_url text;
    checkout_id text;
BEGIN
    SELECT value INTO secret_key FROM public.app_config WHERE key = 'chargily_secret_key';
    SELECT value INTO chargily_mode FROM public.app_config WHERE key = 'chargily_mode';

    IF secret_key IS NULL THEN
        RAISE EXCEPTION 'Chargily secret key not configured';
    END IF;

    IF chargily_mode = 'live' THEN
        api_url := 'https://pay.chargily.net/api/v2/checkouts';
    ELSE
        api_url := 'https://pay.chargily.net/test/api/v2/checkouts';
    END IF;

    request_payload := json_build_object(
        'amount', amount_arg,
        'currency', lower(currency_arg),
        'success_url', 'maouidi://payment-success',
        'failure_url', 'maouidi://payment-failure',
        'webhook_endpoint', current_setting('app.settings.url', true) || '/functions/v1/webhook-handler',
        'metadata', json_build_object(
            'user_id', user_id_arg,
            'partner_id', partner_id_arg,
            'appointment_time', appointment_time_arg
        ),
        'description', 'Homecare Appointment - ' || appointment_time_arg,
        'locale', 'ar'
    );

    SELECT * INTO response
    FROM extensions.http((
        'POST',
        api_url,
        ARRAY[
            extensions.http_header('Authorization', 'Bearer ' || secret_key),
            extensions.http_header('Content-Type', 'application/json')
        ],
        'application/json',
        request_payload::text
    ));

    IF response.status != 200 AND response.status != 201 THEN
        RAISE EXCEPTION 'Chargily API error: % - %', response.status, response.content;
    END IF;

    response_json := response.content::json;
    checkout_url := response_json->>'checkout_url';
    checkout_id := response_json->>'id';

    RETURN json_build_object(
        'checkout_url', checkout_url,
        'checkout_id', checkout_id
    );
END;
$$;

-- ============================================================================
-- PART 4: WEBHOOK TABLES & RPC
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

-- Webhook processing function with auto-resolution
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

    calculated_signature := encode(extensions.hmac(payload::text, secret_key, 'sha256'), 'hex');

    IF signature_header IS NULL OR calculated_signature != signature_header THEN
        UPDATE public.payment_events SET status = 'failed', error_message = 'Invalid signature' WHERE id = payment_event_id;
        RAISE EXCEPTION 'Invalid webhook signature';
    END IF;

    IF event_type != 'checkout.paid' THEN
        UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Event type not handled');
    END IF;

    checkout_status := payload->'data'->>'status';
    transaction_id := payload->'data'->>'id';
    amount_paid := (payload->'data'->>'amount')::numeric / 100;
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

    IF EXISTS (SELECT 1 FROM public.appointments WHERE payment_transaction_id = transaction_id) THEN
        UPDATE public.payment_events SET status = 'processed', processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Appointment already exists');
    END IF;

    target_time := appointment_time;
    
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
            EXIT;
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
        INSERT INTO public.manual_resolution_queue (payment_event_id, reason, payment_transaction_id, amount_paid, customer_id, metadata)
        VALUES (payment_event_id, SQLERRM, transaction_id, amount_paid, user_id::text, metadata_json);
        UPDATE public.payment_events SET status = 'failed', error_message = SQLERRM, processed_at = now() WHERE id = payment_event_id;
        RETURN json_build_object('success', true, 'message', 'Queued for manual resolution');
END;
$$;

GRANT EXECUTE ON FUNCTION "public"."create_chargily_checkout" TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."process_chargily_webhook" TO service_role;
