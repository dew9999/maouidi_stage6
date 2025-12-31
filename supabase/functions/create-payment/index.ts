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

    // 3b. Fetch Platform Fee
    const { data: feeConfig } = await supabase
      .from("app_config")
      .select("value")
      .eq("key", "platform_fee_dzd")
      .single();

    const platformFee = feeConfig?.value ? Number(feeConfig.value) : 500;

    // 4. Fetch appointment details (Consolidated Table)
    const { data: appointment, error: requestError } = await supabase
      .from("appointments")
      .select("id, booking_user_id, partner_id, negotiated_price")
      .eq("id", requestId)
      .single();

    if (requestError || !appointment) {
      console.error("Appointment fetch error:", requestError);
      throw new Error("Appointment not found");
    }

    const negotiatedPrice = Number(appointment.negotiated_price) || 0;
    const totalAmount = negotiatedPrice + platformFee;

    // 5. Fetch patient details for Chargily
    const { data: patient, error: patientError } = await supabase
      .from("users")
      .select("email, display_name, phone_number")
      .eq("id", appointment.booking_user_id)
      .single();

    if (patientError || !patient) {
      console.warn(
        `Patient not found for ID: ${appointment.booking_user_id}. Using fallback.`,
      );
      // Fallback for testing/integrity issues
      // Reuse 'patient' variable name logic or reassign
    }

    const customerName = patient?.display_name || "Guest Patient";
    const customerEmail = patient?.email || "guest@maouidi.com";
    const customerPhone = patient?.phone_number || "0550000000";

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
          amount: totalAmount,
          currency: "dzd",
          success_url: `${
            Deno.env.get("APP_URL") ?? "https://maouidi.com"
          }/payment-success?request_id=${requestId}`,
          failure_url: `${
            Deno.env.get("APP_URL") ?? "https://maouidi.com"
          }/payment-failed?request_id=${requestId}`,
          metadata: {
            request_id: requestId,
            patient_id: appointment.booking_user_id,
            partner_id: appointment.partner_id,
          },
          description:
            `Homecare Service Payment - ${negotiatedPrice} DZD + Fees`,
        }),
      },
    );

    if (!chargilyResponse.ok) {
      const errorText = await chargilyResponse.text();
      throw new Error(`Chargily API error: ${errorText}`);
    }

    const checkoutData: ChargilyCheckoutResponse = await chargilyResponse
      .json();

    // 7. Update appointment with checkout_id
    // Note: Ensure columns exist in 'appointments' table
    const { error: updateError } = await supabase
      .from("appointments")
      .update({
        // chargily_checkout_id: checkoutData.id, // Uncomment if column added
        // payment_status: "pending_payment", // Uncomment if column added
        // For now, we trust the checkout link is generated.
        status: "pending_payment", // Ensure status reflects this
      })
      .eq("id", requestId);

    if (updateError) {
      console.error("Failed to update appointment status:", updateError);
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
