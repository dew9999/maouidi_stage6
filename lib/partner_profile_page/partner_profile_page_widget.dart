// lib/partner_profile_page/partner_profile_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import '../features/partners/presentation/partner_providers.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../features/partners/data/partner_repository.dart';
import '../../backend/supabase/database/tables/medical_partners.dart';
import 'components/reviews_widget.dart';

class PartnerProfilePageWidget extends ConsumerStatefulWidget {
  const PartnerProfilePageWidget({
    super.key,
    required this.partnerId,
  });

  final String? partnerId;

  static String routeName = 'PartnerProfilePage';
  static String routePath = '/partnerProfilePage';

  @override
  ConsumerState<PartnerProfilePageWidget> createState() =>
      _PartnerProfilePageWidgetState();
}

class _PartnerProfilePageWidgetState
    extends ConsumerState<PartnerProfilePageWidget> {
  bool _isEditing = false;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _wilayaController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
    _wilayaController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _addressController.dispose();
    _wilayaController.dispose();
    super.dispose();
  }

  void _enterEditMode(dynamic settings) {
    _bioController.text = settings.bio ?? '';
    _addressController.text = settings.location ?? '';
    _wilayaController.text = settings.state ?? '';
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final notifier = ref.read(partnerSettingsControllerProvider.notifier);
      await notifier.updateBio(_bioController.text);
      await notifier.updateClinic(_addressController.text);
      await notifier.updateState(_wilayaController.text);
      await notifier.saveAllSettings();

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Check if current user is the owner
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isOwner =
        widget.partnerId != null && currentUser?.id == widget.partnerId;

    if (widget.partnerId == null || widget.partnerId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ptrerr)),
        body: Center(child: Text(l10n.ptridmissing)),
      );
    }

    // Owner View
    if (isOwner) {
      final settingsAsync = ref.watch(partnerSettingsControllerProvider);
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: settingsAsync.when(
          data: (settings) => _buildContent(
            context,
            isOwner: true,
            data: settings,
            theme: theme,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      );
    }

    // Public View
    final partnerAsync = ref.watch(partnerByIdProvider(widget.partnerId!));
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: partnerAsync.when(
        data: (partner) {
          if (partner == null) return const Center(child: Text('Not found'));
          return _buildContent(
            context,
            isOwner: false,
            data: partner,
            theme: theme,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isOwner,
    required dynamic data,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Normalize data fields
    final String fullName =
        isOwner ? data.fullName : (data.fullName ?? 'Partner');
    final String? bio = isOwner ? data.bio : data.bio;
    final String? address = isOwner ? data.location : data.address;
    // Map wilaya using LocalizationMapper
    final String? rawWilaya = isOwner ? data.state : data.wilaya;
    final String? wilaya = rawWilaya != null ? rawWilaya : null;

    final String? category = isOwner ? data.category : data.category;
    // Map specialty using LocalizationMapper
    final String? rawSpecialty = isOwner ? data.specialty : data.specialty;
    final String? specialty = rawSpecialty != null ? rawSpecialty : null;
    // Handle differences in working hours structure if necessary,
    // but assuming toString() or basic display is enough for now.
    // PartnerSettingsState has 'workingHours' (Map), MedicalPartner has 'workingHours' (Map or String).
    final workingHours = data.workingHours;

    // Verification concept exists in both?
    // settings might not have isVerified exposed directly in state?
    // Let's assume public view provided verified status.
    // For owner, we might not show verified badge or fetch it separately.
    // Checking settings_state.dart... it doesn't seem to have isVerified.
    // So if owner, we might miss that badge, which is fine for editing mode.
    final bool isVerified = !isOwner &&
        (data.isVerified == true); // Only available in public data for now

    // Ratings
    final String rating =
        !isOwner ? (data.averageRating?.toStringAsFixed(1) ?? 'N/A') : 'N/A';
    final int reviewCount = !isOwner ? (data.reviewCount ?? 0) : 0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          actions: isOwner
              ? [
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveChanges,
                      tooltip: 'Save Changes',
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _enterEditMode(data),
                      tooltip: 'Edit Profile',
                    ),
                ]
              : null,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              fullName,
              style:
                  textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
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
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Rating / Verification Row (Public only mostly)
              if (!isOwner || isVerified)
                _buildInfoCard(
                  colorScheme,
                  textTheme,
                  children: [
                    Row(
                      children: [
                        if (isVerified) ...[
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
                        ],
                        if (!isOwner) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(rating, style: textTheme.titleMedium),
                          Text(
                            ' ($reviewCount)',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              if (!isOwner || isVerified) const SizedBox(height: 16),

              // Location Section
              _buildSectionTitle(textTheme, 'Location'),
              _buildInfoCard(
                colorScheme,
                textTheme,
                children: [
                  if (_isEditing) ...[
                    TextField(
                      controller: _wilayaController,
                      decoration: const InputDecoration(
                        labelText: 'Wilaya (State)',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                  ] else ...[
                    if (wilaya != null)
                      _buildInfoRow(
                        Icons.location_city,
                        'Wilaya',
                        wilaya,
                        colorScheme,
                        textTheme,
                      ),
                    if (address != null)
                      _buildInfoRow(
                        Icons.map,
                        'Address',
                        address,
                        colorScheme,
                        textTheme,
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Bio Section (Moved here as per requirement: "Above Working Hours")
              if (_isEditing || (bio != null && bio.isNotEmpty)) ...[
                _buildSectionTitle(textTheme, 'About'),
                _buildInfoCard(
                  colorScheme,
                  textTheme,
                  children: [
                    if (_isEditing)
                      TextField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter your bio...',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(bio!, style: textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Medical Information (Category, Specialty)
              _buildSectionTitle(textTheme, 'Medical Information'),
              _buildInfoCard(
                colorScheme,
                textTheme,
                children: [
                  if (category != null)
                    _buildInfoRow(
                      Icons.category,
                      'Category',
                      category,
                      colorScheme,
                      textTheme,
                    ),
                  if (specialty != null)
                    _buildInfoRow(
                      Icons.medical_services,
                      'Specialty',
                      specialty,
                      colorScheme,
                      textTheme,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Working Hours
              if (workingHours != null) ...[
                _buildSectionTitle(textTheme, 'Working Hours'),
                _buildInfoCard(
                  colorScheme,
                  textTheme,
                  children: [
                    // Simple display for now, can be sophisticated later
                    Text(
                      workingHours.toString(),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Associated Doctors (For Clinics)
              FutureBuilder<List<MedicalPartnersRow>>(
                future: ref
                    .read(partnerRepositoryProvider)
                    .getDoctorsForClinic(widget.partnerId!),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final doctors = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(textTheme, 'Our Doctors'),
                        SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: doctors.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      PartnerProfilePageWidget.routeName,
                                      queryParameters: {'partnerId': doctor.id},
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: doctor.photoUrl !=
                                                  null
                                              ? NetworkImage(doctor.photoUrl!)
                                              : null,
                                          child: doctor.photoUrl == null
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          doctor.fullName ?? 'Doctor',
                                          style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          doctor.specialty ?? '',
                                          style: textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Reviews (Public only, or Owner view of reviews)
              _buildSectionTitle(textTheme, 'Patient Reviews'),
              ReviewsWidget(partnerId: widget.partnerId!),
              const SizedBox(height: 16),

              if (!isOwner) ...[
                FilledButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      'BookingPage',
                      queryParameters: {
                        'partnerId': widget.partnerId!,
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
              ],
            ]),
          ),
        ),
      ],
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
