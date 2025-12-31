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
    String? specialty,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? availabilityFilter,
  }) async {
    try {
      // Start building the query
      // Note: 'search_partners' RPC is preferred if available,
      // but falling back to direct table query for reliability here.

      var dbQuery = _client.from('medical_partners').select();

      if (category != null && category.isNotEmpty) {
        dbQuery = dbQuery.eq('category', category);
      }

      if (specialty != null && specialty.isNotEmpty) {
        dbQuery = dbQuery.eq('specialty', specialty);
      }

      // Filter by minimum rating
      if (minRating != null) {
        dbQuery = dbQuery.gte('average_rating', minRating);
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
          // Check against wilaya field
          final wilaya = p.wilaya?.toLowerCase() ?? '';
          final address = p.address?.toLowerCase() ?? '';

          return wilaya.contains(loc) || address.contains(loc);
        }).toList();
      }

      // Filter by price range (homecare_price field)
      if (minPrice != null) {
        partners = partners.where((p) {
          final price = p.homecarePrice;
          return price != null && price >= minPrice;
        }).toList();
      }

      if (maxPrice != null) {
        partners = partners.where((p) {
          final price = p.homecarePrice;
          return price != null && price <= maxPrice;
        }).toList();
      }

      // Filter by availability (active partners only for now)
      // In the future, can check closed_days and working_hours
      if (availabilityFilter != null && availabilityFilter != 'any') {
        partners = partners.where((p) {
          final isActive = p.isActive ?? false;
          if (!isActive) return false;

          // For 'today' or 'this_week', check if today is not in closed_days
          if (availabilityFilter == 'today' ||
              availabilityFilter == 'this_week') {
            final closedDays = p.closedDays;
            final today = DateTime.now();

            if (closedDays.isNotEmpty) {
              // Check if today matches any closed day (date only, ignore time)
              final todayDate = DateTime(today.year, today.month, today.day);
              final isClosed = closedDays.any((closedDay) {
                final closedDate =
                    DateTime(closedDay.year, closedDay.month, closedDay.day);
                return closedDate.isAtSameMomentAs(todayDate);
              });
              if (isClosed) return false;
            }
          }

          return true;
        }).toList();
      }

      return partners;
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }
}
