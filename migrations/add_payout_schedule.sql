-- Add payout_schedule column to medical_partners table
-- And create helper function for lifetime earnings

-- Add payout schedule column
ALTER TABLE public.medical_partners
ADD COLUMN IF NOT EXISTS payout_schedule TEXT DEFAULT 'weekly';

-- Add comment
COMMENT ON COLUMN public.medical_partners.payout_schedule IS 'weekly or monthly';

-- Create function to get partner lifetime earnings
CREATE OR REPLACE FUNCTION get_partner_lifetime_earnings(partner_id_arg UUID)
RETURNS DECIMAL(10,2) AS $$
DECLARE
  total_earnings DECIMAL(10,2);
BEGIN
  SELECT COALESCE(SUM(negotiated_price), 0)
  INTO total_earnings
  FROM public.homecare_requests
  WHERE partner_id = partner_id_arg
    AND status = 'completed';
  
  RETURN total_earnings;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
