// lib/ui/login/login_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Riverpod providers for state management
final _loginLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _passwordVisibilityProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class LoginWidget extends ConsumerWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    ref.read(_loginLoadingProvider.notifier).state = true;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Login successful
      final user = response.user;
      if (user != null) {
        // Check if email is verified
        if (user.emailConfirmedAt == null) {
          // Email not verified, redirect to verification page
          if (context.mounted) {
            context.go('/verifyEmail');
          }
        } else {
          // Email verified navigation to home
          if (context.mounted) {
            context.go('/home');
          }
        }
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      ref.read(_loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = ref.watch(_loginLoadingProvider);
    final passwordVisible = ref.watch(_passwordVisibilityProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email...',
                    labelStyle: textTheme.bodyMedium,
                    hintStyle: textTheme.bodyMedium,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  style: textTheme.bodyMedium,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password...',
                    labelStyle: textTheme.bodyMedium,
                    hintStyle: textTheme.bodyMedium,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    suffixIcon: InkWell(
                      onTap: () => ref
                          .read(_passwordVisibilityProvider.notifier)
                          .state = !passwordVisible,
                      focusNode: FocusNode(skipTraversal: true),
                      child: Icon(
                        passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 22.0,
                      ),
                    ),
                  ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24.0),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => _handleLogin(
                            context,
                            ref,
                            emailController.text.trim(),
                            passwordController.text,
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
                  child: Text(isLoading ? 'Signing In...' : 'Sign In'),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: textTheme.bodyMedium,
                    ),
                    InkWell(
                      onTap: () => context.pushNamed('Create'),
                      child: Text(
                        'Sign Up',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.pushNamed('ForgotPassword'),
                  child: Text(
                    'Forgot Password?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
