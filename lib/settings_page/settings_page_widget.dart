// lib/settings_page/settings_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/supabase_auth/auth_util.dart';
import '../../core/constants.dart';
import '../../core/extensions/extensions.dart';
import '../../core/utils/app_helpers.dart';

import 'package:maouidi/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../features/auth/presentation/user_role_provider.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../index.dart';
import '../../pages/privacy_policy_page.dart';
import '../../pages/terms_of_service_page.dart';
import 'components/settings_group.dart';
import 'components/settings_item.dart';
import 'components/become_partner_dialog.dart';
import 'components/profile_card.dart';
import 'components/settings_dialogs.dart';

class SettingsPageWidget extends ConsumerStatefulWidget {
  const SettingsPageWidget({super.key});
  static String routeName = 'SettingsPage';
  static String routePath = '/settingsPage';

  @override
  ConsumerState<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends ConsumerState<SettingsPageWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRoleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: theme.textTheme.headlineMedium?.copyWith(fontFamily: 'Inter'),
        ),
        centerTitle: true,
      ),
      body: userRoleAsync.when(
        data: (userRole) {
          if (userRole == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return userRole == 'Medical Partner'
              ? const _PartnerSettingsView()
              : const _PatientSettingsView();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading settings')),
      ),
    );
  }
}

// =====================================================================
//                       PATIENT SETTINGS VIEW
// =====================================================================

