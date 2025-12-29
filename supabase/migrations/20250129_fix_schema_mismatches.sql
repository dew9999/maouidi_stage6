-- Fix 1: Drop and recreate get_full_partner_profile (return type changed - removed wilaya)
DROP FUNCTION IF EXISTS "public"."get_full_partner_profile"("target_user_id" "uuid");

CREATE OR REPLACE FUNCTION "public"."get_full_partner_profile"("target_user_id" "uuid") 
RETURNS TABLE(
  "id" "uuid", 
  "full_name" "text", 
  "email" "text", 
  "phone" "text", 
  "state" "text", 
  "specialty" "text", 
  "category" "text", 
  "address" "text", 
  "booking_system_type" "text", 
  "daily_booking_limit" integer, 
  "working_hours" "jsonb", 
  "closed_days" "jsonb"
)
LANGUAGE "plpgsql"
AS $$
BEGIN
  RETURN QUERY SELECT 
    mp.id, 
    mp.full_name, 
    u.email, 
    u.phone, 
    u.state,  -- Changed from u.wilaya
    mp.specialty::text,  -- Cast enum to text
    mp.category::text,   -- Cast enum to text for consistency
    mp.address, 
    mp.booking_system_type, 
    mp.daily_booking_limit,
    mp.working_hours, 
    to_jsonb(mp.closed_days) as closed_days  -- Ensure proper jsonb conversion
  FROM medical_partners mp 
  JOIN users u ON u.id = mp.id 
  WHERE mp.id = target_user_id;
END; 
$$;

-- Fix 2: Drop and recreate update_full_partner_profile (signature changed - removed p_wilaya)
DROP FUNCTION IF EXISTS "public"."update_full_partner_profile"(
  "p_id" "uuid", 
  "p_specialty" "text", 
  "p_address" "text", 
  "p_booking_system" "text", 
  "p_limit" integer, 
  "p_wilaya" "text",
  "p_state" "text", 
  "p_phone" "text"
);

CREATE OR REPLACE FUNCTION "public"."update_full_partner_profile"(
  "p_id" "uuid", 
  "p_specialty" "text", 
  "p_address" "text", 
  "p_booking_system" "text", 
  "p_limit" integer, 
  "p_state" "text", 
  "p_phone" "text"
) 
RETURNS "void"
LANGUAGE "plpgsql"
AS $$
BEGIN
  -- Update medical_partners with specialty cast to enum
  UPDATE medical_partners 
  SET 
    specialty = p_specialty::specialty_enum,  -- Cast text to enum
    address = p_address, 
    booking_system_type = p_booking_system, 
    daily_booking_limit = p_limit 
  WHERE id = p_id;
  
  -- Update users table (removed wilaya, only state)
  UPDATE users 
  SET 
    state = p_state, 
    phone = p_phone 
  WHERE id = p_id;
END; 
$$;
