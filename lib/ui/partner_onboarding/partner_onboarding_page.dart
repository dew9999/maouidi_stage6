import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class PartnerOnboardingPage extends ConsumerStatefulWidget {
  const PartnerOnboardingPage({super.key});

  static const routeName = 'PartnerOnboarding';
  static const routePath = '/partnerOnboarding';

  @override
  ConsumerState<PartnerOnboardingPage> createState() =>
      _PartnerOnboardingPageState();
}

class _PartnerOnboardingPageState extends ConsumerState<PartnerOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _licenseController = TextEditingController();

  String? _selectedSpecialty;
  String? _selectedClinicId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _clinics = [];
  bool _isLoadingClinics = true;
  String? _partnerCategory; // Store category to filter specialties

  // Homecare allowed specialties
  static const _homecareSpecialties = [
    'General Medicine',
    'Nursing',
    'Relaxing Massage',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPartnerData();
  }

  Future<void> _fetchPartnerData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Fetch clinics
      final clinicsResponse = await Supabase.instance.client
          .from('medical_partners')
          .select('id, full_name')
          .eq('category', 'Clinics');

      // Fetch current partner category
      final partnerResponse = await Supabase.instance.client
          .from('medical_partners')
          .select('category')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _clinics = List<Map<String, dynamic>>.from(clinicsResponse);
          _partnerCategory = partnerResponse?['category'] as String?;
          _isLoadingClinics = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoadingClinics = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a specialty'),
            backgroundColor: Colors.red,),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await Supabase.instance.client.from('medical_partners').update({
        'specialty': _selectedSpecialty,
        'parent_clinic_id': _selectedClinicId,
        'national_id_number': _nationalIdController.text.trim(),
        'medical_license_number': _licenseController.text.trim(),
      }).eq('id', user.id);

      if (mounted) {
        // Force refresh or navigation
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hardcoded strings for now or add to localizations later if needed,
    // sticking to basic structure as requested.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Setup'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Finish Setting Up Your Profile',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'These details are permanent and cannot be changed later.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Specialty Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(
                  labelText: 'Specialty *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                items: (_partnerCategory == 'Homecare'
                        ? _homecareSpecialties
                        : medicalSpecialties)
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ),)
                    .toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Clinic Dropdown
              DropdownButtonFormField<String>(
                value: _selectedClinicId,
                decoration: const InputDecoration(
                  labelText: 'Associated Clinic (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_outlined),
                  helperText:
                      'Select existing clinic or leave empty if independent',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Independent / No Clinic'),
                  ),
                  ..._clinics.map((c) => DropdownMenuItem<String>(
                        value: c['id'] as String,
                        child: Text(c['full_name'] as String),
                      ),),
                ],
                onChanged: (val) => setState(() => _selectedClinicId = val),
              ),
              const SizedBox(height: 16),

              // National ID
              TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(
                  labelText: 'National ID Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Medical License
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'Medical License Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
