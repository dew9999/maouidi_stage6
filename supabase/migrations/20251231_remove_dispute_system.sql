-- Migration: Remove dispute system (deferred to future release)
-- Date: 2025-12-31
-- Description: Cleanly removes all dispute-related database structures

-- Drop RLS policies
DROP POLICY IF EXISTS "Users can create disputes" ON public.disputes;
DROP POLICY IF EXISTS "Users can view own disputes" ON public.disputes;

-- Drop indexes
DROP INDEX IF EXISTS public.idx_disputes_raised_by;
DROP INDEX IF EXISTS public.idx_disputes_request;
DROP INDEX IF EXISTS public.idx_disputes_status;

-- Drop table
DROP TABLE IF EXISTS public.disputes CASCADE;

-- Add documentation comment
COMMENT ON SCHEMA public IS 'standard public schema - Dispute system deferred to future release';
