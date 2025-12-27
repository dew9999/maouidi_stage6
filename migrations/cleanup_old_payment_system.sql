-- ==========================================
-- CLEANUP SCRIPT - Run this FIRST
-- ==========================================
-- This removes the old migration so we can run the new secure one

-- 1. Drop old triggers
DROP TRIGGER IF EXISTS set_total_amount ON public.homecare_requests;
DROP FUNCTION IF EXISTS calculate_total_amount();
DROP FUNCTION IF EXISTS generate_receipt_number();

-- 2. Drop old RLS policies
DROP POLICY IF EXISTS "Partners can view own payouts" ON public.partner_payouts;
DROP POLICY IF EXISTS "Service role manages payouts" ON public.partner_payouts;
DROP POLICY IF EXISTS "Users view own receipts" ON public.payment_receipts;
DROP POLICY IF EXISTS "Service role manages receipts" ON public.payment_receipts;
DROP POLICY IF EXISTS "Public config accessible to users" ON public.app_config;
DROP POLICY IF EXISTS "Service role can access all config" ON public.app_config;
DROP POLICY IF EXISTS "Allow authenticated users to read config" ON public.app_config;
DROP POLICY IF EXISTS "Only service role can update config" ON public.app_config;

-- 3. Drop old app_config table (will recreate with is_secret column)
DROP TABLE IF EXISTS public.app_config CASCADE;

-- 4. Drop old tables (will recreate)
DROP TABLE IF EXISTS public.payment_receipts CASCADE;
DROP TABLE IF EXISTS public.partner_payouts CASCADE;

-- 5. Remove columns from homecare_requests (will re-add)
ALTER TABLE public.homecare_requests
DROP COLUMN IF EXISTS base_price CASCADE,
DROP COLUMN IF EXISTS negotiated_price CASCADE,
DROP COLUMN IF EXISTS platform_fee CASCADE,
DROP COLUMN IF EXISTS total_amount CASCADE,
DROP COLUMN IF EXISTS current_offer CASCADE,
DROP COLUMN IF EXISTS offered_by CASCADE,
DROP COLUMN IF EXISTS negotiation_history CASCADE,
DROP COLUMN IF EXISTS negotiation_round CASCADE,
DROP COLUMN IF EXISTS payment_status CASCADE,
DROP COLUMN IF EXISTS chargily_checkout_id CASCADE,
DROP COLUMN IF EXISTS chargily_transaction_id CASCADE,
DROP COLUMN IF EXISTS paid_at CASCADE,
DROP COLUMN IF EXISTS service_started_at CASCADE,
DROP COLUMN IF EXISTS service_completed_at CASCADE,
DROP COLUMN IF EXISTS patient_confirmed_at CASCADE,
DROP COLUMN IF EXISTS refund_status CASCADE,
DROP COLUMN IF EXISTS refund_amount CASCADE,
DROP COLUMN IF EXISTS refunded_at CASCADE,
DROP COLUMN IF EXISTS cancellation_reason CASCADE;

-- Done! Now run homecare_payment_system.sql
