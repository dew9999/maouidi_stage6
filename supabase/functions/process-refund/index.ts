import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RefundRequest {
  requestId: string;
  cancelledBy: "patient" | "partner";
  cancellationReason: string;
}

interface RefundEligibility {
  eligible: boolean;
  refundPercentage: number;
  reason: string;
}

// Calculate refund eligibility based on business rules
function calculateRefundEligibility(
  homecareRequest: any,
  cancelledBy: "patient" | "partner",
): RefundEligibility {
  const hasStarted = !!homecareRequest.service_started_at;

  // Rule 1: Partner cancels before service → 100% refund
  if (cancelledBy === "partner" && !hasStarted) {
    return {
      eligible: true,
      refundPercentage: 100,
      reason: "Partner cancelled before service started",
    };
  }

  // Rule 2: Patient cancels before service → 50% refund
  if (cancelledBy === "patient" && !hasStarted) {
    return {
      eligible: true,
      refundPercentage: 50,
      reason: "Patient cancelled before service started",
    };
  }

  // Rule 3: Patient tries to cancel after service started → NO REFUND
  if (cancelledBy === "patient" && hasStarted) {
    return {
      eligible: false,
      refundPercentage: 0,
      reason: "Service already started - no refund available",
    };
  }

  // Rule 4: Partner cancels after service started → 100% refund (partner's fault)
  if (cancelledBy === "partner" && hasStarted) {
    return {
      eligible: true,
      refundPercentage: 100,
      reason: "Partner cancelled after starting service",
    };
  }

  return {
    eligible: false,
    refundPercentage: 0,
    reason: "Refund not applicable",
  };
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Parse request
    const { requestId, cancelledBy, cancellationReason }: RefundRequest =
      await req.json();

    if (!requestId || !cancelledBy || !cancellationReason) {
      throw new Error("Missing required fields");
    }

    // 2. Create Supabase client with SERVICE ROLE
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Fetch homecare request
    const { data: homecareRequest, error: requestError } = await supabase
      .from("homecare_requests")
      .select("*")
      .eq("id", requestId)
      .single();

    if (requestError || !homecareRequest) {
      throw new Error("Homecare request not found");
    }

    // 4. Verify payment was made
    if (homecareRequest.payment_status !== "paid") {
      throw new Error("No payment to refund - payment status is not paid");
    }

    // 5. Check if already refunded
    if (homecareRequest.refund_status === "refunded") {
      throw new Error("This request has already been refunded");
    }

    // 6. Calculate refund eligibility
    const refundInfo = calculateRefundEligibility(homecareRequest, cancelledBy);

    if (!refundInfo.eligible) {
      return new Response(
        JSON.stringify({
          success: false,
          eligible: false,
          reason: refundInfo.reason,
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 7. Calculate refund amount
    const refundAmount =
      (homecareRequest.total_amount * refundInfo.refundPercentage) / 100;

    // 8. Fetch Chargily secret key
    const { data: secretConfig, error: configError } = await supabase
      .from("app_config")
      .select("value")
      .eq("key", "chargily_secret_key")
      .single();

    if (configError || !secretConfig) {
      throw new Error("Failed to fetch Chargily secret key");
    }

    const chargilySecretKey = secretConfig.value;

    // 9. Process refund via Chargily API
    const chargilyResponse = await fetch(
      `https://pay.chargily.net/test/api/v2/checkouts/${homecareRequest.chargily_checkout_id}/refund`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${chargilySecretKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          amount: refundAmount * 100, // Convert to cents
        }),
      },
    );

    if (!chargilyResponse.ok) {
      const errorText = await chargilyResponse.text();
      throw new Error(`Chargily refund failed: ${errorText}`);
    }

    const refundData = await chargilyResponse.json();

    // 10. Update homecare_request
    const { error: updateError } = await supabase
      .from("homecare_requests")
      .update({
        refund_status: "refunded",
        refund_amount: refundAmount,
        refunded_at: new Date().toISOString(),
        cancellation_reason: cancellationReason,
        status: "cancelled",
      })
      .eq("id", requestId);

    if (updateError) {
      throw new Error(`Failed to update request: ${updateError.message}`);
    }

    // 11. Update payment receipt
    const { error: receiptError } = await supabase
      .from("payment_receipts")
      .update({
        payout_status: "refunded",
      })
      .eq("homecare_request_id", requestId);

    if (receiptError) {
      console.error("Failed to update receipt:", receiptError);
    }

    // 12. Return success
    return new Response(
      JSON.stringify({
        success: true,
        eligible: true,
        refundAmount,
        refundPercentage: refundInfo.refundPercentage,
        reason: refundInfo.reason,
        chargilyRefundId: refundData.id,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Refund processing error:", error);
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
