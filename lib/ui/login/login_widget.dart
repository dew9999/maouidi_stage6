// lib/ui/login/login_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Riverpod providers for state management
final _loginLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _passwordVisibilityProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class LoginWidget extends ConsumerStatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
  ) async {
    // Trim and validate inputs
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmedEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    ref.read(_loginLoadingProvider.notifier).state = true;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      // Login successful
      final user = response.user;
      if (user != null) {
        // Check if email is verified
        if (user.emailConfirmedAt == null) {
          // Email not verified, redirect to verification page
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please verify your email first. Check your inbox for the verification link.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
            context.go('/verifyEmail');
          }
        } else {
          // Email verified! Create user record in database if it doesn't exist
          try {
            // Try to create user record (will fail silently if already exists)
            final metadata = user.userMetadata;

            // Validate metadata exists before inserting
            if (metadata == null || metadata.isEmpty) {
              debugPrint('Warning: User metadata is empty');
            }

            await Supabase.instance.client.from('users').insert({
              'id': user.id,
              'email': user.email,
              'first_name': metadata?['first_name'],
              'last_name': metadata?['last_name'],
              'phone': metadata?['phone'],
              'date_of_birth': metadata?['date_of_birth'],
              'gender': metadata?['gender'],
              'wilaya': metadata?['wilaya'],
              'terms_validated_at': metadata?['terms_validated_at'],
            });
            debugPrint('User record created on first login');
          } catch (e) {
            // User record already exists or creation failed - that's okay, continue
            debugPrint(
                'User record creation skipped (might already exist): $e',);
          }

          // Navigate to home
          if (context.mounted) {
            context.go('/home');
          }
        }
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        // Provide more user-friendly error messages
        String errorMessage = e.message;

        // Customize common error messages
        if (e.message.toLowerCase().contains('invalid login credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.message.toLowerCase().contains('email not confirmed')) {
          errorMessage = 'Please verify your email before logging in.';
        } else if (e.message.toLowerCase().contains('too many requests')) {
          errorMessage =
              'Too many login attempts. Please wait a moment and try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (ref.context.mounted) {
        ref.read(_loginLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = ref.watch(_loginLoadingProvider);
    final passwordVisible = ref.watch(_passwordVisibilityProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
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
                  controller: _emailController,
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
                  controller: _passwordController,
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
                            _emailController.text.trim(),
                            _passwordController.text,
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
