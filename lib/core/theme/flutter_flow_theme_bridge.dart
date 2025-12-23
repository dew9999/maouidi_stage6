// lib/core/theme/flutter_flow_theme_bridge.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Temporary compatibility bridge for legacy FlutterFlowTheme calls.
///
/// This class maps old FlutterFlowTheme.of(context) calls to the new
/// Material 3 Theme.of(context).colorScheme and textTheme.
///
/// Usage: Replace `FlutterFlowTheme.of(context)` with `FlutterFlowTheme.of(context)`
/// and this bridge will automatically translate to Material 3 theme values.
class FlutterFlowTheme {
  final BuildContext context;

  FlutterFlowTheme._(this.context);

  /// Factory method to get the theme instance for a context
  static FlutterFlowTheme of(BuildContext context) {
    return FlutterFlowTheme._(context);
  }

  ColorScheme get _colorScheme => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;

  /// Typography property for accessing text theme (legacy FlutterFlow pattern)
  TextTheme get typography => _textTheme;

  // ===== Color Properties =====

  Color get primary => _colorScheme.primary;
  Color get secondary => _colorScheme.secondary;
  Color get tertiary => _colorScheme.tertiary;
  Color get alternate => _colorScheme.surfaceContainerHighest;
  Color get primaryText => _colorScheme.onSurface;
  Color get secondaryText => _colorScheme.onSurfaceVariant;
  Color get primaryBackground => _colorScheme.surface;
  Color get secondaryBackground => _colorScheme.surface;
  Color get accent1 => _colorScheme.primaryContainer;
  Color get accent2 => _colorScheme.secondaryContainer;
  Color get accent3 => _colorScheme.tertiaryContainer;
  Color get accent4 => _colorScheme.errorContainer;
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error => _colorScheme.error;
  Color get info => _colorScheme.tertiary;

  Color get primaryBtnText => _colorScheme.onPrimary;
  Color get lineColor => _colorScheme.outline;
  Color get btnText => _colorScheme.onSurface;
  Color get customColor1 => _colorScheme.primary;
  Color get customColor3 => _colorScheme.tertiary;
  Color get customColor4 => _colorScheme.secondary;
  Color get white => Colors.white;
  Color get background => _colorScheme.surface;
  Color get dark400 => const Color(0xFF8E8E93);
  Color get grayIcon => _colorScheme.onSurfaceVariant;
  Color get gray200 => const Color(0xFFDBE2E7);
  Color get gray600 => const Color(0xFF4B5563);
  Color get black600 => const Color(0xFF374151);
  Color get tertiary400 => _colorScheme.tertiary;
  Color get textColor => _colorScheme.onSurface;

  // ===== Text Style Properties =====

  TextStyle get displayLarge => _textTheme.displayLarge ?? _defaultDisplayLarge;
  TextStyle get displayMedium =>
      _textTheme.displayMedium ?? _defaultDisplayMedium;
  TextStyle get displaySmall => _textTheme.displaySmall ?? _defaultDisplaySmall;

  TextStyle get headlineLarge =>
      _textTheme.headlineLarge ?? _defaultHeadlineLarge;
  TextStyle get headlineMedium =>
      _textTheme.headlineMedium ?? _defaultHeadlineMedium;
  TextStyle get headlineSmall =>
      _textTheme.headlineSmall ?? _defaultHeadlineSmall;

  TextStyle get titleLarge => _textTheme.titleLarge ?? _defaultTitleLarge;
  TextStyle get titleMedium => _textTheme.titleMedium ?? _defaultTitleMedium;
  TextStyle get titleSmall => _textTheme.titleSmall ?? _defaultTitleSmall;

  TextStyle get bodyLarge => _textTheme.bodyLarge ?? _defaultBodyLarge;
  TextStyle get bodyMedium => _textTheme.bodyMedium ?? _defaultBodyMedium;
  TextStyle get bodySmall => _textTheme.bodySmall ?? _defaultBodySmall;

  TextStyle get labelLarge => _textTheme.labelLarge ?? _defaultLabelLarge;
  TextStyle get labelMedium => _textTheme.labelMedium ?? _defaultLabelMedium;
  TextStyle get labelSmall => _textTheme.labelSmall ?? _defaultLabelSmall;

  // Legacy FlutterFlow text style names
  TextStyle get title1 => headlineLarge;
  TextStyle get title2 => headlineMedium;
  TextStyle get title3 => headlineSmall;
  TextStyle get subtitle1 => titleMedium;
  TextStyle get subtitle2 => titleSmall;
  TextStyle get bodyText1 => bodyLarge;
  TextStyle get bodyText2 => bodyMedium;

  // ===== Default Text Styles (Fallbacks) =====

  TextStyle get _defaultDisplayLarge => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultDisplayMedium => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultDisplaySmall => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultHeadlineLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultHeadlineMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultHeadlineSmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultTitleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultTitleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultTitleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultBodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultBodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultBodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultLabelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultLabelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _colorScheme.onSurface,
      );

  TextStyle get _defaultLabelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _colorScheme.onSurface,
      );
}

/// Extension on TextStyle to add the override method used in legacy FlutterFlow code.
extension TextStyleExtension on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
  }) {
    TextStyle result = copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
    );

    if (fontFamily != null && useGoogleFonts) {
      result = GoogleFonts.getFont(fontFamily).merge(result);
    } else if (fontFamily != null) {
      result = result.copyWith(fontFamily: fontFamily);
    }

    return result;
  }
}
