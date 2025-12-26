// lib/partner_profile_page/partner_profile_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import '../features/partners/presentation/partner_providers.dart';

class PartnerProfilePageWidget extends ConsumerWidget {
  const PartnerProfilePageWidget({
    super.key,
    required this.partnerId,
  });

  final String? partnerId;

  static String routeName = 'PartnerProfilePage';
  static String routePath = '/partnerProfilePage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (partnerId == null || partnerId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ptrerr)),
        body: Center(
          child: Text(l10n.ptridmissing),
        ),
      );
    }

    final partnerAsync = ref.watch(partnerByIdProvider(partnerId!));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: partnerAsync.when(
        data: (partner) {
          if (partner == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partner not found',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: $partnerId',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Partner Name
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: colorScheme.primary,
                iconTheme: IconThemeData(color: colorScheme.onPrimary),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    partner.fullName ?? 'Partner',
                    style: textTheme.titleLarge
                        ?.copyWith(color: colorScheme.onPrimary),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Rating & Verification
                    _buildInfoCard(
                      colorScheme,
                      textTheme,
                      children: [
                        Row(
                          children: [
                            if (partner.isVerified == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              partner.averageRating?.toStringAsFixed(1) ??
                                  'N/A',
                              style: textTheme.titleMedium,
                            ),
                            Text(
                              ' (${partner.reviewCount ?? 0})',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location Information
                    _buildSectionTitle(textTheme, 'Location'),
                    _buildInfoCard(
                      colorScheme,
                      textTheme,
                      children: [
                        if (partner.wilaya != null)
                          _buildInfoRow(
                            Icons.location_on,
                            'Wilaya',
                            partner.wilaya!,
                            colorScheme,
                            textTheme,
                          ),
                        if (partner.address != null)
                          _buildInfoRow(
                            Icons.map,
                            'Address',
                            partner.address!,
                            colorScheme,
                            textTheme,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medical Information
                    _buildSectionTitle(textTheme, 'Medical Information'),
                    _buildInfoCard(
                      colorScheme,
                      textTheme,
                      children: [
                        if (partner.category != null)
                          _buildInfoRow(
                            Icons.category,
                            'Category',
                            partner.category!,
                            colorScheme,
                            textTheme,
                          ),
                        if (partner.specialty != null)
                          _buildInfoRow(
                            Icons.medical_services,
                            'Specialty',
                            partner.specialty!,
                            colorScheme,
                            textTheme,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bio (if available)
                    if (partner.bio != null && partner.bio!.isNotEmpty) ...[
                      _buildSectionTitle(textTheme, 'About'),
                      _buildInfoCard(
                        colorScheme,
                        textTheme,
                        children: [
                          Text(
                            partner.bio!,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Working Hours (if available)
                    if (partner.workingHours != null) ...[
                      _buildSectionTitle(textTheme, 'Working Hours'),
                      _buildInfoCard(
                        colorScheme,
                        textTheme,
                        children: [
                          Text(
                            partner.workingHours.toString(),
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Book Appointment Button
                    FilledButton.icon(
                      onPressed: () {
                        context.pushNamed(
                          'BookingPage',
                          queryParameters: {
                            'partnerId': partnerId!,
                            'isPartnerBooking': 'false',
                          },
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book Appointment'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading partner profile...',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    ref.invalidate(partnerByIdProvider(partnerId!)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(TextTheme textTheme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
