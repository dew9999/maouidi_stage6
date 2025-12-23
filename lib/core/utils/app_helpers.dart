// lib/core/utils/app_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

/// Helper functions to replace legacy MyApp.of() static methods
///
/// These functions provide Riverpod-based alternatives for setting
/// app locale and theme mode without requiring StatefulWidget ancestry.

/// Set app language using Riverpod locale provider
void setAppLanguage(BuildContext context, String language) {
  final container = ProviderScope.containerOf(context);
  container.read(localeNotifierProvider.notifier).setLocale(language);
}

/// Set app theme mode using Riverpod theme provider
void setDarkModeSetting(BuildContext context, ThemeMode themeMode) {
  final container = ProviderScope.containerOf(context);
  container.read(themeModeNotifierProvider.notifier).setThemeMode(themeMode);
}
