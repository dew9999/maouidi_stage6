// lib/settings_page/components/location_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/settings_controller.dart';

class LocationField extends ConsumerStatefulWidget {
  final dynamic settings;
  final ThemeData theme;

  const LocationField({
    super.key,
    required this.settings,
    required this.theme,
  });

  @override
  ConsumerState<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends ConsumerState<LocationField> {
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.settings.location ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Location/Address',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Enter your address or location',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: textTheme.bodyMedium,
            maxLines: 2,
            onChanged: (value) {
              // Update the location in the controller
              ref
                  .read(partnerSettingsControllerProvider.notifier)
                  .updateClinic(value.isEmpty ? null : value);
            },
          ),
        ],
      ),
    );
  }
}
