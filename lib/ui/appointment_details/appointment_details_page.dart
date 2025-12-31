import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maouidi/features/appointments/data/appointment_model.dart';
import 'package:maouidi/features/appointments/presentation/partner_dashboard_controller.dart';
import 'package:maouidi/features/patient/presentation/patient_dashboard_controller.dart';
import 'package:maouidi/core/utils/localization_mapper.dart';
import 'package:maouidi/core/services/app_config_service.dart';
import 'package:maouidi/features/payments/data/chargily_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/reviews/presentation/write_review_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  double _platformFee = 500.0;

  @override
  void initState() {
    super.initState();
    if (widget.appointment.negotiatedPrice != null) {
      _priceController.text = widget.appointment.negotiatedPrice.toString();
    }
    _loadPlatformFee();
  }

  Future<void> _loadPlatformFee() async {
    final fee = await ref.read(platformFeeProvider.future);
    if (mounted) setState(() => _platformFee = fee);
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
      await Supabase.instance.client.rpc(
        'propose_homecare_price',
        params: {
          'appointment_id_arg': widget.appointment.id,
          'price_arg': price,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price proposal sent to patient')),
        );
        context.pop();
        // Refresh appropriate controller
        if (widget.isPartnerView) {
          ref.refresh(
            partnerDashboardControllerProvider(widget.appointment.partnerId),
          );
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

      await Supabase.instance.client.rpc(
        rpcName,
        params: {
          'appointment_id_arg': widget.appointment.id,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        // ignore: unused_result
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
              if (status == 'pending_payment' && !widget.isPartnerView)
                _buildPaymentSection(theme)
              else
                _buildNegotiationSection(theme, negotiationStatus),
            ],
            // Review Button Section
            if (!widget.isPartnerView &&
                status == 'Completed' &&
                !widget.appointment.hasReview) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final success = await showDialog<bool>(
                      context: context,
                      builder: (context) => WriteReviewDialog(
                        appointment: widget.appointment,
                      ),
                    );

                    if (success == true && mounted) {
                      // Refresh dashboard to reflect changes
                      // ignore: unused_result
                      ref.refresh(patientDashboardControllerProvider);
                      // Force local state update (though refresh should handle it)
                      // Optionally pop or reload page
                      context.pop();
                    }
                  },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Write a Review'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _isSubmitting = true);
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      final chargilyService = ChargilyService(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
      );

      final response = await chargilyService.createCheckout(
        requestId: widget.appointment.id.toString(),
      );
      // Backend returns camelCase 'checkoutUrl', ensuring fallback just in case
      final checkoutUrl = response['checkoutUrl'] ?? response['checkout_url'];

      if (checkoutUrl != null) {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch payment URL';
        }
      } else {
        throw 'No checkout URL returned from server';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildPaymentSection(ThemeData theme) {
    final price = widget.appointment.negotiatedPrice ?? 0.0;
    final total = price + _platformFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Breakdown', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildDetailRow('Service Price', '$price DZD'),
          _buildDetailRow('Platform Fee', '$_platformFee DZD'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$total DZD',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _handlePayment,
              icon: const Icon(Icons.payment),
              label: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Pay Now with Chargily'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    const Color(0xFF0066FF), // Chargily Blue-ish or use Theme
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCounterOffer(double price) async {
    setState(() => _isSubmitting = true);
    try {
      final rpcName = widget.isPartnerView
          ? 'propose_homecare_price'
          : 'counter_offer_homecare_price';

      await Supabase.instance.client.rpc(
        rpcName,
        params: {
          'appointment_id_arg': widget.appointment.id,
          'price_arg': price,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counter offer sent!')),
        );
        // Refresh controllers
        if (widget.isPartnerView) {
          ref.refresh(
            partnerDashboardControllerProvider(widget.appointment.partnerId),
          );
        } else {
          ref.refresh(patientDashboardControllerProvider);
        }
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending counter offer: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCounterOfferDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Propose Counter Offer'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Your Price (DZD)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null && price > 0) {
                Navigator.pop(context);
                _submitCounterOffer(price);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String status, bool isHomecare) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                    LocalizationMapper.getStatus(status, context),
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
                  .format(widget.appointment.appointmentTime),
            ),
            _buildDetailRow(
              'Patient',
              widget.appointment.onBehalfOfPatientName ??
                  '${widget.appointment.patientFirstName ?? ""} ${widget.appointment.patientLastName ?? ""}',
            ),
            if (isHomecare) ...[
              const SizedBox(height: 12),
              const Text(
                'Homecare Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.appointment.caseDescription != null)
                _buildDetailRow('Case', widget.appointment.caseDescription!),
              if (widget.appointment.patientLocation != null)
                _buildDetailRow(
                  'Location',
                  widget.appointment.patientLocation!,
                ),
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
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
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

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Propose Price', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Enter the cost for this homecare visit to send specifically to the patient for approval.',
                  style: theme.textTheme.bodySmall,
                ),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Proposal'),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (negotiationStatus == 'pending_user_approval') {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.hourglass_top, color: Colors.orange, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Waiting for Patient Approval',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'You proposed: ${_priceController.text.isNotEmpty ? _priceController.text : widget.appointment.negotiatedPrice} DZD',
                ),
              ],
            ),
          ),
        );
      } else if (negotiationStatus == 'pending_partner_approval') {
        // Partner needs to respond to Patient's counter offer
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Counter Offer',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'The patient has proposed a counter-offer:',
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
                            : () => _handlePatientResponse(false), // Reject
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _showCounterOfferDialog(context),
                        child: const Text('Counter'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handlePatientResponse(true), // Accept
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

    // Patient View Logic
    if (!widget.isPartnerView) {
      if (negotiationStatus == 'pending_user_approval') {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                if (widget.appointment.negotiationRound != null &&
                    widget.appointment.negotiationRound! >= 5) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      'Final Offer',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
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
                    const SizedBox(width: 8),
                    // Only show Counter button if round < 5
                    if (widget.appointment.negotiationRound == null ||
                        widget.appointment.negotiationRound! < 5) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _showCounterOfferDialog(context),
                          child: const Text('Counter'),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
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
      } else if (negotiationStatus == 'pending_partner_approval') {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.hourglass_top, color: Colors.orange, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Waiting for Partner Response',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('You proposed: ${widget.appointment.negotiatedPrice} DZD'),
              ],
            ),
          ),
        );
      }
    }

    // Default or Fallback for other statuses
    if (widget.appointment.negotiatedPrice != null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
