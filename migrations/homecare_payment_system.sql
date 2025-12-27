-- ==========================================
-- PHASE 1: CORE TABLES & PAYMENT LOGIC
-- ==========================================

-- 1. Update Homecare Requests with Payment Fields
ALTER TABLE public.homecare_requests
ADD COLUMN IF NOT EXISTS base_price DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS negotiated_price DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS platform_fee DECIMAL(10,2) DEFAULT 500,
ADD COLUMN IF NOT EXISTS total_amount DECIMAL(10,2),
-- Negotiation tracking
ADD COLUMN IF NOT EXISTS current_offer DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS offered_by TEXT,
ADD COLUMN IF NOT EXISTS negotiation_history JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS negotiation_round INT DEFAULT 0,
-- Payment tracking
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS chargily_checkout_id TEXT,
ADD COLUMN IF NOT EXISTS chargily_transaction_id TEXT,
ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP WITH TIME ZONE,
-- Service tracking
ADD COLUMN IF NOT EXISTS service_started_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS service_completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS patient_confirmed_at TIMESTAMP WITH TIME ZONE,
-- Refund tracking
ADD COLUMN IF NOT EXISTS refund_status TEXT,
ADD COLUMN IF NOT EXISTS refund_amount DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS refunded_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- 2. Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_homecare_requests_payment_status 
ON public.homecare_requests(payment_status);
CREATE INDEX IF NOT EXISTS idx_homecare_requests_status_partner 
ON public.homecare_requests(status, partner_id);

-- 3. Partner Payouts Table
CREATE TABLE IF NOT EXISTS public.partner_payouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id UUID NOT NULL REFERENCES public.medical_partners(id) ON DELETE CASCADE,
  payout_period TEXT NOT NULL,
  period_start_date DATE NOT NULL,
  period_end_date DATE NOT NULL,
  total_earnings DECIMAL(10,2) NOT NULL DEFAULT 0,
  num_requests INT NOT NULL DEFAULT 0,
  payout_status TEXT NOT NULL DEFAULT 'pending',
  payout_method TEXT,
  payout_details JSONB,
  payout_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_partner_payouts_partner_id 
ON public.partner_payouts(partner_id, created_at DESC);

-- 4. Payment Receipts Table
CREATE TABLE IF NOT EXISTS public.payment_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  homecare_request_id UUID NOT NULL REFERENCES public.homecare_requests(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES public.medical_partners(id) ON DELETE CASCADE,
  
  service_price DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL DEFAULT 500,
  total_paid DECIMAL(10,2) NOT NULL,
  
  partner_amount DECIMAL(10,2) NOT NULL,
  payout_status TEXT NOT NULL DEFAULT 'pending',
  payout_date TIMESTAMP WITH TIME ZONE,
  
  receipt_number TEXT UNIQUE NOT NULL,
  issued_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  receipt_pdf_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_receipts_request_id ON public.payment_receipts(homecare_request_id);

-- 5. RLS Policies (Security)
ALTER TABLE public.partner_payouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Partners can view own payouts" ON public.partner_payouts FOR SELECT TO authenticated USING (auth.uid() = partner_id);
CREATE POLICY "Service role manages payouts" ON public.partner_payouts FOR ALL TO service_role USING (true) WITH CHECK (true);

ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own receipts" ON public.payment_receipts FOR SELECT TO authenticated USING (auth.uid() = patient_id OR auth.uid() = partner_id);
CREATE POLICY "Service role manages receipts" ON public.payment_receipts FOR ALL TO service_role USING (true) WITH CHECK (true);

-- 6. IMPROVED Trigger for Total Amount
-- (Calculates total even if negotiation hasn't started yet)
CREATE OR REPLACE FUNCTION calculate_total_amount()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.negotiated_price IS NOT NULL THEN
    NEW.total_amount := NEW.negotiated_price + COALESCE(NEW.platform_fee, 500);
  ELSIF NEW.base_price IS NOT NULL THEN
    NEW.total_amount := NEW.base_price + COALESCE(NEW.platform_fee, 500);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_total_amount
BEFORE INSERT OR UPDATE ON public.homecare_requests
FOR EACH ROW
EXECUTE FUNCTION calculate_total_amount();

-- 7. Receipt Number Generator
CREATE OR REPLACE FUNCTION generate_receipt_number()
RETURNS TEXT AS $$
DECLARE
  next_num INT;
  year_part TEXT;
BEGIN
  year_part := TO_CHAR(NOW(), 'YYYY');
  SELECT COALESCE(MAX(CAST(SUBSTRING(receipt_number FROM 9) AS INT)), 0) + 1
  INTO next_num
  FROM public.payment_receipts
  WHERE receipt_number LIKE 'HC-' || year_part || '-%';
  
  RETURN 'HC-' || year_part || '-' || LPAD(next_num::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- PHASE 2: SECURE APP CONFIG (FIXED)
-- ==========================================

-- 1. Create Secure Config Table
CREATE TABLE IF NOT EXISTS public.app_config (
  id SERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  is_secret BOOLEAN DEFAULT FALSE, -- Security Flag
  is_production BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Insert Keys (Marking Secret Key as TRUE for is_secret)
INSERT INTO public.app_config (key, value, description, is_secret, is_production)
VALUES 
  ('chargily_public_key', 'test_pk_CoWeoZeSSV9oolwQopcBqrdFwrKmx1iSygr4xLOE', 'Chargily public key', FALSE, FALSE),
  ('chargily_secret_key', 'test_sk_FuVw05JCyPnpmfSdfVAm0xi93MU1exfsNiRVXuw9', 'Chargily secret key', TRUE, FALSE), -- SECURE THIS!
  ('chargily_mode', 'test', 'Payment mode', FALSE, FALSE)
ON CONFLICT (key) DO UPDATE SET 
  value = EXCLUDED.value,
  updated_at = NOW();

-- 3. SECURE RLS POLICIES (Crucial Step)
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Policy A: Authenticated users can ONLY see public keys (is_secret = false)
CREATE POLICY "Public config accessible to users"
ON public.app_config
FOR SELECT
TO authenticated
USING (is_secret = FALSE); 

-- Policy B: Service Role (Edge Functions) can see EVERYTHING
CREATE POLICY "Service role can access all config"
ON public.app_config
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- 4. Helper to Switch to Production
CREATE OR REPLACE FUNCTION switch_to_production_keys(
  p_public_key TEXT,
  p_secret_key TEXT
)
RETURNS VOID AS $$
BEGIN
  UPDATE public.app_config 
  SET value = p_public_key, is_production = TRUE, updated_at = NOW()
  WHERE key = 'chargily_public_key';
  
  UPDATE public.app_config 
  SET value = p_secret_key, is_production = TRUE, updated_at = NOW()
  WHERE key = 'chargily_secret_key';
  
  UPDATE public.app_config 
  SET value = 'production', updated_at = NOW()
  WHERE key = 'chargily_mode';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
