# Delete User Edge Function

This Supabase Edge Function handles user account deletion using the Admin API.

## Deployment

### Using Supabase CLI

```bash
supabase functions deploy delete-user
```

### Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to Edge Functions
3. Click "New Function"
4. Name it `delete-user`
5. Copy the contents of `index.ts` into the editor
6. Deploy

## Testing

```bash
curl -X POST https://your-project.supabase.co/functions/v1/delete-user \
  -H "Authorization: Bearer YOUR_USER_JWT" \
  -H "Content-Type: application/json"
```

## Environment Variables Required

- `SUPABASE_URL`: Automatically provided
- `SUPABASE_ANON_KEY`: Automatically provided
- `SUPABASE_SERVICE_ROLE_KEY`: Must be set in your project settings

## How It Works

1. Validates user JWT from Authorization header
2. Uses Admin API with service role key to delete user
3. Deletion cascades from `auth.users` to `public.users`
4. Returns success/error response

## Security

- Requires valid user JWT
- Only deletes the authenticated user's own account
- Uses service role key securely on server side
