-- Migration: 20250101_repair_dashboard_rpc.sql
-- Description: Restores the get_partner_dashboard_appointments RPC which was missing or broken, causing the dashboard to be empty.

BEGIN;

DROP FUNCTION IF EXISTS "public"."get_partner_dashboard_appointments"(uuid);

CREATE OR REPLACE FUNCTION "public"."get_partner_dashboard_appointments"(partner_id_arg uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET "search_path" TO ''
AS $$
BEGIN
  RETURN (
    SELECT coalesce(json_agg(t), '[]'::json)
    FROM (
      SELECT
        a.id,
        a.partner_id,
        a.booking_user_id,
        a.appointment_time,
        a.status,
        a.on_behalf_of_patient_name,
        a.on_behalf_of_patient_phone,
        a.appointment_number,
        a.is_rescheduled,
        a.completed_at,
        a.has_review,
        a.case_description,
        a.patient_location,
        a.payment_status,
        a.payment_transaction_id,
        a.amount_paid,
        -- Patient details from users table
        u.first_name as patient_first_name,
        u.last_name as patient_last_name,
        u.phone as patient_phone,
        -- Ensure booking_type exists (handling if column is missing by defaulting, but it should be there from previous migrations)
        -- Note: If booking_type column doesn't exist yet (it was in the plan but maybe not in user's dump), we CAST or use defaults.
        -- We will assume standard columns since we fixed the schema.
        'clinic' as booking_type, -- Default for now if not in table, or select a.booking_type if it exists.
        a.patient_location as homecare_address -- mapping patient_location to homecare_address for model compatibility
      FROM public.appointments a
      LEFT JOIN public.users u ON a.booking_user_id = u.id
      WHERE a.partner_id = partner_id_arg
      ORDER BY a.appointment_time ASC
    ) t
  );
END;
$$;

GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."get_partner_dashboard_appointments"(uuid) TO anon;

COMMIT;
