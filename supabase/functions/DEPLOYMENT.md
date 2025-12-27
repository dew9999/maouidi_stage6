# 🚀 Quick Deployment Guide

## Step 1: Install Supabase CLI (if not installed)

```bash
npm install -g supabase
```

## Step 2: Login & Link

```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref <your-project-ref>
```

> **Finding your project ref**: Go to Supabase Dashboard → Settings → General →
> Project Settings → Reference ID

## Step 3: Set Environment Variables

```bash
# Your Supabase URL (from Dashboard → Settings → API)
supabase secrets set SUPABASE_URL=https://xxxxx.supabase.co

# Service role key (from Dashboard → Settings → API → service_role secret)
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=eyJhbG...

# Your app URL (where Flutter app is hosted)
supabase secrets set APP_URL=https://your-app.com
```

> **Note**: We don't need a separate `CHARGILY_WEBHOOK_SECRET` because Chargily
> uses the API secret key itself for signature verification.

## Step 4: Deploy Functions

```bash
cd "c:\maouidi 22\maouidi"

# Deploy all functions
supabase functions deploy create-payment
supabase functions deploy handle-webhook
supabase functions deploy process-refund
```

## Step 5: Configure Chargily Webhook

1. Go to [Chargily Pay Dashboard](https://pay.chargily.net)
2. Navigate to **Developers Corner** → **Webhooks**
3. Add a new webhook endpoint:
   ```
   https://xxxxx.supabase.co/functions/v1/handle-webhook
   ```
   (Replace `xxxxx` with your project ref)
4. Enable the event: **checkout.paid**
5. Save it

> **Signature Verification**: The webhook handler automatically verifies
> signatures using your Chargily secret key from the database (secure!).

## Step 6: Test Edge Functions

### Test create-payment

```bash
curl -i --location --request POST 'https://xxxxx.supabase.co/functions/v1/create-payment' \
  --header 'Authorization: Bearer <YOUR_ANON_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{
    "requestId": "test-request-id"
  }'
```

### Test process-refund

```bash
curl -i --location --request POST 'https://xxxxx.supabase.co/functions/v1/process-refund' \
  --header 'Authorization: Bearer <YOUR_ANON_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{
    "requestId": "test-request-id",
    "cancelledBy": "partner",
    "cancellationReason": "Test refund"
  }'
```

## Step 7: Verify Deployment

Check function logs:

```bash
supabase functions logs create-payment --tail
supabase functions logs handle-webhook --tail
supabase functions logs process-refund --tail
```

## Troubleshooting

### Error: "Failed to fetch Chargily secret key"

- Verify `app_config` table has the keys
- Run: `SELECT key, is_secret FROM app_config;`
- Ensure `chargily_secret_key` has `is_secret = true`

### Error: "SUPABASE_URL is not set"

- Re-run: `supabase secrets set SUPABASE_URL=https://xxxxx.supabase.co`
- List secrets: `supabase secrets list`

### Error: "Invalid webhook signature"

- Check that your Chargily secret key in `app_config` is correct
- Verify you're using the correct mode (test vs production)
- Check logs: `supabase functions logs handle-webhook`

## Production Checklist

Before going live:

- [ ] Switch to production Chargily keys
  ```sql
  SELECT switch_to_production_keys(
    'prod_pk_xxxxx',
    'prod_sk_xxxxx'
  );
  ```
- [ ] Update `APP_URL` to production domain
- [ ] Verify webhook URL in Chargily dashboard
- [ ] Test payment flow end-to-end
- [ ] Monitor function logs for errors

## Next Steps

After deployment:

1. **Test the payment flow** in your Flutter app
2. Verify receipts are generated
3. Test refund scenarios
4. Enable partner payout schedules
5. Monitor Edge Function logs daily

## Local Testing with ngrok

To test webhooks locally:

```bash
# Install ngrok
npm install -g ngrok

# Start local Supabase
supabase start

# Expose local function
ngrok http 54321

# Use ngrok URL in Chargily dashboard
https://xxxx.ngrok.io/functions/v1/handle-webhook
```

---

**Need Help?**

- Supabase Docs: https://supabase.com/docs/guides/functions
- Chargily Docs: https://dev.chargily.com
