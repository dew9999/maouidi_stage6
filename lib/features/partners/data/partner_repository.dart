// lib/features/partners/data/partner_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../backend/supabase/supabase.dart';
import '../../../core/providers/supabase_provider.dart';

part 'partner_repository.g.dart';

/// Repository for partner-related database operations.
///
/// Provides clean interface for partner discovery and slot availability.
class PartnerRepository {
  final SupabaseClient _supabase;

  PartnerRepository(this._supabase);

  /// Get filtered partners by category, state, and specialty.
  ///
  /// Calls the `get_filtered_partners` RPC function from schema.sql.
  /// Returns a list of verified medical partners matching the criteria.
  Future<List<MedicalPartnersRow>> getFilteredPartners({
    required String category,
    String? state,
    String? specialty,
  }) async {
    final response = await _supabase.rpc(
      'get_filtered_partners',
      params: {
        'category_arg': category,
        'state_arg': state,
        'specialty_arg': specialty,
      },
    );

    return (response as List)
        .map((data) => MedicalPartnersRow(data as Map<String, dynamic>))
        .toList();
  }

  /// Search partners by search term.
  ///
  /// Calls the `search_partners` RPC function which uses full-text search.
  /// Returns a list of verified medical partners matching the search term.
  Future<List<MedicalPartnersRow>> searchPartners(String? searchTerm) async {
    final response = await _supabase.rpc(
      'search_partners',
      params: {
        'search_term': searchTerm ?? '',
      },
    );

    return (response as List)
        .map((data) => MedicalPartnersRow(data as Map<String, dynamic>))
        .toList();
  }

  /// Get available time slots for a partner on a specific date.
  ///
  /// Calls the `get_available_slots` RPC function.
  /// Returns a list of available appointment times.
  Future<List<DateTime>> getAvailableSlots({
    required String partnerId,
    required DateTime date,
  }) async {
    final response = await _supabase.rpc(
      'get_available_slots',
      params: {
        'partner_id_arg': partnerId,
        'day_arg': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      },
    );

    return (response as List)
        .map((slot) => DateTime.parse(slot['available_slot'] as String))
        .toList();
  }

  /// Get featured partners for home screen display.
  ///
  /// Returns top 6 partners ordered by average rating.
  /// Only returns verified partners.
  Future<List<MedicalPartnersRow>> getFeaturedPartners() async {
    final response = await _supabase
        .from('medical_partners')
        .select()
        .eq('is_verified', true)
        .order('average_rating', ascending: false)
        .limit(6);

    return (response as List)
        .map((data) => MedicalPartnersRow(data as Map<String, dynamic>))
        .toList();
  }

  /// Get a single partner by ID.
  ///
  /// Returns partner details for the profile page.
  Future<MedicalPartnersRow?> getPartnerById(String partnerId) async {
    final response = await _supabase
        .from('medical_partners')
        .select()
        .eq('id', partnerId)
        .maybeSingle();

    if (response == null) return null;
    return MedicalPartnersRow(response);
  }
}

/// Provider for the PartnerRepository.
@riverpod
PartnerRepository partnerRepository(PartnerRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PartnerRepository(supabase);
}
