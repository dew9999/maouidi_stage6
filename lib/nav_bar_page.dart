// lib/nav_bar_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '/features/auth/presentation/user_role_provider.dart';
import '/core/providers/screen_utils_provider.dart';
import '/index.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Adaptive Navigation Shell
///
/// Provides:
/// - BottomNavigationBar (GNav) for phones (compact)
/// - NavigationRail for tablets/foldables (medium/expanded)
/// - Role-based tab visibility (Patient vs Medical Partner)
class NavBarPage extends ConsumerStatefulWidget {
  const NavBarPage({
    super.key,
    this.initialPage,
    this.page,
  });

  final String? initialPage;
  final Widget? page;

  @override
  ConsumerState<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends ConsumerState<NavBarPage> {
  String _currentPageName = 'HomePage';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRoleAsync = ref.watch(userRoleProvider);
    final screenUtils = ScreenUtils(context);

    return userRoleAsync.when(
      data: (userRole) {
        // Define tabs based on user role
        final Map<String, Widget> tabs;
        final List<NavigationTab> navTabs;

        if (userRole == 'Medical Partner') {
          tabs = {
            'HomePage': const HomePageWidget(),
            'PartnerDashboardPage':
                PartnerDashboardPageWidget(partnerId: currentUserId),
            'SettingsPage': const SettingsPageWidget(),
          };
          navTabs = const [
            NavigationTab(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            NavigationTab(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
            ),
            NavigationTab(
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
          ];
        } else {
          // Patient role
          tabs = {
            'HomePage': const HomePageWidget(),
            'PatientDashboard': const PatientDashboardWidget(),
            'SettingsPage': const SettingsPageWidget(),
          };
          navTabs = const [
            NavigationTab(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            NavigationTab(
              icon: Icons.calendar_today_outlined,
              label: 'Appointments',
            ),
            NavigationTab(
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
          ];
        }

        final currentIndex = tabs.keys.toList().indexOf(_currentPageName);
        final currentBody = _currentPage ?? tabs[_currentPageName];

        // Adaptive Layout: NavigationRail for tablets, BottomNav for phones
        if (screenUtils.isMedium || screenUtils.isExpanded) {
          // Tablet/Foldable Layout: Use NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) {
                    setState(() {
                      _currentPage = null;
                      _currentPageName = tabs.keys.toList()[i];
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  backgroundColor: theme.colorScheme.surface,
                  destinations: navTabs
                      .map(
                        (tab) => NavigationRailDestination(
                          icon: Icon(tab.icon),
                          label: Text(tab.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: currentBody ?? const SizedBox()),
              ],
            ),
          );
        } else {
          // Phone Layout: Use GNav BottomNavigationBar
          return Scaffold(
            body: currentBody,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: GNav(
                  selectedIndex: currentIndex,
                  onTabChange: (i) {
                    setState(() {
                      _currentPage = null;
                      _currentPageName = tabs.keys.toList()[i];
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  color: theme.colorScheme.onSurfaceVariant,
                  activeColor: theme.colorScheme.primary,
                  tabBackgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.2),
                  gap: 8,
                  padding: const EdgeInsets.all(12),
                  tabs: navTabs
                      .map(
                        (tab) => GButton(
                          icon: tab.icon,
                          text: tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
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
}

/// Navigation tab configuration
class NavigationTab {
  const NavigationTab({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
