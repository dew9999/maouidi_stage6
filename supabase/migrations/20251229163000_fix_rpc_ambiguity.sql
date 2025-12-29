-- Migration to clean up book_appointment RPC ambiguity
-- Date: 2025-12-29
-- Purpose: Drop all variations of book_appointment and recreate the correct one

-- 1. Drop the function with ALL possible signatures just to be safe
DROP FUNCTION IF EXISTS "public"."book_appointment"(uuid, timestamp with time zone, text, text, boolean, text, text);
DROP FUNCTION IF EXISTS "public"."book_appointment"(uuid, timestamp with time zone, text, text, boolean, text, text, "public"."payment_status_enum", text, numeric);

-- 2. Recreate the definitive version
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
  -- 1. Fetch Partner Data
  SELECT is_active, category, confirmation_mode, booking_system_type, daily_booking_limit, working_hours, closed_days
  INTO partner_data
  FROM public.medical_partners WHERE id = partner_id_arg;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Medical partner not found.';
  END IF;

  -- 2. Date/Time Validation
  IF appointment_time_arg::date < current_date AND NOT is_partner_override THEN
      RAISE EXCEPTION 'You cannot book an appointment for a past date.';
  END IF;

  IF appointment_time_arg <= now() AND NOT is_partner_override AND partner_data.booking_system_type = 'time_based' THEN
      RAISE EXCEPTION 'You cannot book an appointment in the past.';
  END IF;

  -- 3. Partner Status/Category Validation
  IF partner_data.category = 'Charities' THEN
    RAISE EXCEPTION 'Booking is not available for this type of partner.';
  END IF;

  IF NOT partner_data.is_active AND NOT is_partner_override THEN
    RAISE EXCEPTION 'This partner is not currently accepting appointments.';
  END IF;

  IF appointment_time_arg::date = ANY(partner_data.closed_days) THEN
      RAISE EXCEPTION 'This partner is closed on the selected date.';
  END IF;

  -- 4. Working Hours Validation
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
  
  -- 5. Determine Initial Status
  IF partner_data.category = 'Homecare' THEN
    -- Homecare starts as Pending unless paid (handled by caller or webhook)
    -- If this is called directly for homecare without logic override, it defaults to Pending
    new_appointment_status := 'Pending';
  ELSE
    IF partner_data.confirmation_mode = 'auto' THEN
      new_appointment_status := 'Confirmed';
    ELSE
      new_appointment_status := 'Pending';
    END IF;
  END IF;

  -- 6. Duplicate/Slot Availability Check
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
  
  -- 7. Insert Appointment
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
