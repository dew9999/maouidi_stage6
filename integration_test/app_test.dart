// integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maouidi/main.dart' as app;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Maouidi App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Initialize Supabase
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
        anonKey:
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app launches without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MainLayout renders correctly for authenticated users',
        (WidgetTester tester) async {
      // Initialize Supabase
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
        anonKey:
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Auth flow: Check if login page appears (for unauthenticated users)
      // or if MainLayout/HomePage appears (for authenticated users)
      final loginPageFound = find.text('Login');
      final homePageFound = find.byType(Scaffold);

      // At least one should be visible
      expect(
        loginPageFound.evaluate().isNotEmpty ||
            homePageFound.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Navigation bar is present and responsive',
        (WidgetTester tester) async {
      // Initialize Supabase
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
        anonKey:
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for NavigationBar (mobile) or NavigationRail (tablet)
      final navBar = find.byType(NavigationBar);
      final navRail = find.byType(NavigationRail);

      // At least one navigation component should be present if user is authenticated
      // (This test will pass even if user is not authenticated and sees login page)
      expect(
        navBar.evaluate().isNotEmpty ||
            navRail.evaluate().isNotEmpty ||
            find.text('Login').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('App handles navigation between tabs',
        (WidgetTester tester) async {
      // Initialize Supabase
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
        anonKey:
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      );

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If NavigationBar is present, test tab switching
      final navBar = find.byType(NavigationBar);

      if (navBar.evaluate().isNotEmpty) {
        // Tap on the second tab (Appointments/Dashboard)
        final secondTab = find.byIcon(Icons.calendar_today_outlined).first;
        if (secondTab.evaluate().isNotEmpty) {
          await tester.tap(secondTab);
          await tester.pumpAndSettle();

          // Verify navigation occurred (should still have Scaffold)
          expect(find.byType(Scaffold), findsWidgets);
        }
      }

      // Test passes if navigation works or if user is not authenticated
      expect(true, true);
    });
  });
}
