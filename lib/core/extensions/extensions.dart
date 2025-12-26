import 'package:flutter/material.dart';

/// Extension methods for BuildContext navigation helpers
extension NavigationExtension on BuildContext {
  /// Safely pop the current route if possible
  void safePop() {
    if (mounted && Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }
}

/// Extension methods for DateTime utilities
extension DateTimeExtension on DateTime {
  /// Get the start of the day (midnight)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get the end of the day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

/// Extension methods for Map utilities
extension MapExtension<K, V> on Map<K, V?> {
  /// Returns a new map with all null values removed
  Map<K, V> get withoutNulls {
    return Map.fromEntries(
      entries.where((entry) => entry.value != null).map(
            (entry) => MapEntry(entry.key, entry.value as V),
          ),
    );
  }
}
