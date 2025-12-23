// lib/core/router/router_provider.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/auth_state_provider.dart';
import '../../features/auth/presentation/user_role_provider.dart';
import '../../index.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/terms_of_service_page.dart';
import '../../search/search_results_page.dart';
import '../../core/layouts/main_layout.dart';

part 'router_provider.g.dart';

/// Riverpod-managed GoRouter with auth guards and role-based redirects.
///
/// Features:
/// - Automatically redirects unauthenticated users to /welcomeScreen
/// - Prevents authenticated users from accessing login screens
/// - Redirects authenticated users to appropriate dashboard based on role
@riverpod
GoRouter router(RouterRef ref) {
  // Watch auth state for automatic route refreshing
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _GoRouterRefreshNotifier(authState),
    redirect: (context, state) async {
      final path = state.uri.path;

      // Wait for auth state to load
      final user = authState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      final isLoggedIn = user != null;

      // Public routes (accessible without authentication)
      final publicRoutes = [
        '/welcomeScreen',
        '/login',
        '/create',
        '/forgotPassword',
        '/privacyPolicy',
        '/termsOfService',
      ];

      // If user is not logged in and trying to access protected route
      if (!isLoggedIn && !publicRoutes.contains(path)) {
        return '/welcomeScreen';
      }

      // If user is logged in and trying to access login/welcome screens
      if (isLoggedIn &&
          (path == '/login' || path == '/welcomeScreen' || path == '/create')) {
        // Get user role to determine redirect destination
        final role = await ref.read(userRoleProvider.future);

        // Redirect to appropriate dashboard based on role
        if (role == 'Medical Partner') {
          return '/homePage'; // Partners see the Partner Hub
        } else {
          return '/homePage'; // Patients see the Patient Hub
        }
      }

      return null; // No redirect needed
    },
    errorBuilder: (context, state) => const WelcomeScreenWidget(),
    routes: [
      GoRoute(
        name: '_initialize',
        path: '/',
        builder: (context, state) {
          // Initial route - let redirect handle the logic
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),

      // Public Routes
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
        name: 'PrivacyPolicyPage',
        path: '/privacyPolicy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        name: 'TermsOfServicePage',
        path: '/termsOfService',
        builder: (context, state) => const TermsOfServicePage(),
      ),

      // Protected Routes (require authentication)
      GoRoute(
        name: 'HomePage',
        path: '/homePage',
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
    ],
  );
}

/// Helper class to refresh GoRouter when auth state changes
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this.authState) {
    authState.whenData((_) => notifyListeners());
  }

  final AsyncValue authState;
}
