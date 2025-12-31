import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/features/search/presentation/partner_search_controller.dart';
// Assuming medicalSpecialties list is here or similar

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // Local state to hold filter values before applying
  String? _selectedSpecialty;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double? _minRating;
  String? _availability;

  @override
  void initState() {
    super.initState();
    // Initialize from current provider state
    final searchState = ref.read(partnerSearchControllerProvider);
    _selectedSpecialty = searchState.specialtyFilter;

    final minPrice = searchState.minPrice ?? 0;
    final maxPrice = searchState.maxPrice ?? 10000;
    _priceRange = RangeValues(minPrice, maxPrice);

    _minRating = searchState.minRating;
    _availability = searchState.availabilityFilter;
  }

  void _applyFilters() {
    final notifier = ref.read(partnerSearchControllerProvider.notifier);

    notifier.updateSpecialtyFilter(_selectedSpecialty);

    // Only update price if it's different from default/full range
    if (_priceRange.start > 0 || _priceRange.end < 10000) {
      notifier.updatePriceRange(_priceRange.start, _priceRange.end);
    } else {
      notifier.updatePriceRange(null, null);
    }

    notifier.updateRatingFilter(_minRating);
    notifier.updateAvailabilityFilter(_availability);

    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedSpecialty = null;
      _priceRange = const RangeValues(0, 10000);
      _minRating = null;
      _availability = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fallback list if constants aren't available
    final specialties = [
      'Cardiologist',
      'Dentist',
      'Dermatologist',
      'General Practitioner',
      'Neurologist',
      'Pediatrician',
      'Psychiatrist',
      'Ophthalmologist',
      'Orthropedist',
      'Gynecologist',
    ];
    // Ideally import this from a constant file, e.g. medicalSpecialties

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.headlineSmall),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Specialty Dropdown
          Text('Specialty', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSpecialty,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            hint: const Text('Select specialty'),
            items: specialties
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => _selectedSpecialty = val),
          ),

          const SizedBox(height: 24),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price Range (DZD)', style: theme.textTheme.titleMedium),
              Text(
                '${_priceRange.start.round()} - ${_priceRange.end.round()}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000,
            divisions: 20,
            labels: RangeLabels(
              _priceRange.start.round().toString(),
              _priceRange.end.round().toString(),
            ),
            onChanged: (values) => setState(() => _priceRange = values),
          ),

          const SizedBox(height: 24),

          // Rating
          Text('Rating', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('4.5+'),
                selected: _minRating == 4.5,
                onSelected: (selected) =>
                    setState(() => _minRating = selected ? 4.5 : null),
              ),
              FilterChip(
                label: const Text('4.0+'),
                selected: _minRating == 4.0,
                onSelected: (selected) =>
                    setState(() => _minRating = selected ? 4.0 : null),
              ),
              FilterChip(
                label: const Text('3.0+'),
                selected: _minRating == 3.0,
                onSelected: (selected) =>
                    setState(() => _minRating = selected ? 3.0 : null),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Availability
          Text('Availability', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Today'),
                selected: _availability == 'today',
                onSelected: (selected) =>
                    setState(() => _availability = selected ? 'today' : null),
              ),
              FilterChip(
                label: const Text('This Week'),
                selected: _availability == 'this_week',
                onSelected: (selected) => setState(
                    () => _availability = selected ? 'this_week' : null,),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Show Results'),
            ),
          ),
        ],
      ),
    );
  }
}
