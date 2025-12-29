-- 1. CLEANUP: Drop ALL potential previous versions of these functions to avoid conflicts
-- Drop the old 7-argument version (from previous fixes)
DROP FUNCTION IF EXISTS "public"."update_full_partner_profile"("uuid", "text", "text", "text", "integer", "text", "text");
-- Drop the original 8-argument version (from schema.sql)
DROP FUNCTION IF EXISTS "public"."update_full_partner_profile"("uuid", "text", "text", "text", "integer", "text", "text", "text");
-- Drop the GET function to allow return type changes
DROP FUNCTION IF EXISTS "public"."get_full_partner_profile"("uuid");

-- 2. Create NEW GET RPC (With Bio, Active, Mode, Notifications)
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
  "closed_days" "jsonb",
  "bio" "text",                  
  "is_active" boolean,           
  "confirmation_mode" "text",    
  "notifications_enabled" boolean 
)
LANGUAGE "plpgsql"
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY SELECT
    mp.id,
    mp.full_name,
    u.email,
    u.phone,
    u.state,
    mp.specialty::text,
    mp.category::text,
    mp.address,
    mp.booking_system_type,
    mp.daily_booking_limit,
    mp.working_hours,
    to_jsonb(mp.closed_days),
    mp.bio,
    mp.is_active,
    mp.confirmation_mode,
    mp.notifications_enabled
  FROM medical_partners mp
  JOIN users u ON u.id = mp.id
  WHERE mp.id = target_user_id;
END;
$$;

-- 3. Create NEW UPDATE RPC (Accepts all 11 arguments)
CREATE OR REPLACE FUNCTION "public"."update_full_partner_profile"(
  "p_id" "uuid",
  "p_specialty" "text",
  "p_address" "text",
  "p_booking_system" "text",
  "p_limit" integer,
  "p_state" "text",
  "p_phone" "text",
  "p_bio" "text",
  "p_is_active" boolean,
  "p_confirmation_mode" "text",
  "p_notifications_enabled" boolean
)
RETURNS "void"
LANGUAGE "plpgsql"
SECURITY DEFINER
AS $$
BEGIN
  -- Update medical_partners table
  UPDATE medical_partners
  SET
    specialty = p_specialty::specialty_enum,
    address = p_address,
    booking_system_type = p_booking_system,
    daily_booking_limit = p_limit,
    bio = p_bio,
    is_active = p_is_active,
    confirmation_mode = p_confirmation_mode,
    notifications_enabled = p_notifications_enabled
  WHERE id = p_id;

  -- Update users table
  UPDATE users
  SET
    state = p_state,
    phone = p_phone
  WHERE id = p_id;
END;
$$;
