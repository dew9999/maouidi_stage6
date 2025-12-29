import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, signature",
};
serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    // 1. Extract signature header
    const signature = req.headers.get("signature");

    // 2. Get RAW request body (critical for signature verification)
    const rawBody = await req.text();

    // 3. Parse JSON payload
    const payload = JSON.parse(rawBody);
    console.log("Webhook received:", {
      type: payload.type,
      checkout_id: payload.data?.id,
      has_signature: !!signature,
    });
    // 4. Create Supabase client with SERVICE ROLE
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    // 5. Call database RPC with RAW body for signature verification
    const { data, error } = await supabase.rpc("process_chargily_webhook", {
      signature_header: signature || "",
      payload: payload,
    });
    if (error) {
      console.error("Webhook RPC error:", error);
      // Still return 200 to prevent retries
      return new Response(
        JSON.stringify({
          received: true,
          error: error.message,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    // 6. Success
    console.log("✅ Webhook processed:", data);
    return new Response(
      JSON.stringify({
        received: true,
        result: data,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ Webhook error:", error);

    // Always return 200 to prevent retries
    return new Response(
      JSON.stringify({
        received: true,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
