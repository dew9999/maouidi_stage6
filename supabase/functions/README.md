# Homecare Payment System - Edge Functions

## Overview

These Edge Functions handle secure payment processing using Chargily without
exposing the secret key to the Flutter client.

## Functions

### 1. `create-payment`

**Purpose**: Creates a Chargily checkout session securely

**Request**:

```json
{
  "requestId": "uuid-of-homecare-request"
}
```

**Response**:

```json
{
  "success": true,
  "checkoutUrl": "https://pay.chargily.net/checkout/...",
  "checkoutId": "checkout_id"
}
```

**Security**: Uses service role to fetch `chargily_secret_key` from `app_config`

---

### 2. `handle-webhook`

**Purpose**: Processes Chargily payment confirmations

**Called by**: Chargily servers (webhook)

**What it does**:

- Verifies webhook signature
- Updates `payment_status` to 'paid'
- Generates payment receipt
- Records transaction ID

**Security**: Verifies HMAC signature to ensure webhook is from Chargily

---

### 3. `process-refund`

**Purpose**: Handles refund requests with smart eligibility logic

**Request**:

```json
{
  "requestId": "uuid-of-homecare-request",
  "cancelledBy": "patient" | "partner",
  "cancellationReason": "string"
}
```

**Refund Rules**:

- Partner cancels before service → **100% refund**
- Patient cancels before service → **50% refund**
- Patient cancels after service starts → **NO REFUND**
- Partner cancels after service starts → **100% refund**

**Response**:

```json
{
  "success": true,
  "eligible": true,
  "refundAmount": 3500,
  "refundPercentage": 100,
  "reason": "Partner cancelled before service started"
}
```

---

## Deployment

### 1. Install Supabase CLI

```bash
npm install -g supabase
```

### 2. Login to Supabase

```bash
supabase login
```

### 3. Link to your project

```bash
supabase link --project-ref your-project-ref
```

### 4. Set environment variables

```bash
supabase secrets set SUPABASE_URL=https://your-project.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
supabase secrets set APP_URL=https://your-app.com
supabase secrets set CHARGILY_WEBHOOK_SECRET=your-webhook-secret
```

### 5. Deploy functions

```bash
supabase functions deploy create-payment
supabase functions deploy handle-webhook
supabase functions deploy process-refund
```

---

## Testing Locally

### 1. Start local Supabase

```bash
supabase start
```

### 2. Serve functions locally

```bash
supabase functions serve create-payment --env-file .env
```

### 3. Test with curl

```bash
curl -i --location --request POST 'http://localhost:54321/functions/v1/create-payment' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"requestId":"your-request-id"}'
```

---

## Security Notes

✅ **Secret key is NEVER exposed to Flutter app**

- Only Edge Functions (with service role) can access it
- RLS policy blocks client-side access (`is_secret = true`)

✅ **Webhook signature verification**

- Prevents fake webhooks from updating payment status

✅ **Refund eligibility validation**

- Prevents abuse by checking service start time

---

## Monitoring

View function logs in Supabase dashboard:

- Go to **Edge Functions** → Select function → **Logs**

Or use CLI:

```bash
supabase functions logs create-payment
```

---

## Chargily Configuration

1. Go to Chargily Dashboard
2. Set webhook URL to:
   ```
   https://your-project.supabase.co/functions/v1/handle-webhook
   ```
3. Copy webhook secret and add to Supabase secrets
4. Enable webhook events: `checkout.paid`

---

## Troubleshooting

**Error: "Failed to fetch Chargily secret key"**

- Verify `app_config` table has the key
- Ensure RLS policies allow service role access

**Error: "Invalid webhook signature"**

- Check `CHARGILY_WEBHOOK_SECRET` matches Chargily dashboard
- Verify webhook is from Chargily servers

**Error: "Chargily API error"**

- Check if using correct mode (test vs production)
- Verify API keys are valid
- Check request payload format

---

## Production Checklist

- [ ] Switch to production Chargily keys using `switch_to_production_keys()`
- [ ] Update `APP_URL` to production domain
- [ ] Configure Chargily webhook URL
- [ ] Test payment flow end-to-end
- [ ] Monitor function logs for errors
- [ ] Set up alerts for payment failures
