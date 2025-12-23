import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../backend/supabase/database/tables/medical_partners.dart';

part 'search_repository.g.dart';

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepository(Supabase.instance.client);
}

class SearchRepository {
  final SupabaseClient _client;

  SearchRepository(this._client);

  /// Search for medical partners with optional filters.
  Future<List<MedicalPartnersRow>> searchPartners({
    String? query,
    String? category,
    String? location,
  }) async {
    try {
      // Start building the query
      // Note: 'search_partners' RPC is preferred if available,
      // but falling back to direct table query for reliability here.

      var dbQuery = _client.from('medical_partners').select();

      if (category != null && category.isNotEmpty) {
        dbQuery = dbQuery.eq('category', category);
      }

      // Execute query
      final data = await dbQuery;

      // Map to Row objects
      var partners = (data as List).map((e) => MedicalPartnersRow(e)).toList();

      // Apply Text Search & Location Filter in Dart (Memory)
      // This avoids SQL errors if columns don't exist
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        partners = partners.where((p) {
          final name = p.fullName?.toLowerCase() ?? '';
          final specialty = p.specialty?.toLowerCase() ?? '';
          return name.contains(q) || specialty.contains(q);
        }).toList();
      }

      if (location != null && location.isNotEmpty) {
        final loc = location.toLowerCase();
        partners = partners.where((p) {
          // FIX: Safely access data map for missing getters
          // Or check against 'address' if that exists
          final address = p.data['address']?.toString().toLowerCase() ?? '';
          final city = p.data['city']?.toString().toLowerCase() ?? '';
          final state = p.data['state']?.toString().toLowerCase() ?? '';

          return address.contains(loc) ||
              city.contains(loc) ||
              state.contains(loc);
        }).toList();
      }

      return partners;
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }
}
