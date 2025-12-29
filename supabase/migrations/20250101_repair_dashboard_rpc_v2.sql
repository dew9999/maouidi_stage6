-- Migration: 20250101_repair_dashboard_rpc_v2.sql
-- Description: Corrected version - returns TABLE instead of JSON to match Dart expectations

BEGIN;

-- Drop existing function
DROP FUNCTION IF EXISTS "public"."get_partner_dashboard_appointments"(uuid);

-- Create function that returns TABLE (not JSON)
CREATE OR REPLACE FUNCTION "public"."get_partner_dashboard_appointments"(partner_id_arg uuid)
RETURNS TABLE(
  id bigint,
  partner_id uuid,
  booking_user_id uuid,
  on_behalf_of_patient_name text,
  appointment_time timestamp with time zone,
  status text,
  on_behalf_of_patient_phone text,
  appointment_number integer,
  is_rescheduled boolean,
  completed_at timestamp with time zone,
  has_review boolean,
  case_description text,
  patient_location text,
  patient_first_name text,
  patient_last_name text,
  patient_phone text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET "search_path" TO ''
AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.partner_id,
    a.booking_user_id,
    a.on_behalf_of_patient_name,
    a.appointment_time,
    a.status,
    a.on_behalf_of_patient_phone,
    a.appointment_number,
    a.is_rescheduled,
    a.completed_at,
    a.has_review,
    a.case_description,
    a.patient_location,
    -- Patient details from users table
    u.first_name as patient_first_name,
    u.last_name as patient_last_name,
    u.phone as patient_phone
  FROM public.appointments a
  LEFT JOIN public.users u ON a.booking_user_id = u.id
  WHERE a.partner_id = partner_id_arg
  ORDER BY a.appointment_time ASC;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO anon;

COMMIT;
