// lib/core/router/router_provider.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/auth_state_provider.dart';
// REMOVED: import '../../features/auth/presentation/user_role_provider.dart';
import '../../index.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/terms_of_service_page.dart';
import '../../search/search_results_page.dart';
import '../../core/layouts/main_layout.dart';

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

      final user = authState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      final isLoggedIn = user != null;

      final publicRoutes = [
        '/welcomeScreen',
        '/login',
        '/create',
        '/forgotPassword',
        '/privacyPolicy',
        '/termsOfService',
      ];

      // 1. Block unauthenticated users
      if (!isLoggedIn && !publicRoutes.contains(path)) {
        return '/welcomeScreen';
      }

      // 2. Redirect authenticated users AWAY from login screens
      if (isLoggedIn &&
          (path == '/login' || path == '/welcomeScreen' || path == '/create')) {
        // FIX: Immediate redirect to Home Page (No DB waiting)
        return '/homePage';
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

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this.authState) {
    authState.whenData((_) => notifyListeners());
  }
  final AsyncValue authState;
}
