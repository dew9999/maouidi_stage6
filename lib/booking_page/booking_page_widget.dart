// lib/booking_page/booking_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maouidi/core/extensions/extensions.dart';
import 'package:maouidi/features/bookings/data/booking_repository.dart';
import 'package:maouidi/features/bookings/presentation/booking_controller.dart';
import 'package:maouidi/features/bookings/presentation/booking_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

Future<Map<String, String>?> showHomecareDetailsDialog(
  BuildContext context,
) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final formKey = GlobalKey<FormState>();
  final caseController = TextEditingController();
  final locationController = TextEditingController();

  // Local state for the checkbox
  bool isLiabilityAccepted = false;

  return await showDialog<Map<String, String>?>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.hcdetails,
              style: textTheme.headlineSmall,
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: caseController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.casedesc,
                        labelStyle: textTheme.labelMedium,
                        hintText: AppLocalizations.of(context)!.casedescex,
                        hintStyle: textTheme.labelMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty
                          ? AppLocalizations.of(context)!.fieldreq
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fulladdr,
                        labelStyle: textTheme.labelMedium,
                        hintText: AppLocalizations.of(context)!.fulladdrex,
                        hintStyle: textTheme.labelMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                      validator: (v) => v == null || v.isEmpty
                          ? AppLocalizations.of(context)!.fieldreq
                          : null,
                    ),
                    const SizedBox(height: 24),
                    // Liability Disclaimer Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isLiabilityAccepted,
                            activeColor: colorScheme.primary,
                            onChanged: (bool? value) {
                              setState(() {
                                isLiabilityAccepted = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLiabilityAccepted = !isLiabilityAccepted;
                              });
                            },
                            child: Text(
                              'Maouidi is a connector. Responsibilities regarding medical care and safety lie solely between the Patient and the Partner.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(null),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: isLiabilityAccepted
                    ? () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(dialogContext).pop({
                            'case_description': caseController.text,
                            'patient_location': locationController.text,
                          });
                        }
                      }
                    : null, // Disabled if checkbox is not checked
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor:
                      colorScheme.onSurface.withOpacity(0.12),
                ),
                child: Text(AppLocalizations.of(context)!.submitreq),
              ),
            ],
          );
        },
      );
    },
  );
}

class BookingPageWidget extends ConsumerWidget {
  const BookingPageWidget({
    super.key,
    required this.partnerId,
    this.isPartnerBooking = false,
  });

  static String routeName = 'BookingPage';
  static String routePath = '/bookingPage';

  final String partnerId;
  final bool isPartnerBooking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(partnerId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.bookapptbar,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: bookingState.isLoadingPartner
            ? const Center(child: CircularProgressIndicator())
            : bookingState.partnerData == null
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.ptrnotconfig,
                    ),
                  )
                : _buildBookingView(
                    context,
                    ref,
                    bookingState,
                    partnerId,
                    isPartnerBooking,
                  ),
      ),
    );
  }

  Widget _buildBookingView(
    BuildContext context,
    WidgetRef ref,
    BookingState state,
    String partnerId,
    bool isPartnerBooking,
  ) {
    final partnerData = state.partnerData!;

    if (partnerData.bookingSystemType == 'number_based') {
      return _NumberQueueBookingView(
        partnerId: partnerId,
        partnerData: partnerData,
        isPartnerBooking: isPartnerBooking,
      );
    } else {
      return _TimeSlotBookingView(
        partnerId: partnerId,
        isPartnerBooking: isPartnerBooking,
      );
    }
  }
}

class _NumberQueueBookingView extends ConsumerWidget {
  const _NumberQueueBookingView({
    required this.partnerId,
    required this.partnerData,
    required this.isPartnerBooking,
  });

