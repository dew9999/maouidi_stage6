// lib/ui/verify_email/verify_email_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Riverpod providers for email verification state
final _isResendingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _resendCooldownProvider = StateProvider.autoDispose<int>((ref) => 0);

class VerifyEmailWidget extends ConsumerStatefulWidget {
  const VerifyEmailWidget({super.key});

  static String routeName = 'VerifyEmail';
  static String routePath = '/verifyEmail';

  @override
  ConsumerState<VerifyEmailWidget> createState() => _VerifyEmailWidgetState();
}

class _VerifyEmailWidgetState extends ConsumerState<VerifyEmailWidget> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Refresh the user session
      await Supabase.instance.client.auth.refreshSession();

      final refreshedUser = Supabase.instance.client.auth.currentUser;
      if (refreshedUser?.emailConfirmedAt != null && mounted) {
        _pollTimer?.cancel();

        // Email is verified, now create the user record in database
        try {
          final metadata = refreshedUser!.userMetadata;
          await Supabase.instance.client.from('users').insert({
            'id': refreshedUser.id,
            'email': refreshedUser.email,
            'first_name': metadata?['first_name'],
            'last_name': metadata?['last_name'],
            'phone': metadata?['phone'],
            'date_of_birth': metadata?['date_of_birth'],
            'gender': metadata?['gender'],
            'wilaya': metadata?['wilaya'],
            'terms_validated_at': metadata?['terms_validated_at'],
          });
        } catch (e) {
          // If insert fails (maybe user already exists), continue anyway
          print('User record creation error: $e');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      // Continue polling on error
    }
  }

  Future<void> _resendVerificationEmail() async {
    final cooldown = ref.read(_resendCooldownProvider);
    final isResending = ref.read(_isResendingProvider);

    if (cooldown > 0 || isResending) return;

    ref.read(_isResendingProvider.notifier).state = true;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: user.email!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent!'),
            backgroundColor: Colors.green,
          ),
        );

        // Start 60 second cooldown
        ref.read(_resendCooldownProvider.notifier).state = 60;
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final currentCooldown = ref.read(_resendCooldownProvider);
          if (currentCooldown > 0) {
            ref.read(_resendCooldownProvider.notifier).state =
                currentCooldown - 1;
          } else {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      ref.read(_isResendingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = Supabase.instance.client.auth.currentUser;

    final isResending = ref.watch(_isResendingProvider);
    final resendCooldown = ref.watch(_resendCooldownProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              context.go('/welcomeScreen');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 100,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Email',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification email to:',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Click the link in the email to verify your account.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The page will automatically continue once you verify.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Resend button
                FilledButton(
                  onPressed: (resendCooldown > 0 || isResending)
                      ? null
                      : _resendVerificationEmail,
                  child: isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          resendCooldown > 0
                              ? 'Resend in $resendCooldown s'
                              : 'Resend Email',
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Didn\'t receive the email? Check your spam folder.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
