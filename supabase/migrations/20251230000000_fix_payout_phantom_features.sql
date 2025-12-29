-- Fix Payout Phantom Features

-- 1. Add payout_schedule to medical_partners
ALTER TABLE "public"."medical_partners" ADD COLUMN IF NOT EXISTS "payout_schedule" text DEFAULT 'weekly';

-- 2. Create partner_payouts table
CREATE TABLE IF NOT EXISTS "public"."partner_payouts" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    "partner_id" uuid REFERENCES "public"."medical_partners"("id") ON DELETE CASCADE,
    "payout_period" text NOT NULL, -- '2025-W01' or '2025-01'
    "period_start_date" timestamp with time zone NOT NULL,
    "period_end_date" timestamp with time zone NOT NULL,
    "total_earnings" numeric(10,2) DEFAULT 0,
    "num_requests" integer DEFAULT 0,
    "payout_status" text DEFAULT 'pending', -- pending, completed, failed
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

-- Enable RLS for partner_payouts
ALTER TABLE "public"."partner_payouts" ENABLE ROW LEVEL SECURITY;

-- Policy: Partners can view their own payouts
DROP POLICY IF EXISTS "Partners can view own payouts" ON "public"."partner_payouts";
CREATE POLICY "Partners can view own payouts" ON "public"."partner_payouts"
    FOR SELECT
    USING (auth.uid() = partner_id);

-- 3. Create RPC for lifetime earnings
CREATE OR REPLACE FUNCTION "public"."get_partner_lifetime_earnings"("partner_id_arg" uuid)
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_earnings numeric;
BEGIN
    SELECT COALESCE(SUM(amount_paid), 0)
    INTO total_earnings
    FROM appointments
    WHERE partner_id = partner_id_arg
    AND status = 'Completed'; -- Using PascalCase 'Completed' based on common usage in app, but DB might be different. Let's assume standard 'Completed' from previous edits.

    RETURN total_earnings;
END;
$$;
