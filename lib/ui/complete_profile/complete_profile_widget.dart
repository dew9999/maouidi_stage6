// lib/ui/complete_profile/complete_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../../core/constants/wilayas.dart';

// Riverpod providers for form state
final _dateOfBirthProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);
final _genderProvider = StateProvider.autoDispose<String?>((ref) => null);
final _wilayaProvider = StateProvider.autoDispose<String?>((ref) => null);
final _termsAgreedProvider = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CompleteProfileWidget extends ConsumerWidget {
  final bool isEditing;

  const CompleteProfileWidget({super.key, this.isEditing = false});

  static String routeName = 'CompleteProfile';
  static String routePath = '/completeProfile';

  Future<void> _checkExistingProfile(BuildContext context) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('users')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null &&
          response['first_name'] != null &&
          response['first_name'].toString().trim().isNotEmpty) {
        if (context.mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      // Continue to show form
    }
  }

  Future<void> _submitProfile(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneController,
  ) async {
    if (!formKey.currentState!.validate()) return;

    // Validate phone number format
    final phone = phoneController.text.trim();
    if (phone.length != 10 || !RegExp(r'^0[567]').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Phone number must be 10 digits starting with 05, 06, or 07',
          ),
        ),
      );
      return;
    }

    final selectedDateOfBirth = ref.read(_dateOfBirthProvider);
    if (selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    final selectedGender = ref.read(_genderProvider);
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    final selectedWilaya = ref.read(_wilayaProvider);
    if (selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your wilaya')),
      );
      return;
    }

    final termsAgreed = ref.read(_termsAgreedProvider);
    if (!termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy'),
        ),
      );
      return;
    }

    ref.read(_isLoadingProvider.notifier).state = true;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('users').update({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'date_of_birth': selectedDateOfBirth.toIso8601String(),
        'gender': selectedGender,
        'wilaya': selectedWilaya,
      }).eq('id', user.id);

      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      ref.read(_isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();

    final selectedDateOfBirth = ref.watch(_dateOfBirthProvider);
    final selectedGender = ref.watch(_genderProvider);
    final selectedWilaya = ref.watch(_wilayaProvider);
    final termsAgreed = ref.watch(_termsAgreedProvider);
    final isLoading = ref.watch(_isLoadingProvider);

    // Check existing profile only if not editing
    if (!isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkExistingProfile(context);
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Complete Your Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let\'s set up your profile',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '* Required field',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                TextFormField(
                  controller: firstNameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter your first name',
                    prefixIcon:
                        Icon(Icons.person_outline, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: lastNameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter your last name',
                    prefixIcon:
                        Icon(Icons.person_outline, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter your phone number',
                    prefixIcon:
                        Icon(Icons.phone_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth
                InkWell(
                  onTap: () {
                    DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime(1900, 1, 1),
                      maxTime: DateTime.now(),
                      currentTime: selectedDateOfBirth ?? DateTime(2000, 1, 1),
                      onConfirm: (date) {
                        ref.read(_dateOfBirthProvider.notifier).state = date;
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
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
                                'Date of Birth *',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedDateOfBirth != null
                                    ? '${selectedDateOfBirth.day}/${selectedDateOfBirth.month}/${selectedDateOfBirth.year}'
                                    : 'Select date',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender *',
                    hintText: 'Select your gender',
                    prefixIcon:
                        Icon(Icons.wc_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                  onChanged: (value) =>
                      ref.read(_genderProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),

                // Wilaya
                DropdownButtonFormField<String>(
                  value: selectedWilaya,
                  decoration: InputDecoration(
                    labelText: 'Wilaya *',
                    hintText: 'Select your wilaya',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.primary,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                  onChanged: (value) =>
                      ref.read(_wilayaProvider.notifier).state = value,
                ),
                const SizedBox(height: 24),

                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: termsAgreed,
                      onChanged: (value) => ref
                          .read(_termsAgreedProvider.notifier)
                          .state = value ?? false,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => ref
                            .read(_termsAgreedProvider.notifier)
                            .state = !termsAgreed,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () => _submitProfile(
                            context,
                            ref,
                            formKey,
                            firstNameController,
                            lastNameController,
                            phoneController,
                          ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Complete Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
