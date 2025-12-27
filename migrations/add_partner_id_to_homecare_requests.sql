-- Migration: Add partner_id to homecare_requests table
-- This allows homecare requests to be sent to specific partners

-- Add partner_id column with foreign key to medical_partners
ALTER TABLE public.homecare_requests
ADD COLUMN IF NOT EXISTS partner_id uuid;

-- Add foreign key constraint
ALTER TABLE public.homecare_requests
ADD CONSTRAINT homecare_requests_partner_id_fkey
FOREIGN KEY (partner_id)
REFERENCES public.medical_partners(id)
ON DELETE CASCADE;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_homecare_requests_partner_id
ON public.homecare_requests(partner_id, created_at DESC);

-- Add on_behalf_of fields for booking on behalf of others
ALTER TABLE public.homecare_requests
ADD COLUMN IF NOT EXISTS on_behalf_of_name text;

ALTER TABLE public.homecare_requests
ADD COLUMN IF NOT EXISTS on_behalf_of_phone text;

-- Add RLS policy for partners to view their homecare requests
CREATE POLICY "Partners can view their own homecare requests"
ON public.homecare_requests
FOR SELECT
TO authenticated
USING (auth.uid() = partner_id);

-- Add RLS policy for partners to update their homecare requests (accept/decline)
CREATE POLICY "Partners can update their own homecare requests"
ON public.homecare_requests
FOR UPDATE 
TO authenticated
USING (auth.uid() = partner_id)
WITH CHECK (auth.uid() = partner_id);
