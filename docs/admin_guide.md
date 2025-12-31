# Maouidi Admin Guide

## System Overview

Maouidi is a Flutter-based health booking platform using Supabase for backend
services (Auth, Database, Realtime, Storage).

## Configuration

Key configurations are stored in the `app_config` table in Supabase.

- **platform_fee_dzd**: The fixed fee added to homecare bookings (Default:
  500.0).
- **maintenance_mode**: Boolean to disable app access during updates.

## Database Schema

The system uses a unified `appointments` table for all booking types (Clinic,
Homecare, Online).

- `booking_type`: ENUM ('clinic', 'homecare', 'online')
- `status`: ENUM ('pending', 'confirmed', 'completed', 'cancelled', etc.)

### Critical Tables

- `users`: Core profile data.
- `medical_partners`: Professional details linked to users.
- `appointments`: Central booking records.
- `payment_transactions`: Logs of Chargily payments.

## Troubleshooting

### Payment Issues

- Check `payment_transactions` for failed webhook logs.
- Verify Chargily API keys in Edge Functions secrets.

### Search Issues

- Search relies on Postgres text search. If results are missing, ensure
  `medical_partners` table indexes are active.

## Deployment

- **Android**: Build AppBundle (`flutter build appbundle`).
- **iOS**: Archive via Xcode (`flutter build ipa`).
- **Web**: `flutter build web --release`.

## Monitoring

- Use Supabase Dashboard to monitor API requests and database health.
- Check Edge Function logs for backend logic errors.