  final String partnerId;
  final PartnerBookingData partnerData;
  final bool isPartnerBooking;

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _bookAppointment(
    BuildContext context,
    WidgetRef ref, {
    String? onBehalfOfName,
    String? onBehalfOfPhone,
  }) async {
    final bookingState = ref.read(bookingControllerProvider(partnerId));
    final selectedDate = bookingState.selectedDate;

    Map<String, String>? homecareDetails;
    if (partnerData.category == 'Homecare' && !isPartnerBooking) {
      homecareDetails = await showHomecareDetailsDialog(context);
      if (homecareDetails == null) return;
    }

    try {
      final appointmentDateUTC = DateTime.utc(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      await ref
          .read(bookingControllerProvider(partnerId).notifier)
          .confirmBooking(
            partnerId: partnerId,
            appointmentTime: appointmentDateUTC,
            onBehalfOfName: onBehalfOfName,
            onBehalfOfPhone: onBehalfOfPhone,
            isPartnerOverride: isPartnerBooking,
            caseDescription: homecareDetails?['case_description'],
            patientLocation: homecareDetails?['patient_location'],
          );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            partnerData.category == 'Homecare'
                ? AppLocalizations.of(context)!.reqsent
                : AppLocalizations.of(context)!.gotnum,
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (context.mounted) context.pop();
    } catch (e) {
      if (!context.mounted) return;
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e is PostgrestException) {
        if (e.message.contains('You already have an active appointment')) {
          errorMessage = AppLocalizations.of(context)!.alrdyappt;
        } else if (e.message.contains('fully booked')) {
          errorMessage = 'This provider is fully booked today.';
        } else {
          errorMessage = e.message;
        }
      } else {
        errorMessage =
            'Could not connect to the server. Please check your internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookForPatientDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.bookforpatient,
          style: textTheme.titleLarge,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ptfullname,
                ),
                validator: (v) =>
                    v!.isEmpty ? AppLocalizations.of(context)!.fieldreq : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ptphone,
                ),
                validator: (v) =>
                    v!.isEmpty ? AppLocalizations.of(context)!.fieldreq : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                await _bookAppointment(
                  context,
                  ref,
                  onBehalfOfName: nameController.text,
                  onBehalfOfPhone: phoneController.text,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Text(AppLocalizations.of(context)!.submitreq),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bookingState = ref.watch(bookingControllerProvider(partnerId));
    final selectedDate = bookingState.selectedDate;

    final isDateInClosedDays =
        partnerData.closedDays.any((d) => isSameDay(d, selectedDate));

    final dayOfWeekKey = selectedDate.weekday.toString();
    final isWorkingDay = partnerData.workingHours.containsKey(dayOfWeekKey);

    final isPastDay = selectedDate.isBefore(DateTime.now().startOfDay);

    final bool isButtonDisabled =
        isDateInClosedDays || !isWorkingDay || isPastDay;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            enabledDayPredicate: (day) {
              // Disable past dates
              if (day.isBefore(DateTime.now().startOfDay)) {
                return false;
              }

              // Disable dates in closed_days array
              final isClosedDay =
                  partnerData.closedDays.any((d) => isSameDay(d, day));
              if (isClosedDay) {
                return false;
              }

              // Disable non-working days
              final dayOfWeekKey = day.weekday.toString();
              final isWorkingDay =
                  partnerData.workingHours.containsKey(dayOfWeekKey);

              return isWorkingDay;
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref
                  .read(bookingControllerProvider(partnerId).notifier)
                  .onDateSelected(selectedDay, partnerId);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              disabledDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              selectedTextStyle:
                  textTheme.titleSmall?.copyWith(color: Colors.white) ??
                      const TextStyle(color: Colors.white),
              todayTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              defaultTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              weekendTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              outsideTextStyle: textTheme.labelMedium ?? const TextStyle(),
              disabledTextStyle: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ) ??
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: textTheme.titleLarge ?? const TextStyle(),
              formatButtonVisible: false,
              titleCentered: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: textTheme.bodyLarge ?? const TextStyle(),
              weekendStyle: textTheme.bodyLarge ?? const TextStyle(),
            ),
          ),
        ),
        const Divider(thickness: 1, indent: 16, endIndent: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  partnerData.category == 'Homecare'
                      ? Icons.medical_services_outlined
                      : Icons.confirmation_number_outlined,
                  size: 60,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '${partnerData.category == 'Homecare' ? AppLocalizations.of(context)!.requestvisit : AppLocalizations.of(context)!.getnumberfor} for the day of:',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                Text(
                  DateFormat.yMMMMd().format(selectedDate),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppLocalizations.of(context)!.atpartner} ${partnerData.fullName}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const Spacer(),
                if (isPastDay)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.pastdateerr,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.error),
                    ),
                  )
                else if (isDateInClosedDays)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.closeddate,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.error),
                    ),
                  )
                else if (!isWorkingDay)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      AppLocalizations.of(context)!.notworkingday,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.error),
                    ),
                  ),
                FilledButton(
                  onPressed: isButtonDisabled
                      ? null
                      : () async {
                          if (isPartnerBooking) {
                            _showBookForPatientDialog(context, ref);
                          } else {
                            await _bookAppointment(context, ref);
                          }
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    isPartnerBooking
                        ? AppLocalizations.of(context)!.bookforpatient
                        : (partnerData.category == 'Homecare'
                            ? AppLocalizations.of(context)!.submithcreq
                            : AppLocalizations.of(context)!.getmynum),
                    style: textTheme.titleSmall
                        ?.copyWith(fontFamily: 'Inter', color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TimeSlotBookingView extends ConsumerWidget {
  const _TimeSlotBookingView({
    required this.partnerId,
    required this.isPartnerBooking,
  });

  final String partnerId;
  final bool isPartnerBooking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bookingState = ref.watch(bookingControllerProvider(partnerId));
    final selectedDate = bookingState.selectedDate;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            enabledDayPredicate: (day) {
              // Need to get partner data from booking state
              final bookingState =
                  ref.read(bookingControllerProvider(partnerId));
              final partnerData = bookingState.partnerData;

              if (partnerData == null) {
                return true; // Allow selection if no data yet
              }

              // Disable past dates
              if (day.isBefore(DateTime.now().startOfDay)) {
                return false;
              }

              // Disable dates in closed_days array
              final isClosedDay =
                  partnerData.closedDays.any((d) => isSameDay(d, day));
              if (isClosedDay) {
                return false;
              }

              // Disable non-working days
              final dayOfWeekKey = day.weekday.toString();
              final isWorkingDay =
                  partnerData.workingHours.containsKey(dayOfWeekKey);

              return isWorkingDay;
            },
            onDaySelected: (selectedDay, focusedDay) {
              ref
                  .read(bookingControllerProvider(partnerId).notifier)
                  .onDateSelected(selectedDay, partnerId);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              disabledDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              selectedTextStyle:
                  textTheme.titleSmall?.copyWith(color: Colors.white) ??
                      const TextStyle(color: Colors.white),
              todayTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              defaultTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              weekendTextStyle: textTheme.bodyMedium ?? const TextStyle(),
              outsideTextStyle: textTheme.labelMedium ?? const TextStyle(),
              disabledTextStyle: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ) ??
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: textTheme.titleLarge ?? const TextStyle(),
              formatButtonVisible: false,
              titleCentered: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: textTheme.bodyLarge ?? const TextStyle(),
              weekendStyle: textTheme.bodyLarge ?? const TextStyle(),
            ),
          ),
        ),
        const Divider(thickness: 1, indent: 16, endIndent: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _TimeSlotGrid(
              partnerId: partnerId,
              isPartnerBooking: isPartnerBooking,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSlotGrid extends ConsumerWidget {
  const _TimeSlotGrid({
    required this.partnerId,
    required this.isPartnerBooking,
  });

  final String partnerId;
  final bool isPartnerBooking;

  void _showBookForPatientDialog(
    BuildContext context,
    WidgetRef ref,
    TimeSlot slot,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.bookforpatient,
          style: textTheme.titleLarge,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ptfullname,
                ),
                validator: (v) =>
                    v!.isEmpty ? AppLocalizations.of(context)!.fieldreq : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.ptphone,
                ),
                validator: (v) =>
                    v!.isEmpty ? AppLocalizations.of(context)!.fieldreq : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                await _bookAppointment(
                  context,
                  ref,
                  slot,
                  onBehalfOfName: nameController.text,
                  onBehalfOfPhone: phoneController.text,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Text(AppLocalizations.of(context)!.submitreq),
          ),
        ],
      ),
    );
  }

  Future<void> _bookAppointment(
    BuildContext context,
    WidgetRef ref,
    TimeSlot slot, {
    String? onBehalfOfName,
    String? onBehalfOfPhone,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref
          .read(bookingControllerProvider(partnerId).notifier)
          .confirmBooking(
            partnerId: partnerId,
            appointmentTime: slot.time,
            onBehalfOfName: onBehalfOfName,
            onBehalfOfPhone: onBehalfOfPhone,
            isPartnerOverride: isPartnerBooking,
            caseDescription: null,
            patientLocation: null,
          );

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.apptcreated),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh slots by re-selecting the current date
      final currentState = ref.read(bookingControllerProvider(partnerId));
      ref
          .read(bookingControllerProvider(partnerId).notifier)
          .onDateSelected(currentState.selectedDate, partnerId);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      String errorMessage = 'An unexpected error occurred. Please try again.';
      if (e is PostgrestException) {
        if (e.message.contains('You already have an active appointment')) {
          errorMessage = AppLocalizations.of(context)!.alrdyappt;
        } else {
          errorMessage = AppLocalizations.of(context)!.slottaken;
        }
      } else {
        errorMessage =
            'Could not connect to the server. Please check your internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(partnerId));

    if (bookingState.isLoadingSlots) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (bookingState.availableSlots.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noslots,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final availableSlots = bookingState.availableSlots;
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.5,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        final bool isTappable = slot.status == SlotStatus.available;
        final colorScheme = Theme.of(context).colorScheme;
        Color buttonColor;
        switch (slot.status) {
          case SlotStatus.available:
            buttonColor = colorScheme.primary;
            break;
          case SlotStatus.booked:
            buttonColor = colorScheme.surfaceContainerHighest;
            break;
          case SlotStatus.inPast:
            buttonColor = colorScheme.onSurfaceVariant;
            break;
        }

        return FilledButton(
          onPressed: isTappable
              ? () async {
                  if (isPartnerBooking) {
                    _showBookForPatientDialog(context, ref, slot);
                  } else {
                    await _bookAppointment(context, ref, slot);
                  }
                }
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            backgroundColor: buttonColor,
            disabledBackgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 2.0,
          ),
          child: Text(
            DateFormat('HH:mm').format(slot.time.toLocal()),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontFamily: 'Inter', color: Colors.white),
          ),
        );
      },
    );
  }
}