class _PatientSettingsView extends ConsumerWidget {
  const _PatientSettingsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(patientSettingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ProfileCard(
              name: settings.displayName,
              email: settings.email,
              photoUrl: settings.photoUrl,
              gender: settings.gender,
              onTap: () => context.pushNamed(UserProfileWidget.routeName),
            ),
            SettingsGroup(
              title: AppLocalizations.of(context)!.notifications,
              children: [
                SettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: AppLocalizations.of(context)!.pushnotif,
                  subtitle: AppLocalizations.of(context)!.rcvalerts,
                  trailing: Switch.adaptive(
                    value: settings.notificationsEnabled,
                    thumbColor:
                        WidgetStateProperty.all(theme.colorScheme.primary),
                    onChanged: (newValue) {
                      ref
                          .read(patientSettingsControllerProvider.notifier)
                          .toggleNotifications(newValue);
                    },
                  ),
                ),
              ],
            ),
            const _GeneralAndLegalSettings(),
            SettingsGroup(
              title: AppLocalizations.of(context)!.acctlegal,
              children: [
                SettingsItem(
                  icon: Icons.work_outline,
                  title: AppLocalizations.of(context)!.becomeptr,
                  subtitle: AppLocalizations.of(context)!.listservices,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => BecomePartnerDialog(
                      currentDisplayName: settings.displayName,
                      currentPhoneNumber: settings.phoneNumber,
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.delete_forever_outlined,
                  title: AppLocalizations.of(context)!.delacct,
                  iconColor: theme.colorScheme.error,
                  iconBackgroundColor: theme.colorScheme.error.withAlpha(25),
                  onTap: () => showDeleteAccountDialog(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FilledButton(
                onPressed: () async {
                  await ref
                      .read(patientSettingsControllerProvider.notifier)
                      .signOut();
                  if (context.mounted) {
                    context.go(WelcomeScreenWidget.routePath);
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  textStyle: theme.textTheme.titleSmall,
                ),
                child: Text(AppLocalizations.of(context)!.logout),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading settings: ${error.toString()}'),
      ),
    );
  }
}

// =====================================================================
//                       PARTNER SETTINGS VIEW
// =====================================================================

class _PartnerSettingsView extends ConsumerWidget {
  const _PartnerSettingsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(partnerSettingsControllerProvider);

    return settingsAsync.when(
      data: (settings) {
        final isDoctor =
            settings.category != 'Clinics' && settings.category != 'Charities';

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              ProfileCard(
                name: settings.fullName,
                email: settings.email,
                photoUrl: settings.photoUrl,
                gender: settings.gender,
                onTap: () => context.pushNamed(
                  PartnerProfilePageWidget.routeName,
                  queryParameters: {'partnerId': currentUserId}.withoutNulls,
                ),
              ),
              if (isDoctor)
                _ProfessionalDetailsSection(
                  settings: settings,
                  theme: theme,
                ),
              _BookingConfigurationSection(
                settings: settings,
                theme: theme,
              ),
              _AvailabilitySection(settings: settings),
              SettingsGroup(
                title: 'Actions',
                children: [_EmergencyCard()],
              ),
              SettingsGroup(
                title: AppLocalizations.of(context)!.notifications,
                children: [
                  SettingsItem(
                    icon: Icons.notifications_active_outlined,
                    title: AppLocalizations.of(context)!.pushnotif,
                    subtitle: 'Receive alerts for new bookings',
                    trailing: Switch.adaptive(
                      value: settings.notificationsEnabled,
                      activeTrackColor: theme.colorScheme.primary,
                      onChanged: (newValue) {
                        ref
                            .read(partnerSettingsControllerProvider.notifier)
                            .toggleNotifications(newValue);
                      },
                    ),
                  ),
                ],
              ),
              const _GeneralAndLegalSettings(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                child: FilledButton(
                  onPressed: settings.isSaving
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(
                                  partnerSettingsControllerProvider.notifier,
                                )
                                .saveAllSettings();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Settings saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to save settings: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: theme.textTheme.titleSmall,
                  ),
                  child: Text(
                    settings.isSaving
                        ? AppLocalizations.of(context)!.saving
                        : AppLocalizations.of(context)!.saveall,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(partnerSettingsControllerProvider.notifier)
                        .signOut();
                    if (context.mounted) {
                      context.go(WelcomeScreenWidget.routePath);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    textStyle: theme.textTheme.titleSmall,
                  ),
                  child: Text(AppLocalizations.of(context)!.logout),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading settings: ${error.toString()}'),
      ),
    );
  }
}

// =====================================================================
//                    PARTNER SUB-SECTIONS
// =====================================================================

class _ProfessionalDetailsSection extends ConsumerStatefulWidget {
  final dynamic settings;
  final ThemeData theme;

  const _ProfessionalDetailsSection({
    required this.settings,
    required this.theme,
  });

  @override
  ConsumerState<_ProfessionalDetailsSection> createState() =>
      _ProfessionalDetailsSectionState();
}

class _ProfessionalDetailsSectionState
    extends ConsumerState<_ProfessionalDetailsSection> {
  // Bio controller removed as Bio is moved to Profile page

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Professional Details',
      children: [
        SettingsItem(
          icon: Icons.medical_services_outlined,
          title: 'Specialty',
          trailing: SizedBox(
            width: 180,
            child: DropdownButton<String>(
              value: widget.settings.specialty,
              items: medicalSpecialties.map((String specialty) {
                return DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(
                    specialty,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? val) {
                if (val != null) {
                  ref
                      .read(partnerSettingsControllerProvider.notifier)
                      .updateSpecialty(val);
                }
              },
              hint: const Text('Select...'),
              isExpanded: true,
              underline: const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingConfigurationSection extends ConsumerStatefulWidget {
  final dynamic settings;
  final ThemeData theme;

  const _BookingConfigurationSection({
    required this.settings,
    required this.theme,
  });

  @override
  ConsumerState<_BookingConfigurationSection> createState() =>
      _BookingConfigurationSectionState();
}

class _BookingConfigurationSectionState
    extends ConsumerState<_BookingConfigurationSection> {
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.settings.dailyBookingLimit.toString(),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: 'Booking Configuration',
      children: [
        SettingsItem(
          icon: Icons.toggle_on_outlined,
          title: 'Accepting Appointments',
          subtitle:
              widget.settings.isActive ? 'You are open' : 'You are closed',
          trailing: Switch.adaptive(
            value: widget.settings.isActive,
            activeTrackColor: widget.theme.colorScheme.primary,
            onChanged: (newValue) {
              ref
                  .read(partnerSettingsControllerProvider.notifier)
                  .updateIsActive(newValue);
            },
          ),
        ),
        SettingsItem(
          icon: Icons.approval_outlined,
          title: 'Confirmation Mode',
          subtitle: widget.settings.confirmationMode == 'auto'
              ? 'Auto-Confirm'
              : 'Manual Confirm',
          trailing: SegmentedButton<String>(
            style: SegmentedButton.styleFrom(
              backgroundColor: widget.theme.colorScheme.surface,
            ),
            segments: const [
              ButtonSegment(value: 'auto', label: Text('Auto')),
              ButtonSegment(value: 'manual', label: Text('Manual')),
            ],
            selected: {widget.settings.confirmationMode},
            onSelectionChanged: (newSelection) {
              ref
                  .read(partnerSettingsControllerProvider.notifier)
                  .updateConfirmationMode(newSelection.first);
            },
          ),
        ),
        SettingsItem(
          icon: Icons.people_outline,
          title: 'Booking System',
          subtitle: widget.settings.bookingSystemType == 'time_based'
              ? 'Time Slots'
              : 'Queue Numbers',
          trailing: widget.settings.category == 'Homecare'
              ? Text(
                  'Queue (Required)',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: widget.theme.colorScheme.surface,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: 'time_based',
                      label: Text('Slots'),
                    ),
                    ButtonSegment(
                      value: 'number_based',
                      label: Text('Queue'),
                    ),
                  ],
                  selected: {widget.settings.bookingSystemType},
                  onSelectionChanged: (newSelection) {
                    ref
                        .read(partnerSettingsControllerProvider.notifier)
                        .updateBookingSystem(newSelection.first);
                  },
                ),
        ),
        if (widget.settings.bookingSystemType == 'number_based')
          SettingsItem(
            icon: Icons.pin_outlined,
            title: 'Daily Patient Limit',
            trailing: SizedBox(
              width: 80,
              child: TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if ((int.tryParse(val) ?? 0) <= 0) {
                    return ' > 0';
                  }
                  return null;
                },
                onChanged: (val) {
                  final limit = int.tryParse(val);
                  if (limit != null && limit > 0) {
                    ref
                        .read(partnerSettingsControllerProvider.notifier)
                        .updateDailyLimit(limit);
                  }
                },
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g., 20',
                  hintStyle: widget.theme.textTheme.labelMedium,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AvailabilitySection extends ConsumerWidget {
  final dynamic settings;

  const _AvailabilitySection({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsGroup(
      title: 'Your Availability',
      children: [
        const _WorkingHoursEditor(), // No props needed, uses provider
        _ClosedDaysEditor(
          closedDays: settings.closedDays,
        ),
      ],
    );
  }
}

// =====================================================================
//                       SHARED SETTINGS WIDGET
// =====================================================================

class _GeneralAndLegalSettings extends StatelessWidget {
  const _GeneralAndLegalSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SettingsGroup(
          title: AppLocalizations.of(context)!.general,
          children: [
            SettingsItem(
              icon: Icons.translate_rounded,
              title: AppLocalizations.of(context)!.language,
              trailing: DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                ],
                onChanged: (String? languageCode) {
                  if (languageCode != null) {
                    setAppLanguage(context, languageCode);
                  }
                },
                underline: const SizedBox.shrink(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                dropdownColor: theme.colorScheme.surface,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            SettingsItem(
              icon: Icons.brightness_6_outlined,
              title: AppLocalizations.of(context)!.darkmode,
              trailing: Switch.adaptive(
                value: isDarkMode,
                thumbColor: WidgetStateProperty.all(theme.colorScheme.primary),
                onChanged: (isDarkMode) {
                  final newMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                  setDarkModeSetting(context, newMode);
                },
              ),
            ),
            SettingsItem(
              icon: Icons.contact_support_outlined,
              title: AppLocalizations.of(context)!.contactus,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => showContactUsDialog(context),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Legal',
          children: [
            SettingsItem(
              icon: Icons.shield_outlined,
              title: AppLocalizations.of(context)!.privpolicy,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushNamed(PrivacyPolicyPage.routeName),
            ),
            SettingsItem(
              icon: Icons.description_outlined,
              title: AppLocalizations.of(context)!.termsserv,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushNamed(TermsOfServicePage.routeName),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkingHoursEditor extends ConsumerWidget {
  const _WorkingHoursEditor();

  final Map<String, String> _daysOfWeek = const {
    'Monday': '1',
    'Tuesday': '2',
    'Wednesday': '3',
    'Thursday': '4',
    'Friday': '5',
    'Saturday': '6',
    'Sunday': '7',
  };

  Future<void> _editTimeSlot(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<String>> hours,
    String dayKey,
    int slotIndex,
  ) async {
    final parts = hours[dayKey]![slotIndex].split('-');
    final TimeOfDay startTime = TimeOfDay(
      hour: int.parse(parts[0].split(':')[0]),
      minute: int.parse(parts[0].split(':')[1]),
    );
    final TimeOfDay endTime = TimeOfDay(
      hour: int.parse(parts[1].split(':')[0]),
      minute: int.parse(parts[1].split(':')[1]),
    );

    final newStartTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select Start Time',
    );
    if (newStartTime == null) return;

    final newEndTime = await showTimePicker(
      context: context,
      initialTime: endTime,
      helpText: 'Select End Time',
    );
    if (newEndTime != null) {
      if (!context.mounted) return;

      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = newEndTime.hour * 60 + newEndTime.minute;
      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final formattedStart =
          '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
      final formattedEnd =
          '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';

      final newSlot = '$formattedStart-$formattedEnd';

      ref
          .read(partnerSettingsControllerProvider.notifier)
          .updateWorkingHourSlot(dayKey, slotIndex, newSlot);
    }
  }

  Future<void> _addTimeSlot(
    BuildContext context,
    WidgetRef ref,
    String dayKey,
  ) async {
    const startTime = TimeOfDay(hour: 9, minute: 0);
    const endTime = TimeOfDay(hour: 17, minute: 0);

    final newStartTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select Start Time',
    );
    if (newStartTime == null) return;

    final newEndTime = await showTimePicker(
      context: context,
      initialTime: endTime,
      helpText: 'Select End Time',
    );
    if (newEndTime != null) {
      if (!context.mounted) return;

      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = newEndTime.hour * 60 + newEndTime.minute;

      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final formattedStart =
          '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
      final formattedEnd =
          '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';

      // We pass the dayKey, controller handles appending a new slot if needed, but wait--
      // Controller has `addWorkingHourSlot(day)` which adds default.
      // We need `addWorkingHourSlot(day, customSlot)?`
      // Or we just add default and then update it?
      // User flow here picks time first.
      // I should update controller to accept custom slot content for add action or support it.
      // For now, I'll update the logic: I need to add slot with specific times.
      // I'll assume I can just update the LIST directly via updateWorkingHours if I really need to,
      // BUT `PartnerSettingsController` has `addWorkingHourSlot(day)` which adds "09:00-17:00".
      // I should probably update that method to accept time, or just rely on updateWorkingHourSlot after adding?
      // No, that's racy or ugly.
      // Let's assume for now I'll just use the default add method provided by the controller for simplicity and let user edit later?
      // No, the UI here shows picker.
      // I will rely on `updateWorkingHours` map update for this complex interaction OR
      // ideally I should have added `addWorkingHourSlot(day, slot)` to controller.
      // Since I can't easily jump back to controller now without context switch cost, I'll use the
      // full update method which is exposed: `updateWorkingHours(newMap)`.
      // But wait, constructing `newMap` requires reading state.

      final currentMap =
          ref.read(partnerSettingsControllerProvider).value?.workingHours ?? {};
      final newMap = Map<String, List<String>>.from(currentMap);
      if (!newMap.containsKey(dayKey)) {
        newMap[dayKey] = [];
      }
      newMap[dayKey]!.add('$formattedStart-$formattedEnd');

      ref
          .read(partnerSettingsControllerProvider.notifier)
          .updateWorkingHours(newMap);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(partnerSettingsControllerProvider);
    // Cache theme references to prevent crashes during theme transitions
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        final hours = settings.workingHours;

        return Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: _daysOfWeek.entries.map((dayEntry) {
              final dayName = dayEntry.key;
              final dayKey = dayEntry.value;
              final isEnabled = hours.containsKey(dayKey);

              return ExpansionTile(
                key: PageStorageKey(dayName),
                iconColor: colorScheme.onSurface,
                collapsedIconColor: colorScheme.onSurfaceVariant,
                title: Text(
                  dayName,
                  style: textTheme.bodyLarge,
                ),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (enabled) {
                    ref
                        .read(partnerSettingsControllerProvider.notifier)
                        .setDayAvailability(dayKey, enabled);
                  },
                  activeTrackColor: colorScheme.primary,
                ),
                children: [
                  if (isEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                      child: Column(
                        children: [
                          ...(hours[dayKey] ?? []).asMap().entries.map((entry) {
                            final int idx = entry.key;
                            final String timeSlot = entry.value;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeSlot,
                                    style: textTheme.bodyMedium,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        onPressed: () => _editTimeSlot(
                                          context,
                                          ref,
                                          hours,
                                          dayKey,
                                          idx,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: colorScheme.error,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                partnerSettingsControllerProvider
                                                    .notifier,
                                              )
                                              .removeWorkingHourSlot(
                                                dayKey,
                                                idx,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Time Slot'),
                              onPressed: () =>
                                  _addTimeSlot(context, ref, dayKey),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ClosedDaysEditor extends ConsumerWidget {
  final List<DateTime> closedDays;

  const _ClosedDaysEditor({required this.closedDays});

  Future<void> _addDay(BuildContext context, WidgetRef ref) async {
    final newDay = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDay != null && !closedDays.any((d) => d.isAtSameMomentAs(newDay))) {
      try {
        await ref
            .read(partnerSettingsControllerProvider.notifier)
            .addClosedDay(newDay);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Day closed and patients have been notified.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error closing day: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _removeDay(WidgetRef ref, DateTime day) {
    ref.read(partnerSettingsControllerProvider.notifier).removeClosedDay(day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Assuming controller handles loading state which is reflected in settingsAsync in parent
    // However, for adding day action, we might want local loading indicator?
    // User requested removal of setState. We can trust the async operation speed or use
    // value state if we really want to show spinner on the button.
    // Since I'm converting to ConsumerWidget, I'll rely on the global loading or just
    // blocking interaction via await.

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specific Closed Days', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          closedDays.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('You have no specific closed days scheduled.'),
                  ),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: closedDays
                      .map(
                        (day) => Chip(
                          label: Text(DateFormat.yMMMd().format(day)),
                          onDeleted: () => _removeDay(ref, day),
                          deleteIconColor: theme.colorScheme.error,
                          backgroundColor: theme.colorScheme.surface,
                          labelStyle: theme.textTheme.bodyMedium,
                        ),
                      )
                      .toList(),
                ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add a Closed Day'),
              onPressed: () => _addDay(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsItem(
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange.withAlpha(25),
      title: 'Emergency',
      subtitle: 'Notify patients of an urgent cancellation',
      onTap: () => _showEmergencyConfirmation(context, ref),
    );
  }

  void _showEmergencyConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Emergency'),
        content: const Text(
          'This will alert and cancel appointments for patients in the near future. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(partnerSettingsControllerProvider.notifier)
                    .handleEmergency();
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency alert sent successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showContactUsDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Contact Us'),
      content: const Text('Support email: support@maouidi.com'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
