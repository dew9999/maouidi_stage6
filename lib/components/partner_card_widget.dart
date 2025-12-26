// lib/components/partner_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import '../core/constants.dart';

class PartnerCardWidget extends StatelessWidget {
  const PartnerCardWidget({
    super.key,
    required this.partner,
    this.showBookingButton = false,
  });

  final MedicalPartnersRow partner;
  final bool showBookingButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'PartnerProfilePage',
            queryParameters: {'partnerId': partner.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: colorScheme.shadow,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: partner.photoUrl ?? defaultAvatarUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 90,
                        height: 90,
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 90,
                        height: 90,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          partner.fullName ?? l10n.unnamedptr,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          partner.specialty ?? l10n.nospecialty,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              partner.averageRating?.toStringAsFixed(1) ??
                                  l10n.notavail,
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${partner.reviewCount ?? 0})',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showBookingButton)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FilledButton(
                    onPressed: () {
                      context.pushNamed(
                        'BookingPage',
                        queryParameters: {'partnerId': partner.id},
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      textStyle: textTheme.titleSmall,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(l10n.booknow),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
