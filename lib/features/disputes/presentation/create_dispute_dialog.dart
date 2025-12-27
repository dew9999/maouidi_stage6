// lib/features/disputes/presentation/create_dispute_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dispute_service.dart';
import '../../../core/providers/supabase_provider.dart';

/// Dialog for creating a dispute
class CreateDisputeDialog extends ConsumerStatefulWidget {
  const CreateDisputeDialog({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  ConsumerState<CreateDisputeDialog> createState() =>
      _CreateDisputeDialogState();
}

class _CreateDisputeDialogState extends ConsumerState<CreateDisputeDialog> {
  String _selectedReason = 'service_not_delivered';
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final Map<String, String> _disputeReasons = {
    'service_not_delivered': 'Service was not delivered',
    'poor_quality': 'Poor quality of service',
    'unprofessional': 'Unprofessional behavior',
    'overcharged': 'Overcharged/wrong price',
    'safety_concern': 'Safety concerns',
    'other': 'Other',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final disputeService = DisputeService(supabase);
      final userId = supabase.auth.currentUser!.id;

      await disputeService.createDispute(
        requestId: widget.requestId,
        raisedBy: userId,
        reason: _selectedReason,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute created. Our team will investigate.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.report_problem, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          const Text('Report an Issue'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will freeze the partner\'s payout until resolved',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'What went wrong?',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Reason Dropdown
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _disputeReasons.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedReason = value);
                }
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Please describe the issue in detail',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Provide as much detail as possible...',
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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitDispute,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit Dispute'),
        ),
      ],
    );
  }
}
