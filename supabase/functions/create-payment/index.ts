import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface PaymentRequest {
  requestId: string;
}

interface ChargilyCheckoutResponse {
  checkout_url: string;
  id: string;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Parse request
    const { requestId }: PaymentRequest = await req.json();

    if (!requestId) {
      throw new Error("requestId is required");
    }

    // 2. Create Supabase client with SERVICE ROLE (can access secret keys)
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Fetch Chargily secret key from app_config (SECURE!)
    const { data: secretConfig, error: configError } = await supabase
      .from("app_config")
      .select("value")
      .eq("key", "chargily_secret_key")
      .single();

    if (configError || !secretConfig) {
      throw new Error("Failed to fetch Chargily secret key");
    }

    const chargilySecretKey = secretConfig.value;

    // 4. Fetch homecare request details
    const { data: homecareRequest, error: requestError } = await supabase
      .from("homecare_requests")
      .select("id, total_amount, patient_id, partner_id, negotiated_price")
      .eq("id", requestId)
      .single();

    if (requestError || !homecareRequest) {
      throw new Error("Homecare request not found");
    }

    // 5. Fetch patient details for Chargily
    const { data: patient, error: patientError } = await supabase
      .from("users")
      .select("email, display_name, phone_number")
      .eq("id", homecareRequest.patient_id)
      .single();

    if (patientError || !patient) {
      throw new Error("Patient not found");
    }

    // 6. Create Chargily checkout
    const chargilyResponse = await fetch(
      "https://pay.chargily.net/test/api/v2/checkouts",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${chargilySecretKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          amount: homecareRequest.total_amount * 100, // Convert to cents
          currency: "dzd",
          success_url: `${
            Deno.env.get("APP_URL")
          }/payment-success?request_id=${requestId}`,
          failure_url: `${
            Deno.env.get("APP_URL")
          }/payment-failed?request_id=${requestId}`,
          webhook_url: `${supabaseUrl}/functions/v1/handle-webhook`,
          customer: {
            name: patient.display_name || "Patient",
            email: patient.email,
            phone: patient.phone_number,
          },
          metadata: {
            request_id: requestId,
            patient_id: homecareRequest.patient_id,
            partner_id: homecareRequest.partner_id,
          },
          description:
            `Homecare Service Payment - ${homecareRequest.negotiated_price} DA`,
        }),
      },
    );

    if (!chargilyResponse.ok) {
      const errorText = await chargilyResponse.text();
      throw new Error(`Chargily API error: ${errorText}`);
    }

    const checkoutData: ChargilyCheckoutResponse = await chargilyResponse
      .json();

    // 7. Update homecare_request with checkout_id
    const { error: updateError } = await supabase
      .from("homecare_requests")
      .update({
        chargily_checkout_id: checkoutData.id,
        payment_status: "pending_payment",
      })
      .eq("id", requestId);

    if (updateError) {
      console.error("Failed to update request:", updateError);
    }

    // 8. Return checkout URL to client
    return new Response(
      JSON.stringify({
        success: true,
        checkoutUrl: checkoutData.checkout_url,
        checkoutId: checkoutData.id,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Error creating payment:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
