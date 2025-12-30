import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maouidi/features/appointments/data/appointment_model.dart';
import 'package:maouidi/features/appointments/presentation/partner_dashboard_controller.dart';
import 'package:maouidi/features/patient/presentation/patient_dashboard_controller.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

class AppointmentDetailsPage extends ConsumerStatefulWidget {
  final AppointmentModel appointment;
  final bool isPartnerView;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
    required this.isPartnerView,
  });

  static const routeName = 'AppointmentDetailsPage';
  static const routePath = '/appointmentDetails';

  @override
  ConsumerState<AppointmentDetailsPage> createState() =>
      _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState
    extends ConsumerState<AppointmentDetailsPage> {
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointment.negotiatedPrice != null) {
      _priceController.text = widget.appointment.negotiatedPrice.toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Confirmed':
      case 'Completed':
        return Colors.green;
      case 'Pending':
      case 'pending':
      case 'pending_user_approval':
        return Colors.orange;
      case 'Cancelled':
      case 'Cancelled_ByUser':
      case 'Cancelled_ByPartner':
      case 'negotiation_failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitPriceProposal() async {
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.rpc('propose_homecare_price', params: {
        'appointment_id_arg': widget.appointment.id,
        'price_arg': price,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price proposal sent to patient')),
        );
        context.pop();
        // Refresh appropriate controller
        if (widget.isPartnerView) {
          ref.refresh(
              partnerDashboardControllerProvider(widget.appointment.partnerId));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting proposal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handlePatientResponse(bool accepted) async {
    setState(() => _isSubmitting = true);

    try {
      final rpcName =
          accepted ? 'accept_homecare_price' : 'reject_homecare_price';
      final successMessage = accepted
          ? 'Price accepted! Appointment confirmed.'
          : 'Price rejected. Appointment cancelled.';

      await Supabase.instance.client.rpc(rpcName, params: {
        'appointment_id_arg': widget.appointment.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        ref.refresh(patientDashboardControllerProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.appointment.status;
    final negotiationStatus = widget.appointment.negotiationStatus;

    // Determine the actual display status for homecare specific logic
    final isHomecare = widget.appointment.bookingType == 'homecare' ||
        widget.appointment.caseDescription != null;
    // Fallback check as bookingType might not be populated in old data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(theme, status, isHomecare),
            if (isHomecare) ...[
              const SizedBox(height: 24),
              _buildNegotiationSection(theme, negotiationStatus),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String status, bool isHomecare) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment #${widget.appointment.appointmentNumber ?? widget.appointment.id}',
                  style: theme.textTheme.titleMedium,
                ),
                Chip(
                  label: Text(
                    status.replaceAll('_', ' '),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(context, status),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow(
                'Date',
                DateFormat.yMMMd()
                    .add_jm()
                    .format(widget.appointment.appointmentTime)),
            _buildDetailRow(
                'Patient',
                widget.appointment.onBehalfOfPatientName ??
                    '${widget.appointment.patientFirstName ?? ""} ${widget.appointment.patientLastName ?? ""}'),
            if (isHomecare) ...[
              const SizedBox(height: 12),
              const Text('Homecare Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (widget.appointment.caseDescription != null)
                _buildDetailRow('Case', widget.appointment.caseDescription!),
              if (widget.appointment.patientLocation != null)
                _buildDetailRow(
                    'Location', widget.appointment.patientLocation!),
              if (widget.appointment.homecareAddress != null)
                _buildDetailRow('Address', widget.appointment.homecareAddress!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNegotiationSection(ThemeData theme, String negotiationStatus) {
    // Partner View Logic
    if (widget.isPartnerView) {
      if (negotiationStatus == 'none' || negotiationStatus == 'pending') {
        // 'pending' here in DB might mean pending proposed price or active negotiation.
        // The user requirement says: "allow the Partner to input a 'Proposed Price' and submit. Update status to pending_user_approval."
        // So initially it might be 'pending' (booking request sent), waiting for partner to propose price.

        return Card(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Propose Price', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                    'Enter the cost for this homecare visit to send specifically to the patient for approval.',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price (DZD)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submitPriceProposal,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Proposal'),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (negotiationStatus == 'pending_user_approval') {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.hourglass_top, color: Colors.orange, size: 40),
                const SizedBox(height: 16),
                Text('Waiting for Patient Approval',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('You proposed: ${_priceController.text} DZD'),
              ],
            ),
          ),
        );
      }
    }

    // Patient View Logic
    if (!widget.isPartnerView) {
      if (negotiationStatus == 'pending_user_approval') {
        return Card(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Proposal', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                Text(
                  'The partner has proposed a price for this service:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.appointment.negotiatedPrice} DZD',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handlePatientResponse(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handlePatientResponse(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    // Default or Fallback for other statuses
    if (widget.appointment.negotiatedPrice != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Agreed Price:'),
              Text(
                '${widget.appointment.negotiatedPrice} DZD',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
