-- Phase 9: Anti-Scam Measures - Database Schema
-- Create tables for disputes, ratings, and partner verification

-- 1. Disputes table
CREATE TABLE IF NOT EXISTS public.disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  homecare_request_id UUID NOT NULL REFERENCES public.homecare_requests(id) ON DELETE CASCADE,
  raised_by UUID NOT NULL REFERENCES public.users(id),
  dispute_reason TEXT NOT NULL,
  dispute_description TEXT NOT NULL,
  evidence_urls TEXT[], -- Array of image/file URLs
  status TEXT NOT NULL DEFAULT 'open', -- open, investigating, resolved, closed
  resolution_notes TEXT,
  resolved_by UUID REFERENCES public.users(id), -- Admin who resolved
  resolved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_disputes_request ON public.disputes(homecare_request_id);
CREATE INDEX idx_disputes_status ON public.disputes(status);
CREATE INDEX idx_disputes_raised_by ON public.disputes(raised_by);

-- 2. Partner ratings table
CREATE TABLE IF NOT EXISTS public.partner_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  homecare_request_id UUID NOT NULL UNIQUE REFERENCES public.homecare_requests(id) ON DELETE CASCADE,
  partner_id UUID NOT NULL REFERENCES public.medical_partners(id) ON DELETE CASCADE,
  patient_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_partner_ratings_partner ON public.partner_ratings(partner_id);
CREATE INDEX idx_partner_ratings_rating ON public.partner_ratings(partner_id, rating);

-- 3. Partner verification tracking
ALTER TABLE public.medical_partners
ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'unverified',
ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS completed_services_count INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_rating DECIMAL(3,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_ratings INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_new_partner BOOLEAN DEFAULT TRUE;

-- 4. Partner payout holds (for new partners)
ALTER TABLE public.partner_payouts
ADD COLUMN IF NOT EXISTS hold_until TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS hold_reason TEXT;

-- 5. RLS Policies for disputes
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own disputes"
ON public.disputes
FOR SELECT
TO authenticated
USING (auth.uid() = raised_by);

CREATE POLICY "Users can create disputes"
ON public.disputes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = raised_by);

-- Admins can manage all disputes (handled via service role)

-- 6. RLS Policies for ratings
ALTER TABLE public.partner_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view ratings"
ON public.partner_ratings
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Patients can create ratings for their requests"
ON public.partner_ratings
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = patient_id);

-- 7. Function to update partner rating average
CREATE OR REPLACE FUNCTION update_partner_rating_average()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.medical_partners
  SET 
    average_rating = (
      SELECT AVG(rating)::DECIMAL(3,2)
      FROM public.partner_ratings
      WHERE partner_id = NEW.partner_id
    ),
    total_ratings = (
      SELECT COUNT(*)
      FROM public.partner_ratings
      WHERE partner_id = NEW.partner_id
    )
  WHERE id = NEW.partner_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_update_partner_rating
AFTER INSERT ON public.partner_ratings
FOR EACH ROW
EXECUTE FUNCTION update_partner_rating_average();

-- 8. Function to increment completed services
CREATE OR REPLACE FUNCTION increment_completed_services()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE public.medical_partners
    SET completed_services_count = completed_services_count + 1
    WHERE id = NEW.partner_id;
    
    -- Mark partner as not new after 3 completed services
    UPDATE public.medical_partners
    SET is_new_partner = FALSE
    WHERE id = NEW.partner_id
      AND completed_services_count >= 3;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_increment_completed_services
AFTER UPDATE ON public.homecare_requests
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION increment_completed_services();

-- 9. Function to apply payout holds for new partners
CREATE OR REPLACE FUNCTION apply_new_partner_hold()
RETURNS TRIGGER AS $$
DECLARE
  partner_is_new BOOLEAN;
  partner_services_count INT;
BEGIN
  -- Check if partner is new
  SELECT is_new_partner, completed_services_count
  INTO partner_is_new, partner_services_count
  FROM public.medical_partners
  WHERE id = NEW.partner_id;
  
  -- Apply 30-day hold for first 3 payouts of new partners
  IF partner_is_new = TRUE AND partner_services_count <= 3 THEN
    NEW.hold_until := NOW() + INTERVAL '30 days';
    NEW.hold_reason := 'New partner - 30 day hold on first 3 payouts';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_apply_new_partner_hold
BEFORE INSERT ON public.partner_payouts
FOR EACH ROW
EXECUTE FUNCTION apply_new_partner_hold();
