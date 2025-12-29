-- Migration: 20250101_repair_booking_system.sql
-- Description: Repairs the booking system by restoring missing RPCs, columns, and config.

BEGIN;

-- ============================================================================
-- 1. ENABLE EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- ============================================================================
-- 2. UPDATE APPOINTMENTS TABLE
-- ============================================================================
DO $$ BEGIN
    CREATE TYPE "public"."payment_status_enum" AS ENUM ('unpaid', 'pending', 'paid', 'failed', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

ALTER TABLE "public"."appointments" 
ADD COLUMN IF NOT EXISTS "payment_status" "public"."payment_status_enum" DEFAULT 'unpaid',
ADD COLUMN IF NOT EXISTS "payment_transaction_id" text,
ADD COLUMN IF NOT EXISTS "amount_paid" numeric(10,2) DEFAULT 0;

CREATE INDEX IF NOT EXISTS "idx_appointments_payment_status" ON "public"."appointments" ("payment_status");

-- ============================================================================
-- 3. APP CONFIG & KEYS
-- ============================================================================
CREATE TABLE IF NOT EXISTS "public"."app_config" (
    "key" text PRIMARY KEY,
    "value" text NOT NULL,
    "description" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;

-- Policy: Service role can read everything
DROP POLICY IF EXISTS "Service role can read app_config" ON "public"."app_config";
CREATE POLICY "Service role can read app_config" ON "public"."app_config" FOR SELECT USING (auth.role() = 'service_role');

-- INSERT KEYS (Using Test Keys found in project history)
INSERT INTO "public"."app_config" ("key", "value", "description")
VALUES 
    ('chargily_public_key', 'test_pk_CoWeoZeSSV9oolwQopcBqrdFwrKmx1iSygr4xLOE', 'Chargily public key'),
    ('chargily_secret_key', 'test_sk_FuVw05JCyPnpmfSdfVAm0xi93MU1exfsNiRVXuw9', 'Chargily secret key'),
    ('chargily_mode', 'test', 'Payment mode')
ON CONFLICT ("key") DO UPDATE SET value = EXCLUDED.value;

-- ============================================================================
-- 4. RESTORE create_chargily_checkout RPC
-- ============================================================================

-- DROP EXISTING VARIABLES TO FIX "function name is not unique" ERROR
DROP FUNCTION IF EXISTS "public"."create_chargily_checkout"(numeric, text, jsonb); -- The one you created manually
DROP FUNCTION IF EXISTS "public"."create_chargily_checkout"(numeric, text, text, text, text); -- The correct signature

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
        -- Adjust webhook URL as needed
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
-- 5. UPDATE book_appointment RPC
-- ============================================================================

-- DROP EXISTING VARIABLES TO FIX "function name is not unique" ERROR
-- 1. Drop the old signature (7 args)
DROP FUNCTION IF EXISTS "public"."book_appointment"(uuid, timestamptz, text, text, boolean, text, text);
-- 2. Drop the manual signature you created (10 args, all text/numeric)
DROP FUNCTION IF EXISTS "public"."book_appointment"(uuid, timestamptz, text, text, boolean, text, text, text, text, numeric);

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

-- Grants
GRANT EXECUTE ON FUNCTION "public"."create_chargily_checkout" TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."book_appointment" TO authenticated;

COMMIT;
