// lib/core/router/router_provider.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/auth_state_provider.dart';
import '../../index.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/terms_of_service_page.dart';
import '../../search/search_results_page.dart';
import '../../core/layouts/main_layout.dart';
import '../../features/homecare_negotiation/presentation/negotiation_screen.dart';
import '../../features/payments/presentation/payment_screen.dart';

part 'router_provider.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _GoRouterRefreshNotifier(authState),
    redirect: (context, state) async {
      final path = state.uri.path;

      // Get current user synchronously to avoid redirect loops during stream loading
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;

      final publicRoutes = [
        '/welcomeScreen',
        '/login',
        '/create',
        '/forgotPassword',
        '/privacyPolicy',
        '/termsOfService',
        '/verifyEmail', // Allow access to verify email page
      ];

      // 0. Redirect from initial route based on auth status
      if (path == '/') {
        return isLoggedIn ? '/home' : '/welcomeScreen';
      }

      // 1. Block unauthenticated users from protected routes
      if (!isLoggedIn && !publicRoutes.contains(path)) {
        return '/welcomeScreen';
      }

      // 2. Check if email needs verification FIRST (before other redirects)
      if (isLoggedIn &&
          user.emailConfirmedAt == null &&
          path != '/verifyEmail') {
        return '/verifyEmail';
      }

      // 3. Redirect authenticated users with VERIFIED emails away from auth screens
      if (isLoggedIn &&
          user.emailConfirmedAt != null &&
          (path == '/login' || path == '/welcomeScreen' || path == '/create')) {
        return '/home';
      }

      return null;
    },
    errorBuilder: (context, state) => const WelcomeScreenWidget(),
    routes: [
      GoRoute(
        name: '_initialize',
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        name: 'WelcomeScreen',
        path: '/welcomeScreen',
        builder: (context, state) => const WelcomeScreenWidget(),
      ),
      GoRoute(
        name: 'Login',
        path: '/login',
        builder: (context, state) => const LoginWidget(),
      ),
      GoRoute(
        name: 'Create',
        path: '/create',
        builder: (context, state) => const CreateWidget(),
      ),
      GoRoute(
        name: 'ForgotPassword',
        path: '/forgotPassword',
        builder: (context, state) => const ForgotPasswordWidget(),
      ),
      GoRoute(
        name: 'VerifyEmail',
        path: '/verifyEmail',
        builder: (context, state) => const VerifyEmailWidget(),
      ),
      GoRoute(
        name: 'CompleteProfile',
        path: '/completeProfile',
        builder: (context, state) {
          final isEditing = state.uri.queryParameters['isEditing'] == 'true';
          return CompleteProfileWidget(isEditing: isEditing);
        },
      ),
      GoRoute(
        name: 'PrivacyPolicyPage',
        path: '/privacyPolicy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        name: 'TermsOfServicePage',
        path: '/termsOfService',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        name: 'HomePage',
        path: '/home',
        builder: (context, state) => const MainLayout(initialPageIndex: 0),
      ),
      GoRoute(
        name: 'user_profile',
        path: '/userProfile',
        builder: (context, state) => const UserProfileWidget(),
      ),
      GoRoute(
        name: 'PartnerListPage',
        path: '/partnerListPage',
        builder: (context, state) => PartnerListPageWidget(
          categoryName: state.uri.queryParameters['categoryName'],
        ),
      ),
      GoRoute(
        name: 'PartnerProfilePage',
        path: '/partnerProfilePage',
        builder: (context, state) => PartnerProfilePageWidget(
          partnerId: state.uri.queryParameters['partnerId'],
        ),
      ),
      GoRoute(
        name: 'BookingPage',
        path: '/bookingPage',
        builder: (context, state) => BookingPageWidget(
          partnerId: state.uri.queryParameters['partnerId']!,
          isPartnerBooking:
              state.uri.queryParameters['isPartnerBooking'] == 'true',
        ),
      ),
      GoRoute(
        name: 'PatientDashboard',
        path: '/patientDashboard',
        builder: (context, state) => const MainLayout(initialPageIndex: 1),
      ),
      GoRoute(
        name: 'PartnerDashboardPage',
        path: '/partnerDashboardPage',
        builder: (context, state) => PartnerDashboardPageWidget(
          partnerId: state.uri.queryParameters['partnerId']!,
        ),
      ),
      GoRoute(
        name: 'SettingsPage',
        path: '/settingsPage',
        builder: (context, state) => const MainLayout(initialPageIndex: 2),
      ),
      GoRoute(
        name: 'SearchResultsPage',
        path: '/searchResults',
        builder: (context, state) => SearchResultsPage(
          searchTerm: state.uri.queryParameters['searchTerm']!,
        ),
      ),
      GoRoute(
        name: 'NegotiationScreen',
        path: '/negotiation',
        builder: (context, state) => NegotiationScreen(
          requestId: state.uri.queryParameters['requestId']!,
          userRole: state.uri.queryParameters['userRole'] ?? 'patient',
        ),
      ),
      GoRoute(
        name: 'PaymentScreen',
        path: '/payment',
        builder: (context, state) {
          final requestId = state.uri.queryParameters['requestId']!;
          final negotiatedPrice = double.parse(
            state.uri.queryParameters['negotiatedPrice'] ?? '0',
          );
          final platformFee = double.parse(
            state.uri.queryParameters['platformFee'] ?? '500',
          );
          return PaymentScreen(
            requestId: requestId,
            negotiatedPrice: negotiatedPrice,
            platformFee: platformFee,
          );
        },
      ),
      // Deep Link: Chargily Payment Success
      GoRoute(
        name: 'PaymentSuccess',
        path: '/payment-success',
        builder: (context, state) {
          final transactionId = state.uri.queryParameters['transaction_id'];
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text('Payment Successful!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 8),
                  Text('Transaction ID: ${transactionId ?? "N/A"}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Return to Home'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Deep Link: Chargily Payment Failure
      GoRoute(
        name: 'PaymentFailure',
        path: '/payment-failure',
        builder: (context, state) {
          final error = state.uri.queryParameters['error'];
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 80),
                  const SizedBox(height: 16),
                  const Text('Payment Failed',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 8),
                  Text('Error: ${error ?? "Unknown error"}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Return to Home'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this.authState) {
    authState.whenData((_) => notifyListeners());
  }
  final AsyncValue authState;
}
