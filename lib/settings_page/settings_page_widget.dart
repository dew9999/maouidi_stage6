// lib/settings_page/settings_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/supabase_auth/auth_util.dart';
import '../../core/constants.dart';
import '../../flutter_flow/flutter_flow_drop_down.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'package:maouidi/flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/form_field_controller.dart';
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
    final theme = FlutterFlowTheme.of(context);
    final userRoleAsync = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          FFLocalizations.of(context).getText('settings'),
          style: theme.headlineMedium.override(fontFamily: 'Inter'),
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
    final theme = FlutterFlowTheme.of(context);
    final settingsAsync = ref.watch(patientSettingsControllerProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ProfileCard(
              name: settings.displayName,
              email: settings.email,
              onTap: () => context.pushNamed(UserProfileWidget.routeName),
            ),
            SettingsGroup(
              title: FFLocalizations.of(context).getText('notifications'),
              children: [
                SettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: FFLocalizations.of(context).getText('pushnotif'),
                  subtitle: FFLocalizations.of(context).getText('rcvalerts'),
                  trailing: Switch.adaptive(
                    value: settings.notificationsEnabled,
                    thumbColor: WidgetStateProperty.all(theme.primary),
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
              title: FFLocalizations.of(context).getText('acctlegal'),
              children: [
                SettingsItem(
                  icon: Icons.work_outline,
                  title: FFLocalizations.of(context).getText('becomeptr'),
                  subtitle: FFLocalizations.of(context).getText('listservices'),
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
                  title: FFLocalizations.of(context).getText('delacct'),
                  iconColor: theme.error,
                  iconBackgroundColor: theme.error.withAlpha(25),
                  onTap: () => showDeleteAccountDialog(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FFButtonWidget(
                onPressed: () async {
                  await ref
                      .read(patientSettingsControllerProvider.notifier)
                      .signOut();
                  if (context.mounted) {
                    context.go(WelcomeScreenWidget.routePath);
                  }
                },
                text: FFLocalizations.of(context).getText('logout'),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50,
                  color: theme.error,
                  textStyle: theme.titleSmall.copyWith(color: Colors.white),
                ),
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
    final theme = FlutterFlowTheme.of(context);
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
                title: FFLocalizations.of(context).getText('notifications'),
                children: [
                  SettingsItem(
                    icon: Icons.notifications_active_outlined,
                    title: FFLocalizations.of(context).getText('pushnotif'),
                    subtitle: 'Receive alerts for new bookings',
                    trailing: Switch.adaptive(
                      value: settings.notificationsEnabled,
                      activeTrackColor: theme.primary,
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
                child: FFButtonWidget(
                  onPressed: settings.isSaving
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(
                                    partnerSettingsControllerProvider.notifier,)
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
                                      'Failed to save settings: ${e.toString()}',),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  text: settings.isSaving
                      ? FFLocalizations.of(context).getText('saving')
                      : FFLocalizations.of(context).getText('saveall'),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: theme.primary,
                    textStyle: theme.titleSmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FFButtonWidget(
                  onPressed: () async {
                    await ref
                        .read(partnerSettingsControllerProvider.notifier)
                        .signOut();
                    if (context.mounted) {
                      context.go(WelcomeScreenWidget.routePath);
                    }
                  },
                  text: FFLocalizations.of(context).getText('logout'),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50,
                    color: theme.error,
                    textStyle: theme.titleSmall.copyWith(color: Colors.white),
                  ),
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
  final FlutterFlowTheme theme;

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
  late FormFieldController<String> _specialtyController;
  late FormFieldController<String> _clinicController;

  @override
  void initState() {
    super.initState();
    _specialtyController =
        FormFieldController<String>(widget.settings.specialty);
    _clinicController =
        FormFieldController<String>(widget.settings.parentClinicId);
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

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
            child: FlutterFlowDropDown<String>(
              controller: _specialtyController,
              options: medicalSpecialties,
              onChanged: (val) {
                setState(() => _specialtyController.value = val);
                ref
                    .read(partnerSettingsControllerProvider.notifier)
                    .updateSpecialty(val);
              },
              textStyle: widget.theme.bodyMedium
                  .copyWith(overflow: TextOverflow.ellipsis),
              hintText: 'Select...',
              fillColor: widget.theme.secondaryBackground,
              elevation: 2,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 8,
              margin: const EdgeInsets.fromLTRB(12, 4, 0, 4),
              hidesUnderline: true,
            ),
          ),
        ),
        SettingsItem(
          icon: Icons.apartment_outlined,
          title: 'Clinic',
          trailing: SizedBox(
            width: 180,
            child: FlutterFlowDropDown<String>(
              controller: _clinicController,
              options: [
                'None',
                ...widget.settings.availableClinics.map((c) => c.id),
              ],
              optionLabels: [
                'None',
                ...widget.settings.availableClinics
                    .map((c) => c.fullName ?? 'Unnamed Clinic'),
              ],
              onChanged: (val) {
                setState(
                    () => _clinicController.value = val == 'None' ? null : val,);
                ref
                    .read(partnerSettingsControllerProvider.notifier)
                    .updateClinic(val == 'None' ? null : val);
              },
              textStyle: widget.theme.bodyMedium
                  .copyWith(overflow: TextOverflow.ellipsis),
              hintText: 'Select...',
              fillColor: widget.theme.secondaryBackground,
              elevation: 2,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 8,
              margin: const EdgeInsets.fromLTRB(12, 4, 0, 4),
              hidesUnderline: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingConfigurationSection extends ConsumerStatefulWidget {
  final dynamic settings;
  final FlutterFlowTheme theme;

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
            activeTrackColor: widget.theme.primary,
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
              backgroundColor: widget.theme.primaryBackground,
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
                  style: widget.theme.bodyMedium
                      .copyWith(color: widget.theme.secondaryText),
                )
              : SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: widget.theme.primaryBackground,
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
                  hintStyle: widget.theme.labelMedium,
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
        _WorkingHoursEditor(
          initialHours: settings.workingHours,
          onChanged: (newHours) {
            ref
                .read(partnerSettingsControllerProvider.notifier)
                .updateWorkingHours(newHours);
          },
        ),
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
    final theme = FlutterFlowTheme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SettingsGroup(
          title: FFLocalizations.of(context).getText('general'),
          children: [
            SettingsItem(
              icon: Icons.translate_rounded,
              title: FFLocalizations.of(context).getText('language'),
              trailing: DropdownButton<String>(
                value: FFLocalizations.of(context).languageCode,
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
                icon: Icon(Icons.arrow_drop_down, color: theme.secondaryText),
                dropdownColor: theme.secondaryBackground,
                style: theme.bodyMedium,
              ),
            ),
            SettingsItem(
              icon: Icons.brightness_6_outlined,
              title: FFLocalizations.of(context).getText('darkmode'),
              trailing: Switch.adaptive(
                value: isDarkMode,
                thumbColor: WidgetStateProperty.all(theme.primary),
                onChanged: (isDarkMode) {
                  final newMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
                  setDarkModeSetting(context, newMode);
                },
              ),
            ),
            SettingsItem(
              icon: Icons.contact_support_outlined,
              title: FFLocalizations.of(context).getText('contactus'),
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
              title: FFLocalizations.of(context).getText('privpolicy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushNamed(PrivacyPolicyPage.routeName),
            ),
            SettingsItem(
              icon: Icons.description_outlined,
              title: FFLocalizations.of(context).getText('termsserv'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.pushNamed(TermsOfServicePage.routeName),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkingHoursEditor extends StatefulWidget {
  final Map<String, List<String>> initialHours;
  final ValueChanged<Map<String, List<String>>> onChanged;

  const _WorkingHoursEditor({
    required this.initialHours,
    required this.onChanged,
  });

  @override
  State<_WorkingHoursEditor> createState() => _WorkingHoursEditorState();
}

class _WorkingHoursEditorState extends State<_WorkingHoursEditor> {
  late Map<String, List<String>> _hours;
  final Map<String, String> _daysOfWeek = {
    'Monday': '1',
    'Tuesday': '2',
    'Wednesday': '3',
    'Thursday': '4',
    'Friday': '5',
    'Saturday': '6',
    'Sunday': '7',
  };

  @override
  void initState() {
    super.initState();
    _hours = Map<String, List<String>>.from(widget.initialHours);
  }

  Future<void> _editTimeSlot(
    BuildContext context,
    String dayKey,
    int slotIndex,
  ) async {
    final parts = _hours[dayKey]![slotIndex].split('-');
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
      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = newEndTime.hour * 60 + newEndTime.minute;
      if (endMinutes <= startMinutes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        final formattedStart =
            '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
        final formattedEnd =
            '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';
        _hours[dayKey]![slotIndex] = '$formattedStart-$formattedEnd';
      });
      widget.onChanged(_hours);
    }
  }

  Future<void> _addTimeSlot(BuildContext context, String dayKey) async {
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
      final startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      final endMinutes = newEndTime.hour * 60 + newEndTime.minute;

      if (endMinutes <= startMinutes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End time must be after start time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        final formattedStart =
            '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';
        final formattedEnd =
            '${newEndTime.hour.toString().padLeft(2, '0')}:${newEndTime.minute.toString().padLeft(2, '0')}';
        if (!_hours.containsKey(dayKey)) {
          _hours[dayKey] = [];
        }
        _hours[dayKey]!.add('$formattedStart-$formattedEnd');
      });
      widget.onChanged(_hours);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Column(
        children: _daysOfWeek.entries.map((dayEntry) {
          final dayName = dayEntry.key;
          final dayKey = dayEntry.value;
          final isEnabled = _hours.containsKey(dayKey);

          return ExpansionTile(
            key: PageStorageKey(dayName),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            collapsedIconColor: FlutterFlowTheme.of(context).secondaryText,
            title: Text(dayName, style: FlutterFlowTheme.of(context).bodyLarge),
            trailing: Switch(
              value: isEnabled,
              onChanged: (enabled) {
                setState(() {
                  if (enabled) {
                    if (!_hours.containsKey(dayKey)) {
                      _hours[dayKey] = ['09:00-17:00'];
                    }
                  } else {
                    _hours.remove(dayKey);
                  }
                });
                widget.onChanged(_hours);
              },
              activeTrackColor: FlutterFlowTheme.of(context).primary,
            ),
            children: [
              if (isEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                  child: Column(
                    children: [
                      ...(_hours[dayKey] ?? []).asMap().entries.map((entry) {
                        final int idx = entry.key;
                        final String timeSlot = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeSlot,
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    onPressed: () =>
                                        _editTimeSlot(context, dayKey, idx),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _hours[dayKey]!.removeAt(idx);
                                        if (_hours[dayKey]!.isEmpty) {
                                          _hours.remove(dayKey);
                                        }
                                      });
                                      widget.onChanged(_hours);
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
                            foregroundColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Time Slot'),
                          onPressed: () => _addTimeSlot(context, dayKey),
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
  }
}

class _ClosedDaysEditor extends ConsumerStatefulWidget {
  final List<DateTime> closedDays;

  const _ClosedDaysEditor({required this.closedDays});

  @override
  ConsumerState<_ClosedDaysEditor> createState() => _ClosedDaysEditorState();
}

class _ClosedDaysEditorState extends ConsumerState<_ClosedDaysEditor> {
  bool _isAdding = false;

  Future<void> _addDay() async {
    final newDay = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDay != null &&
        !widget.closedDays.any((d) => d.isAtSameMomentAs(newDay))) {
      setState(() => _isAdding = true);
      try {
        await ref
            .read(partnerSettingsControllerProvider.notifier)
            .addClosedDay(newDay);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Day closed and patients have been notified.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error closing day: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isAdding = false);
        }
      }
    }
  }

  void _removeDay(DateTime day) {
    ref.read(partnerSettingsControllerProvider.notifier).removeClosedDay(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specific Closed Days', style: theme.titleMedium),
          const SizedBox(height: 16),
          widget.closedDays.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('You have no specific closed days scheduled.'),
                  ),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.closedDays
                      .map(
                        (day) => Chip(
                          label: Text(DateFormat.yMMMd().format(day)),
                          onDeleted: () => _removeDay(day),
                          deleteIconColor: theme.error,
                          backgroundColor: theme.primaryBackground,
                          labelStyle: theme.bodyMedium,
                        ),
                      )
                      .toList(),
                ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: theme.primary),
              icon: _isAdding
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Icon(Icons.add),
              label: Text(_isAdding ? 'Processing...' : 'Add a Closed Day'),
              onPressed: _isAdding ? null : _addDay,
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
            child: Text(FFLocalizations.of(context).getText('cancel')),
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
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
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
