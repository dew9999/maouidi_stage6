// lib/features/payments/presentation/cancellation_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_providers.dart';

/// Dialog for cancelling a homecare request with refund preview
class CancellationDialog extends ConsumerStatefulWidget {
  const CancellationDialog({
    super.key,
    required this.requestId,
    required this.cancelledBy,
  });

  final String requestId;
  final String cancelledBy; // 'patient' or 'partner'

  @override
  ConsumerState<CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends ConsumerState<CancellationDialog> {
  final _reasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _processCancel() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a cancellation reason')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final refundService = await ref.read(refundServiceProvider.future);
      await refundService.processRefund(
        requestId: widget.requestId,
        cancelledBy: widget.cancelledBy,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true); // Return true to indicate success

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request cancelled and refund processed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FutureBuilder(
      future: ref
          .read(refundServiceProvider.future)
          .then((service) => service.calculateRefundAmount(
                requestId: widget.requestId,
                cancelledBy: widget.cancelledBy,
              )),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to calculate refund: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final refundInfo = snapshot.data!;
        final isRefundable = refundInfo['refundable'] as bool;
        final refundAmount =
            (refundInfo['refund_amount'] as num?)?.toDouble() ?? 0;
        final refundPercentage = refundInfo['refund_percentage'] as int? ?? 0;
        final reason = refundInfo['reason'] as String;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 12),
              const Text('Cancel Request'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Refund Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isRefundable ? Colors.blue.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRefundable
                          ? Colors.blue.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refund Information',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isRefundable
                              ? Colors.blue.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isRefundable) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Refund Amount:', style: textTheme.bodyMedium),
                            Text(
                              '${refundAmount.toStringAsFixed(2)} DA',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Refund:', style: textTheme.bodyMedium),
                            Text(
                              '$refundPercentage%',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        reason,
                        style: textTheme.bodySmall?.copyWith(
                          color: isRefundable
                              ? Colors.blue.shade800
                              : Colors.red.shade800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isRefundable) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This action cannot be undone and no refund will be issued.',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Reason TextField
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Cancellation Reason *',
                    hintText: 'Please explain why you\'re cancelling...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Keep Request'),
            ),
            FilledButton(
              onPressed: _isProcessing ? null : _processCancel,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm Cancellation'),
            ),
          ],
        );
      },
    );
  }
}
