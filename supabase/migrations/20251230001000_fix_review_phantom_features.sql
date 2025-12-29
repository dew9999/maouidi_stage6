-- Fix Review Phantom Features

-- 1. Add has_review boolean to appointments for efficient filtering
ALTER TABLE "public"."appointments" ADD COLUMN IF NOT EXISTS "has_review" boolean DEFAULT false;

-- 2. Create reviews table
CREATE TABLE IF NOT EXISTS "public"."reviews" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    "appointment_id" integer REFERENCES "public"."appointments"("id") ON DELETE CASCADE,
    "partner_id" uuid REFERENCES "public"."medical_partners"("id") ON DELETE CASCADE,
    "user_id" uuid REFERENCES "auth"."users"("id") ON DELETE CASCADE,
    "rating" numeric(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    "comment" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    UNIQUE("appointment_id")
);

-- Enable RLS
ALTER TABLE "public"."reviews" ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public reviews are viewable by everyone" ON "public"."reviews"
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews for their own appointments" ON "public"."reviews"
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. RPC: Submit Review with Validation
CREATE OR REPLACE FUNCTION "public"."submit_review"(
    "appointment_id_arg" integer,
    "rating_arg" numeric,
    "review_text_arg" text
)
RETURNS "void"
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    appt_record record;
BEGIN
    -- unique appointment check is handled by table constraint, but we strictly validate business rules here
    
    SELECT * INTO appt_record
    FROM appointments
    WHERE id = appointment_id_arg;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Appointment not found.';
    END IF;

    -- Verify ownership (security)
    IF appt_record.patient_id != auth.uid() THEN
        RAISE EXCEPTION 'You can only review your own appointments.';
    END IF;

    -- 1. Status Check
    -- Checking strictly for 'Completed' (PascalCase as seen in code) or 'completed' to be safe
    IF appt_record.status NOT ILIKE 'Completed' THEN
        RAISE EXCEPTION 'You can only review completed appointments.';
    END IF;

    -- 2. Duplicate Check
    IF appt_record.has_review = true THEN
        RAISE EXCEPTION 'Review already submitted for this appointment.';
    END IF;

    -- 3. Time Window Check (24 Hours)
    -- coalesce completed_at to now if null? No, if null it's not completed properly.
    IF appt_record.completed_at IS NULL THEN
         RAISE EXCEPTION 'Appointment completion time is missing.';
    END IF;

    IF (now() > (appt_record.completed_at + interval '24 hours')) THEN
        RAISE EXCEPTION 'Review window expired (24 hours).';
    END IF;

    -- Insert Review
    INSERT INTO reviews (appointment_id, partner_id, user_id, rating, comment)
    VALUES (
        appointment_id_arg,
        appt_record.partner_id,
        appt_record.patient_id,
        rating_arg,
        review_text_arg
    );

    -- Update Flag
    UPDATE appointments
    SET has_review = true
    WHERE id = appointment_id_arg;

END;
$$;

-- 4. RPC: Get Reviews with User Names (for Partner Public Profile)
DROP FUNCTION IF EXISTS "public"."get_reviews_with_user_names"("uuid");
CREATE OR REPLACE FUNCTION "public"."get_reviews_with_user_names"("partner_id_arg" uuid)
RETURNS TABLE (
    "id" uuid,
    "rating" numeric,
    "comment" text,
    "created_at" timestamp with time zone,
    "user_first_name" text,
    "user_last_name" text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.rating,
        r.comment,
        r.created_at,
        u.first_name,
        u.last_name
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.partner_id = partner_id_arg
    ORDER BY r.created_at DESC;
END;
$$;
