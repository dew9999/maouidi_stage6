// lib/core/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

const _kLocaleStorageKey = '__locale_key__';

/// Locale Provider - manages app locale using Riverpod
///
/// Manages app-wide locale state
/// Supports: English (en), Arabic (ar), French (fr)
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const List<String> supportedLanguages = ['en', 'ar', 'fr'];

  @override
  Locale? build() {
    _loadLocale();
    return null; // Default to null, will load from storage
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_kLocaleStorageKey);

    if (savedLocale != null && savedLocale.isNotEmpty) {
      state = _createLocale(savedLocale);
    }
  }

  /// Set and persist locale
  Future<void> setLocale(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) {
      return; // Ignore unsupported languages
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleStorageKey, languageCode);
    state = _createLocale(languageCode);
  }

  /// Create Locale from language code
  Locale _createLocale(String language) {
    if (language.contains('_')) {
      return Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      );
    }
    return Locale(language);
  }
}
