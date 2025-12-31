import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/review_repository.dart';
import '../../appointments/data/appointment_model.dart';

class WriteReviewDialog extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const WriteReviewDialog({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends ConsumerState<WriteReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(reviewRepositoryProvider);

      await repository.submitReview(
        appointmentId: widget.appointment.id,
        rating: _rating,
        reviewText: _commentController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,),
        );
      }
    } catch (e) {
      if (mounted) {
        String message = 'Failed to submit review';
        if (e is ReviewException) {
          message = e.message;
        } else {
          message = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('Rate your experience:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () =>
                      setState(() => _rating = (index + 1).toDouble()),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Share your feedback (optional)',
                border: OutlineInputBorder(),
                hintText: 'How was the service?',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
