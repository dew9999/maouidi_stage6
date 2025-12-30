import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Riverpod provider for loading state
final _resetLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class ForgotPasswordWidget extends ConsumerWidget {
  const ForgotPasswordWidget({super.key});

  static String routeName = 'ForgotPassword';
  static String routePath = '/forgotPassword';

  Future<void> _handleResetPassword(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    ref.read(_resetLoadingProvider.notifier).state = true;

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        // Enhanced error messaging for debugging
        final errorMessage = e is AuthException
            ? 'Auth Error: ${e.message}'
            : 'Error: ${e.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      ref.read(_resetLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = ref.watch(_resetLoadingProvider);

    final emailController = TextEditingController();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          automaticallyImplyLeading: true,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
              size: 24.0,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Forgot Password',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Enter your email address and we will send you a link to reset your password.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24.0),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => _handleResetPassword(
                            context,
                            ref,
                            emailController.text.trim(),
                          ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor:
                        colorScheme.primary.withOpacity(0.5),
                    textStyle: textTheme.titleSmall,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(isLoading ? 'Sending...' : 'Send Reset Link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
