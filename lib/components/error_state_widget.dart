// lib/components/error_state_widget.dart

import 'package:flutter/material.dart';

/// A reusable widget for displaying error states with retry functionality
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title,
  });

  /// The error message to display
  final String message;

  /// Optional callback to retry the failed operation
  final VoidCallback? onRetry;

  /// Icon to display (defaults to error_outline)
  final IconData icon;

  /// Optional title text (defaults to "Error")
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Error',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact error widget for use in cards or smaller spaces
class CompactErrorWidget extends StatelessWidget {
  const CompactErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: colorScheme.error,
              tooltip: 'Retry',
            ),
          ],
        ],
      ),
    );
  }
}

/// Error widget specifically for network-related errors
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message = 'No internet connection',
  });

  final VoidCallback? onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.wifi_off_rounded,
      title: 'Connection Error',
    );
  }
}

/// Error widget for data loading failures
class DataLoadErrorWidget extends StatelessWidget {
  const DataLoadErrorWidget({
    super.key,
    required this.onRetry,
    this.message = 'Failed to load data',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off_rounded,
      title: 'Load Failed',
    );
  }
}
