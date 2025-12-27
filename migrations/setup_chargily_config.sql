-- Create app_config table to store Chargily API keys
-- This allows easy switching between test and production keys

-- Step 1: Create config table
CREATE TABLE IF NOT EXISTS public.app_config (
  id SERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  is_production BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Insert Chargily test keys
INSERT INTO public.app_config (key, value, description, is_production)
VALUES 
  ('chargily_public_key', 'test_pk_CoWeoZeSSV9oolwQopcBqrdFwrKmx1iSygr4xLOE', 'Chargily public key (test mode)', FALSE),
  ('chargily_secret_key', 'test_sk_FuVw05JCyPnpmfSdfVAm0xi93MU1exfsNiRVXuw9', 'Chargily secret key (test mode)', FALSE),
  ('chargily_mode', 'test', 'Payment mode: test or production', FALSE)
ON CONFLICT (key) DO UPDATE SET 
  value = EXCLUDED.value,
  updated_at = NOW();

-- Step 3: Add RLS policies
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read config (for public keys)
CREATE POLICY "Allow authenticated users to read config"
ON public.app_config
FOR SELECT
TO authenticated
USING (true);

-- Only service role can update config
CREATE POLICY "Only service role can update config"
ON public.app_config
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Step 4: Create function to update to production keys
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

-- To switch to production later, run:
-- SELECT switch_to_production_keys('your_production_public_key', 'your_production_secret_key');

-- View current config
SELECT key, 
       CASE 
         WHEN key LIKE '%secret%' THEN LEFT(value, 10) || '...' 
         ELSE value 
       END as value,
       is_production,
       description
FROM public.app_config
ORDER BY key;
