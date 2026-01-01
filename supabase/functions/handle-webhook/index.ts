import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface ChargilyWebhook {
  id: string;
  entity: string;
  livemode: string;
  type: string;
  data: {
    id: string;
    entity: string;
    status: string;
    amount: number;
    metadata?: Record<string, any>;
  };
  created_at: number;
  updated_at: number;
}

// Generate receipt number
function generateReceiptNumber(): string {
  const year = new Date().getFullYear();
  const random = Math.floor(Math.random() * 99999) + 1;
  return `HC-${year}-${random.toString().padStart(5, "0")}`;
}

serve(async (req) => {
  try {
    // 1. Get signature header and raw body
    const signature = req.headers.get("signature");
    const rawBody = await req.text();

    // 2. Create Supabase client to fetch secret key
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Fetch Chargily secret key for signature verification
    const { data: secretConfig, error: configError } = await supabase
      .from("app_config")
      .select("value")
      .eq("key", "chargily_secret_key")
      .single();

    if (configError || !secretConfig) {
      throw new Error("Failed to fetch Chargily secret key");
    }

    const chargilySecretKey = secretConfig.value;

    // 4. Verify webhook signature using HMAC-SHA256
    // Per Chargily docs: signature = HMAC-SHA256(payload, secret_key)
    if (signature) {
      const encoder = new TextEncoder();
      const keyData = encoder.encode(chargilySecretKey);
      const messageData = encoder.encode(rawBody);

      const cryptoKey = await crypto.subtle.importKey(
        "raw",
        keyData,
        { name: "HMAC", hash: "SHA-256" },
        false,
        ["sign"],
      );

      const signatureBuffer = await crypto.subtle.sign(
        "HMAC",
        cryptoKey,
        messageData,
      );

      // Convert to hex string
      const computedSignature = Array.from(new Uint8Array(signatureBuffer))
        .map((b) => b.toString(16).padStart(2, "0"))
        .join("");

      if (signature !== computedSignature) {
        console.error("Signature mismatch:", {
          received: signature,
          computed: computedSignature,
        });
        throw new Error("Invalid webhook signature");
      }

      console.log("✅ Webhook signature verified");
    } else {
      console.warn(
        "⚠️ No signature header - accepting webhook anyway (not recommended for production)",
      );
    }

    // 5. Parse webhook payload
    const webhookData: ChargilyWebhook = JSON.parse(rawBody);
    console.log("Webhook received:", webhookData.type);

    // 6. Only process successful payments
    if (webhookData.type !== "checkout.paid") {
      console.log(`Ignoring event type: ${webhookData.type}`);
      return new Response(JSON.stringify({ received: true }), { status: 200 });
    }

    // 7. Extract request_id from metadata
    const requestId = webhookData.data.metadata?.request_id;
    if (!requestId) {
      throw new Error("No request_id in webhook metadata");
    }

    console.log(`Processing payment for request: ${requestId}`);

    // 8. Fetch request details
    const { data: appointment, error: requestError } = await supabase
      .from("appointments")
      .select("*")
      .eq("id", requestId)
      .single();

    if (requestError || !appointment) {
      throw new Error("Appointment not found");
    }

    // 9. Calculate totals (moved up for use in update)
    const platformFee = 500;
    const servicePrice = appointment.negotiated_price || appointment.price || 0;
    const totalPaid = servicePrice + platformFee;

    // 10. Update payment status & amount_paid
    const { error: updateError } = await supabase
      .from("appointments")
      .update({
        status: "Confirmed",
        amount_paid: totalPaid, // Store the actual amount paid
      })
      .eq("id", requestId);

    if (updateError) {
      throw new Error(
        `Failed to update payment status: ${updateError.message}`,
      );
    }

    // 10. Generate payment receipt
    // Check if 'payment_receipts' table exists and has 'appointment_id'
    // For safety, we wrap this in try-catch-log because if it fails, we don't want to fail the webhook (since payment is confirmed)
    let receiptNumber: string | null = null;
    try {
      receiptNumber = generateReceiptNumber();
      const platformFee = 500; // Should fetch from config or appointment if stored
      const servicePrice = appointment.negotiated_price || 0;
      const totalPaid = servicePrice + platformFee;

      const { error: receiptError } = await supabase
        .from("payment_receipts")
        .insert({
          appointment_id: requestId, // Ensure this column exists in SQL
          patient_id: appointment.booking_user_id,
          partner_id: appointment.partner_id,
          service_price: servicePrice,
          platform_fee: platformFee,
          total_paid: totalPaid,
          partner_amount: servicePrice,
          receipt_number: receiptNumber,
          payout_status: "pending",
        });

      if (receiptError) {
        console.error("Failed to create receipt:", receiptError);
      } else {
        console.log(
          `✅ Payment processed successfully - Receipt: ${receiptNumber}`,
        );
      }
    } catch (e) {
      console.error("Receipt creation error:", e);
    }

    // 11. Respond with 200 OK (required by Chargily)
    // We already do this below, but good to log success

    // 11. Respond with 200 OK (required by Chargily)
    return new Response(
      JSON.stringify({
        success: true,
        message: "Payment processed",
        receipt_number: receiptNumber,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ Webhook processing error:", error);

    // Still return 200 to prevent Chargily from retrying
    // (Log the error for debugging but don't expose details)
    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});
