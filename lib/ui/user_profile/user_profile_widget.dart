// lib/ui/user_profile/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../../core/constants/wilayas.dart';
import '../../features/auth/data/auth_repository.dart';

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

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedWilaya;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final authRepo = ref.read(authRepositoryProvider);
      final profile = await authRepo.getUserProfile(user.id);

      if (mounted && profile != null) {
        // Validate dropdown values match available items
        final dbGender = profile['gender']?.toString();
        final dbWilaya = profile['wilaya']?.toString();

        setState(() {
          _profileData = profile;
          _firstNameController.text = profile['first_name']?.toString() ?? '';
          _lastNameController.text = profile['last_name']?.toString() ?? '';
          _phoneController.text = profile['phone']?.toString() ?? '';

          // Parse date of birth
          if (profile['date_of_birth'] != null) {
            _selectedDateOfBirth = DateTime.parse(profile['date_of_birth']);
          }

          // Only set dropdown values if they exist in the dropdown lists
          _selectedGender =
              ['Male', 'Female', 'Other'].contains(dbGender) ? dbGender : null;
          _selectedWilaya = wilayas.contains(dbWilaya) ? dbWilaya : null;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.updateUserProfile(user.id, {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'date_of_birth': _selectedDateOfBirth?.toIso8601String(),
        'gender': _selectedGender,
        'wilaya': _selectedWilaya,
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
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
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _loadProfile();
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      _getGenderIcon(
                        _selectedGender ?? _profileData?['gender'],
                      ),
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Display
                  Text(
                    '${_firstNameController.text} ${_lastNameController.text}',
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
                  if (!_isEditing)
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _isEditing = true);
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
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: _isSaving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
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
                  ),
                  const SizedBox(height: 16),

                  _buildDatePicker(colorScheme, textTheme),
                  const SizedBox(height: 16),

                  _buildGenderDropdown(colorScheme, textTheme),
                  const SizedBox(height: 16),

                  _buildWilayaDropdown(colorScheme, textTheme),

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
                    _profileData?['role']?.toString() ?? 'Patient',
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
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        filled: true,
        fillColor: _isEditing
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

  Widget _buildDatePicker(ColorScheme colorScheme, TextTheme textTheme) {
    return InkWell(
      onTap: () {
        DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(1900, 1, 1),
          maxTime: DateTime.now(),
          currentTime: _selectedDateOfBirth ?? DateTime.now(),
          onConfirm: (date) {
            if (_isEditing) {
              setState(() => _selectedDateOfBirth = date);
            }
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _isEditing
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
                    _selectedDateOfBirth != null
                        ? _formatDate(_selectedDateOfBirth!)
                        : 'Not set',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Icon(Icons.edit, color: colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(ColorScheme colorScheme, TextTheme textTheme) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: _isEditing
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
      onChanged: _isEditing
          ? (value) => setState(() => _selectedGender = value)
          : null,
    );
  }

  Widget _buildWilayaDropdown(ColorScheme colorScheme, TextTheme textTheme) {
    return DropdownButtonFormField<String>(
      value: _selectedWilaya,
      decoration: InputDecoration(
        labelText: 'Wilaya',
        prefixIcon:
            Icon(Icons.location_on_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: _isEditing
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
      onChanged: _isEditing
          ? (value) => setState(() => _selectedWilaya = value)
          : null,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
