-- 1. Clean Slate: Drop old phantom table/RPCs to avoid conflicts
DROP TABLE IF EXISTS "public"."reviews" CASCADE;
DROP FUNCTION IF EXISTS "public"."submit_review"(integer, numeric, text);
DROP FUNCTION IF EXISTS "public"."submit_review"(bigint, numeric, text);

-- 2. Create Reviews Table (Corrected Types)
CREATE TABLE "public"."reviews" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    "appointment_id" bigint REFERENCES "public"."appointments"("id") ON DELETE CASCADE, -- Fixed: integer -> bigint
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

CREATE POLICY "Public reviews are viewable by everyone" ON "public"."reviews"
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews for their own appointments" ON "public"."reviews"
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. RPC: Submit Review (Fixed Logic)
CREATE OR REPLACE FUNCTION "public"."submit_review"(
    "appointment_id_arg" bigint,  -- Fixed: integer -> bigint
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
    SELECT * INTO appt_record
    FROM appointments
    WHERE id = appointment_id_arg;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Appointment not found.';
    END IF;

    -- Fixed: patient_id -> booking_user_id
    IF appt_record.booking_user_id != auth.uid() THEN
        RAISE EXCEPTION 'You can only review your own appointments.';
    END IF;

    IF appt_record.status NOT ILIKE 'Completed' THEN
        RAISE EXCEPTION 'You can only review completed appointments.';
    END IF;

    IF appt_record.has_review = true THEN
        RAISE EXCEPTION 'Review already submitted for this appointment.';
    END IF;

    IF appt_record.completed_at IS NULL THEN
         RAISE EXCEPTION 'Appointment completion time is missing.';
    END IF;

    -- 24 Hour Window Check
    IF (now() > (appt_record.completed_at + interval '24 hours')) THEN
        RAISE EXCEPTION 'Review window expired (24 hours).';
    END IF;

    INSERT INTO reviews (appointment_id, partner_id, user_id, rating, comment)
    VALUES (
        appointment_id_arg,
        appt_record.partner_id,
        appt_record.booking_user_id, -- Fixed: patient_id -> booking_user_id
        rating_arg,
        review_text_arg
    );

    UPDATE appointments
    SET has_review = true
    WHERE id = appointment_id_arg;
END;
$$;

-- 4. RPC: Get Reviews (Aligned columns)
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
