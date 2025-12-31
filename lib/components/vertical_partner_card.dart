// lib/components/vertical_partner_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maouidi/backend/supabase/supabase.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import '../core/utils/localization_mapper.dart';
import '../core/constants.dart';

/// Vertical Partner Card - Premium design for featured partners
class VerticalPartnerCard extends StatefulWidget {
  const VerticalPartnerCard({
    super.key,
    required this.partner,
  });

  final MedicalPartnersRow partner;

  @override
  State<VerticalPartnerCard> createState() => _VerticalPartnerCardState();
}

class _VerticalPartnerCardState extends State<VerticalPartnerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 8.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            context.pushNamed(
              'PartnerProfilePage',
              queryParameters: {'partnerId': widget.partner.id},
            );
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.15),
                        blurRadius: _elevationAnimation.value * 2,
                        offset: Offset(0, _elevationAnimation.value),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: _elevationAnimation.value,
                        offset: Offset(0, _elevationAnimation.value / 2),
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with Gradient Overlay
                  SizedBox(
                    height: 180,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Partner Image
                        CachedNetworkImage(
                          imageUrl: widget.partner.photoUrl ?? defaultAvatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceVariant,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary.withOpacity(0.3),
                                  colorScheme.tertiary.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        // Gradient Overlay for Better Text Contrast
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Rating Badge - Floating on Image
                        if (widget.partner.averageRating != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E40AF),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.partner.averageRating!
                                        .toStringAsFixed(1),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Partner Details with Enhanced Styling
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.surface,
                            colorScheme.surface.withOpacity(0.98),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                widget.partner.fullName ?? l10n.unnamedptr,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Specialty with Icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_information_rounded,
                                    size: 14,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.partner.specialty != null
                                          ? LocalizationMapper.getSpecialty(
                                              widget.partner.specialty!,
                                              context,)
                                          : l10n.nospecialty,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Wilaya / Location
                              if (widget.partner.wilaya != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color:
                                          colorScheme.primary.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        LocalizationMapper.getState(
                                            widget.partner.wilaya!, context,),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          // Review Count with Enhanced Styling
                          if (widget.partner.reviewCount != null &&
                              widget.partner.reviewCount! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reviews_rounded,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.partner.reviewCount} reviews',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
