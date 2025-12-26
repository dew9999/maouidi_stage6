// lib/ui/user_profile/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../../core/constants/wilayas.dart';
import 'user_profile_controller.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'user_profile';
  static String routePath = '/userProfile';

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  IconData _getGenderIcon(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return Icons.man;
      case 'female':
        return Icons.woman;
      default:
        return Icons.transgender;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to update controllers when data loads or on cancel
    ref.listen(userProfileControllerProvider, (previous, next) {
      final nextState = next.value;
      final prevState = previous?.value;

      if (nextState != null) {
        // Initial load or if we just cancelled editing
        bool justLoaded = prevState == null;
        bool cancelledEditing =
            (prevState?.isEditing == true && !nextState.isEditing);

        if (justLoaded || cancelledEditing) {
          _firstNameController.text = nextState.firstName;
          _lastNameController.text = nextState.lastName;
          _phoneController.text = nextState.phone;
        }
      }
    });

    final stateAsync = ref.watch(userProfileControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Your Profile',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          stateAsync.when(
            data: (state) {
              if (state.isEditing) {
                return TextButton(
                  onPressed: () {
                    ref
                        .read(userProfileControllerProvider.notifier)
                        .toggleEditing(false);
                  },
                  child: const Text('Cancel'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    _getGenderIcon(state.gender),
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Display
                Text(
                  '${state.firstName} ${state.lastName}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Edit/Save Button
                if (!state.isEditing)
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(userProfileControllerProvider.notifier)
                          .toggleEditing(true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            try {
                              final success = await ref
                                  .read(userProfileControllerProvider.notifier)
                                  .saveProfile();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Profile updated successfully!')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error saving profile: $e')),
                                );
                              }
                            }
                          },
                    icon: state.isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Personal Information Section
                _buildSectionHeader(
                  'Personal Information',
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z\s-]'),
                    ),
                  ],
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isEditing: state.isEditing,
                  onChanged: (val) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(firstName: val),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z\s-]'),
                    ),
                  ],
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isEditing: state.isEditing,
                  onChanged: (val) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(lastName: val),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isEditing: state.isEditing,
                  onChanged: (val) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(phone: val),
                ),
                const SizedBox(height: 16),

                _buildDatePicker(
                  context,
                  state.dateOfBirth,
                  state.isEditing,
                  colorScheme,
                  textTheme,
                  (date) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(dateOfBirth: date),
                ),
                const SizedBox(height: 16),

                _buildGenderDropdown(
                  state.gender,
                  state.isEditing,
                  colorScheme,
                  textTheme,
                  (val) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(gender: val),
                ),
                const SizedBox(height: 16),

                _buildWilayaDropdown(
                  state.wilaya,
                  state.isEditing,
                  colorScheme,
                  textTheme,
                  (val) => ref
                      .read(userProfileControllerProvider.notifier)
                      .updateField(wilaya: val),
                ),

                const SizedBox(height: 32),

                // Account Information Section
                _buildSectionHeader(
                  'Account Information',
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 16),

                _buildInfoRow(
                  'Email',
                  user?.email ?? 'N/A',
                  Icons.email_outlined,
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  'Email Verified',
                  user?.emailConfirmedAt != null ? 'Yes' : 'No',
                  Icons.verified_outlined,
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  'Role',
                  state.profileData?['role']?.toString() ?? 'Patient',
                  Icons.badge_outlined,
                  colorScheme,
                  textTheme,
                ),
                const SizedBox(height: 12),

                _buildInfoRow(
                  'Member Since',
                  user?.createdAt != null
                      ? _formatDate(DateTime.parse(user!.createdAt))
                      : 'N/A',
                  Icons.calendar_today_outlined,
                  colorScheme,
                  textTheme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isEditing,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        filled: true,
        fillColor: isEditing
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime? selectedDate,
    bool isEditing,
    ColorScheme colorScheme,
    TextTheme textTheme,
    ValueChanged<DateTime> onConfirm,
  ) {
    return InkWell(
      onTap: () {
        if (!isEditing) return;
        DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(1900, 1, 1),
          maxTime: DateTime.now(),
          currentTime: selectedDate ?? DateTime.now(),
          onConfirm: onConfirm,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isEditing
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Not set',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (isEditing)
              Icon(Icons.edit, color: colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(
    String? currentVal,
    bool isEditing,
    ColorScheme colorScheme,
    TextTheme textTheme,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentVal,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: isEditing
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      items: ['Male', 'Female', 'Other']
          .map(
            (gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ),
          )
          .toList(),
      onChanged: isEditing ? onChanged : null,
    );
  }

  Widget _buildWilayaDropdown(
    String? currentVal,
    bool isEditing,
    ColorScheme colorScheme,
    TextTheme textTheme,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentVal,
      decoration: InputDecoration(
        labelText: 'Wilaya',
        prefixIcon:
            Icon(Icons.location_on_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: isEditing
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      items: wilayas
          .map(
            (wilaya) => DropdownMenuItem(
              value: wilaya,
              child: Text(wilaya),
            ),
          )
          .toList(),
      onChanged: isEditing ? onChanged : null,
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
