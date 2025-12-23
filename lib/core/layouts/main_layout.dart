// lib/core/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/auth/presentation/user_role_provider.dart';
import '/core/providers/screen_utils_provider.dart';
import '/index.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Main Navigation Layout - Pure Flutter + Riverpod Implementation
///
/// Replaces the legacy NavBarPage with:
/// - Material 3 NavigationBar for mobile
/// - Material 3 NavigationRail for tablet/desktop
/// - Role-based tab visibility (Medical Partner vs Patient)
/// - NO FlutterFlow dependencies
/// - NO GNav dependency
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({
    super.key,
    this.initialPageIndex = 0,
  });

  final int initialPageIndex;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRoleAsync = ref.watch(userRoleProvider);
    final screenUtils = ScreenUtils(context);

    return userRoleAsync.when(
      data: (userRole) {
        // Define tabs based on user role
        final NavigationConfig config = _getNavigationConfig(userRole);

        // Ensure current index is valid
        if (_currentIndex >= config.pages.length) {
          _currentIndex = 0;
        }

        final currentPage = config.pages[_currentIndex];

        // Adaptive Layout: NavigationRail for tablets, NavigationBar for phones
        if (screenUtils.isMedium || screenUtils.isExpanded) {
          return _buildTabletLayout(theme, config, currentPage);
        } else {
          return _buildMobileLayout(theme, config, currentPage);
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
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
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
  ) {
    return Scaffold(
      body: currentPage,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
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
