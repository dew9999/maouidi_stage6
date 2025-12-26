// lib/features/partners/presentation/partner_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../backend/supabase/supabase.dart';
import '../data/partner_repository.dart';

part 'partner_providers.g.dart';

/// Parameters for filtering the partner list.
class PartnerListParams {
  final String category;
  final String? state;
  final String? specialty;

  const PartnerListParams({
    required this.category,
    this.state,
    this.specialty,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerListParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          state == other.state &&
          specialty == other.specialty;

  @override
  int get hashCode => Object.hash(category, state, specialty);
}

/// Provider for filtered partner list.
///
/// Returns a list of medical partners filtered by category, state, and specialty.
/// Uses Riverpod's automatic caching and invalidation.
@riverpod
Future<List<MedicalPartnersRow>> partnerList(
  PartnerListRef ref,
  PartnerListParams params,
) async {
  final repository = ref.watch(partnerRepositoryProvider);
  return repository.getFilteredPartners(
    category: params.category,
    state: params.state,
    specialty: params.specialty,
  );
}

/// Provider for partner search.
///
/// Returns a list of medical partners matching the search term.
/// Returns empty list for null or empty search terms.
@riverpod
Future<List<MedicalPartnersRow>> partnerSearch(
  PartnerSearchRef ref,
  String? searchTerm,
) async {
  if (searchTerm == null || searchTerm.isEmpty) {
    return [];
  }

  final repository = ref.watch(partnerRepositoryProvider);
  return repository.searchPartners(searchTerm);
}

/// Provider for featured partners on home screen.
///
/// Returns a list of top 6 partners ordered by rating.
/// Uses Riverpod's automatic caching and invalidation.
@riverpod
Future<List<MedicalPartnersRow>> featuredPartners(
  FeaturedPartnersRef ref,
) async {
  final repository = ref.watch(partnerRepositoryProvider);
  return repository.getFeaturedPartners();
}
