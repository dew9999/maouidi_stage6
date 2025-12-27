// lib/features/payments/presentation/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../providers/payment_providers.dart';

/// Payment screen showing price breakdown and payment agreement
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.requestId,
    required this.negotiatedPrice,
    required this.platformFee,
  });

  final String requestId;
  final double negotiatedPrice;
  final double platformFee; // 500 DA

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _agreedToTerms = false;
  bool _isProcessing = false;

  double get totalAmount => widget.negotiatedPrice + widget.platformFee;

  Future<void> _proceedToPayment() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.agreetoterms),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final chargilyService = await ref.read(chargilyServiceProvider.future);

      // Create checkout session
      final checkout = await chargilyService.createCheckout(
        requestId: widget.requestId,
        amount: totalAmount,
        successUrl:
            'https://yourapp.com/payment/success?request_id=${widget.requestId}',
        failureUrl: 'https://yourapp.com/payment/failed',
        webhookUrl: 'https://yourapp.com/webhooks/chargily',
        metadata: {
          'negotiated_price': widget.negotiatedPrice,
          'platform_fee': widget.platformFee,
        },
      );

      // Get checkout URL
      final checkoutUrl = checkout['checkout_url'] as String?;
      if (checkoutUrl == null) {
        throw Exception('No checkout URL returned');
      }

      // Open Chargily payment page
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch payment URL');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Payment',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Complete Your Payment',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review the price breakdown below',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Price Breakdown Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICE BREAKDOWN',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPriceRow(
                      'Service Price',
                      widget.negotiatedPrice,
                      textTheme,
                      colorScheme,
                    ),
                    const Divider(height: 24),
                    _buildPriceRow(
                      'Platform Fee',
                      widget.platformFee,
                      textTheme,
                      colorScheme,
                      isHighlighted: true,
                    ),
                    const Divider(height: 24, thickness: 2),
                    _buildPriceRow(
                      'TOTAL AMOUNT',
                      totalAmount,
                      textTheme,
                      colorScheme,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Platform Fee Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The 500 DA platform fee helps us maintain the service and ensure quality care.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Agreement Checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _agreedToTerms
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    width: _agreedToTerms ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() => _agreedToTerms = value ?? false);
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'I agree to pay ${totalAmount.toStringAsFixed(2)} DA for this homecare service',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Pay Now Button
              FilledButton(
                onPressed: _isProcessing ? null : _proceedToPayment,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor: colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Pay Now - ${totalAmount.toStringAsFixed(2)} DA',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                'Secure payment powered by Chargily',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    bool isTotal = false,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : textTheme.bodyLarge,
        ),
        Text(
          '${isHighlighted ? '+' : ''}${amount.toStringAsFixed(2)} DA',
          style: isTotal
              ? textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                )
              : isHighlighted
                  ? textTheme.titleMedium?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    )
                  : textTheme.titleMedium,
        ),
      ],
    );
  }
}
