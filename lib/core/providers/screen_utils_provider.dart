// lib/core/providers/screen_utils_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'screen_utils_provider.g.dart';

/// Device type categories for adaptive UI
enum DeviceType {
  phone,
  tablet,
  foldable,
}

/// Material Design 3 breakpoints
enum ScreenBreakpoint {
  compact, // < 600dp (phones in portrait)
  medium, // 600-840dp (tablets in portrait, phones in landscape)
  expanded, // > 840dp (tablets in landscape, desktops)
}

/// Screen utilities for responsive and adaptive UI design
/// Provides device detection, responsive sizing, and Material 3 breakpoints
class ScreenUtils {
  final BuildContext context;

  ScreenUtils(this.context);

  // ===== SCREEN DIMENSIONS =====

  double get width => MediaQuery.of(context).size.width;

  double get height => MediaQuery.of(context).size.height;

  double get diagonal {
    final size = MediaQuery.of(context).size;
    return sqrt(pow(size.width, 2) + pow(size.height, 2));
  }

  double get pixelRatio => MediaQuery.of(context).devicePixelRatio;

  // ===== SAFE AREAS =====

  EdgeInsets get safeArea => MediaQuery.of(context).padding;

  double get topSafeArea => MediaQuery.of(context).padding.top;

  double get bottomSafeArea => MediaQuery.of(context).padding.bottom;

  // ===== ORIENTATION =====

  Orientation get orientation => MediaQuery.of(context).orientation;

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  // ===== DEVICE TYPE DETECTION =====

  /// Detects device type based on diagonal screen size
  /// Phone: < 7 inches, Tablet: >= 7 inches, Foldable: detected via aspect ratio
  DeviceType get deviceType {
    // Calculate diagonal in inches (assuming ~160 dpi baseline)
    final diagonalInches = diagonal / (pixelRatio * 160);

    // Foldable detection: unusual aspect ratios when unfolded
    final aspectRatio = width / height;
    if ((aspectRatio > 2.0 || aspectRatio < 0.5) && diagonalInches > 7) {
      return DeviceType.foldable;
    }

    // Standard phone/tablet detection
    return diagonalInches < 7.0 ? DeviceType.phone : DeviceType.tablet;
  }

  bool get isPhone => deviceType == DeviceType.phone;

  bool get isTablet => deviceType == DeviceType.tablet;

  bool get isFoldable => deviceType == DeviceType.foldable;

  // ===== MATERIAL 3 BREAKPOINTS =====

  /// Returns the current Material Design 3 window size class
  /// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
  ScreenBreakpoint get breakpoint {
    if (width < 600) return ScreenBreakpoint.compact;
    if (width < 840) return ScreenBreakpoint.medium;
    return ScreenBreakpoint.expanded;
  }

  bool get isCompact => breakpoint == ScreenBreakpoint.compact;

  bool get isMedium => breakpoint == ScreenBreakpoint.medium;

  bool get isExpanded => breakpoint == ScreenBreakpoint.expanded;

  // ===== RESPONSIVE SIZING HELPERS =====

  /// Returns a value scaled to screen width percentage
  /// Usage: responsiveWidth(0.5) returns 50% of screen width
  double responsiveWidth(double percentage) => width * percentage;

  /// Returns a value scaled to screen height percentage
  /// Usage: responsiveHeight(0.5) returns 50% of screen height
  double responsiveHeight(double percentage) => height * percentage;

  /// Returns responsive font size scaled to screen width
  /// Clamps between minSize and maxSize for accessibility
  double responsiveFontSize(
    double baseSize, {
    double minSize = 12.0,
    double maxSize = 32.0,
  }) {
    final scaledSize =
        baseSize * (width / 375.0); // 375 = iPhone SE width baseline
    return scaledSize.clamp(minSize, maxSize);
  }

  /// Returns responsive spacing based on breakpoint
  /// Compact: 8dp, Medium: 12dp, Expanded: 16dp
  double get responsiveSpacing {
    switch (breakpoint) {
      case ScreenBreakpoint.compact:
        return 8.0;
      case ScreenBreakpoint.medium:
        return 12.0;
      case ScreenBreakpoint.expanded:
        return 16.0;
    }
  }

  /// Returns responsive padding based on breakpoint
  EdgeInsets get responsivePadding {
    final spacing = responsiveSpacing;
    return EdgeInsets.all(spacing * 2);
  }

  // ===== COLUMN COUNT FOR GRIDS =====

  /// Returns recommended column count for grid layouts based on breakpoint
  int get gridColumnCount {
    switch (breakpoint) {
      case ScreenBreakpoint.compact:
        return 2;
      case ScreenBreakpoint.medium:
        return 3;
      case ScreenBreakpoint.expanded:
        return 4;
    }
  }
}

/// Riverpod provider for ScreenUtils
/// Usage: final screenUtils = ref.watch(screenUtilsProvider);
@riverpod
ScreenUtils screenUtils(ScreenUtilsRef ref) {
  // This will throw if called outside of a widget context
  // Use it only within widget builds or ConsumerWidget
  throw UnimplementedError(
    'screenUtilsProvider must be overridden with a scoped provider in your widget tree',
  );
}
