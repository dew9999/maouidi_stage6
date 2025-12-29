-- 1. Update GET RPC to return missing fields
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
  "bio" "text",                  -- NEW
  "is_active" boolean,           -- NEW
  "confirmation_mode" "text",    -- NEW
  "notifications_enabled" boolean -- NEW
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
    mp.bio,                    -- NEW
    mp.is_active,              -- NEW
    mp.confirmation_mode,      -- NEW
    mp.notifications_enabled   -- NEW
  FROM medical_partners mp 
  JOIN users u ON u.id = mp.id 
  WHERE mp.id = target_user_id;
END; 
$$;

-- 2. Update UPDATE RPC to accept new params
CREATE OR REPLACE FUNCTION "public"."update_full_partner_profile"(
  "p_id" "uuid", 
  "p_specialty" "text", 
  "p_address" "text", 
  "p_booking_system" "text", 
  "p_limit" integer, 
  "p_state" "text", 
  "p_phone" "text",
  "p_bio" "text",                  -- NEW
  "p_is_active" boolean,           -- NEW
  "p_confirmation_mode" "text",    -- NEW
  "p_notifications_enabled" boolean -- NEW
) 
RETURNS "void"
LANGUAGE "plpgsql"
SECURITY DEFINER
AS $$
BEGIN
  -- Update medical_partners 
  UPDATE medical_partners 
  SET 
    specialty = p_specialty::specialty_enum, 
    address = p_address, 
    booking_system_type = p_booking_system, 
    daily_booking_limit = p_limit,
    bio = p_bio,                                -- NEW
    is_active = p_is_active,                    -- NEW
    confirmation_mode = p_confirmation_mode,    -- NEW
    notifications_enabled = p_notifications_enabled -- NEW
  WHERE id = p_id;
  
  -- Update users table 
  UPDATE users 
  SET 
    state = p_state, 
    phone = p_phone 
  WHERE id = p_id;
END; 
$$;
