// lib/core/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/auth/presentation/user_role_provider.dart';
import '/core/providers/screen_utils_provider.dart';
import '/index.dart';
import '/auth/supabase_auth/auth_util.dart';

// Riverpod provider for navigation index
final _navIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Main Navigation Layout - Pure Flutter + Riverpod Implementation
///
/// Replaces the legacy NavBarPage with:
/// - Material 3 NavigationBar for mobile
/// - Material 3 NavigationRail for tablet/desktop
/// - Role-based tab visibility (Medical Partner vs Patient)
/// - NO FlutterFlow dependencies
/// - NO setState - uses Riverpod StateProvider
class MainLayout extends ConsumerWidget {
  const MainLayout({
    super.key,
    this.initialPageIndex = 0,
  });

  final int initialPageIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRoleAsync = ref.watch(userRoleProvider);
    final screenUtils = ScreenUtils(context);

    // Initialize index on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(_navIndexProvider) == 0 && initialPageIndex != 0) {
        ref.read(_navIndexProvider.notifier).state = initialPageIndex;
      }
    });

    return userRoleAsync.when(
      data: (userRole) {
        // Define tabs based on user role
        final NavigationConfig config = _getNavigationConfig(userRole);

        final currentIndex = ref.watch(_navIndexProvider);

        // Ensure current index is valid
        final safeIndex =
            currentIndex >= config.pages.length ? 0 : currentIndex;
        if (safeIndex != currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(_navIndexProvider.notifier).state = safeIndex;
          });
        }

        final currentPage = config.pages[safeIndex];

        // Adaptive Layout: NavigationRail for tablets, NavigationBar for phones
        if (screenUtils.isMedium || screenUtils.isExpanded) {
          return _buildTabletLayout(theme, config, currentPage, safeIndex, ref);
        } else {
          return _buildMobileLayout(theme, config, currentPage, safeIndex, ref);
        }
      },
      loading: () => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Text(
            'Error loading navigation',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  /// Build tablet/desktop layout with NavigationRail
  Widget _buildTabletLayout(
    ThemeData theme,
    NavigationConfig config,
    Widget currentPage,
    int currentIndex,
    WidgetRef ref,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(_navIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.selected,
            backgroundColor: theme.colorScheme.surface,
            destinations: config.tabs
                .map(
                  (tab) => NavigationRailDestination(
                    icon: Icon(tab.icon),
                    label: Text(tab.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: currentPage),
        ],
      ),
    );
  }

  /// Build mobile layout with NavigationBar
  Widget _buildMobileLayout(
    ThemeData theme,
    NavigationConfig config,
    Widget currentPage,
    int currentIndex,
    WidgetRef ref,
  ) {
    return Scaffold(
      body: currentPage,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(_navIndexProvider.notifier).state = index;
        },
        destinations: config.tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Get navigation configuration based on user role
  NavigationConfig _getNavigationConfig(String? userRole) {
    if (userRole == 'Medical Partner') {
      return NavigationConfig(
        tabs: const [
          NavTab(icon: Icons.home_outlined, label: 'Home'),
          NavTab(icon: Icons.dashboard_outlined, label: 'Dashboard'),
          NavTab(icon: Icons.settings_outlined, label: 'Settings'),
        ],
        pages: [
          const HomePageWidget(),
          PartnerDashboardPageWidget(partnerId: currentUserId),
          const SettingsPageWidget(),
        ],
      );
    } else {
      // Patient role (default)
      return const NavigationConfig(
        tabs: [
          NavTab(icon: Icons.home_outlined, label: 'Home'),
          NavTab(icon: Icons.calendar_today_outlined, label: 'Appointments'),
          NavTab(icon: Icons.settings_outlined, label: 'Settings'),
        ],
        pages: [
          HomePageWidget(),
          PatientDashboardWidget(),
          SettingsPageWidget(),
        ],
      );
    }
  }
}

/// Navigation configuration data class
class NavigationConfig {
  const NavigationConfig({
    required this.tabs,
    required this.pages,
  });

  final List<NavTab> tabs;
  final List<Widget> pages;
}

/// Navigation tab data class
class NavTab {
  const NavTab({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
