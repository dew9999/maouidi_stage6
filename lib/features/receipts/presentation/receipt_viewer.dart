// lib/features/receipts/presentation/receipt_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../providers/receipt_providers.dart';

/// Widget for viewing and sharing receipts
class ReceiptViewer extends ConsumerWidget {
  const ReceiptViewer({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final receiptData = ref.watch(receiptDataProvider(requestId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Receipt',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: receiptData.when(
        data: (receipt) {
          if (receipt == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No receipt available yet',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Receipt will be generated after payment',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        final service = ref.read(receiptServiceProvider);
                        final file =
                            await service.generateReceipt(requestId: requestId);

                        if (!context.mounted) return;

                        // Show preview
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreview(
                              build: (format) => file.readAsBytes(),
                            ),
                          ),
                        );

                        // Refresh receipt data
                        ref.invalidate(receiptDataProvider(requestId));
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error generating receipt: $e'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.receipt),
                    label: const Text('Generate Receipt'),
                  ),
                ],
              ),
            );
          }

          final receiptNumber = receipt['receipt_number'] as String;
          final servicePrice = (receipt['service_price'] as num).toDouble();
          final platformFee = (receipt['platform_fee'] as num).toDouble();
          final totalPaid = (receipt['total_paid'] as num).toDouble();
          final partnerAmount = (receipt['partner_amount'] as num).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Receipt Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Payment Successful',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Receipt #$receiptNumber',
                                style: textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'PAYMENT BREAKDOWN',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPriceRow(
                          'Service Price:',
                          servicePrice,
                          textTheme,
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow(
                          'Platform Fee:',
                          platformFee,
                          textTheme,
                          isHighlighted: true,
                        ),
                        const Divider(height: 32, thickness: 2),
                        _buildPriceRow(
                          'TOTAL PAID:',
                          totalPaid,
                          textTheme,
                          isTotal: true,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PARTNER PAYOUT',
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPriceRow(
                                'To be paid:',
                                partnerAmount,
                                textTheme,
                              ),
                              _buildPriceRow(
                                'Platform keeps:',
                                platformFee,
                                textTheme,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final service = ref.read(receiptServiceProvider);
                            final file = await service.generateReceipt(
                              requestId: requestId,
                            );

                            if (!context.mounted) return;

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfPreview(
                                  build: (format) => file.readAsBytes(),
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('View PDF'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          try {
                            final service = ref.read(receiptServiceProvider);
                            final file = await service.generateReceipt(
                              requestId: requestId,
                            );

                            await Printing.sharePdf(
                              bytes: await file.readAsBytes(),
                              filename: '$receiptNumber.pdf',
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    TextTheme textTheme, {
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
                  color: Colors.green.shade700,
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
