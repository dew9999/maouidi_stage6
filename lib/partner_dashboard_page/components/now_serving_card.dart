// lib/partner_dashboard_page/components/now_serving_card.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homecare_details_view.dart';
import 'dashboard_helpers.dart';

class NowServingCard extends StatelessWidget {
  const NowServingCard({
    super.key,
    required this.appointmentData,
    required this.onAction,
  });

  final Map<String, dynamic> appointmentData;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final client = Supabase.instance.client;
    final appointmentId = appointmentData['id'];

    final (displayName, _) = getPatientDisplayInfo(appointmentData);
    final appointmentNumber = appointmentData['appointment_number'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Now Serving',
              style: textTheme.labelLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    '$appointmentNumber',
                    style: textTheme.displaySmall
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayName,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            HomecareDetailsView(
              appointmentData: appointmentData,
              lightTheme: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await client.from('appointments').update(
                          {'status': 'NoShow'},
                        ).eq('id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                            context,
                            'Action failed: ${e.toString()}',
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: Colors.white.withAlpha(51),
                      foregroundColor: Colors.white,
                      textStyle: textTheme.titleSmall,
                    ),
                    child: const Text('No-Show'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () async {
                      try {
                        await client.from('appointments').update({
                          'status': 'Completed',
                          'completed_at': DateTime.now().toIso8601String(),
                        }).eq('id', appointmentId);
                        onAction();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorSnackbar(
                            context,
                            'Action failed: ${e.toString()}',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('Mark as Completed'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.primary,
                      textStyle: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
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
