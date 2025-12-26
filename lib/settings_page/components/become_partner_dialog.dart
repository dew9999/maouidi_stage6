import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Riverpod provider for loading state
final _becomePartnerLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class BecomePartnerDialog extends ConsumerWidget {
  final String currentDisplayName;
  final String currentPhoneNumber;

  const BecomePartnerDialog({
    super.key,
    required this.currentDisplayName,
    required this.currentPhoneNumber,
  });

  Future<void> _submitApplication(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController phoneController,
    TextEditingController addressController,
    TextEditingController nationalIdController,
    TextEditingController licenseController,
  ) async {
    if (formKey.currentState!.validate()) {
      ref.read(_becomePartnerLoadingProvider.notifier).state = true;
      try {
        await Supabase.instance.client.rpc(
          'submit_partner_application',
          params: {
            'first_name_arg': firstNameController.text,
            'last_name_arg': lastNameController.text,
            'phone_arg': phoneController.text,
            'address_arg': addressController.text,
            'national_id_arg': nationalIdController.text,
            'license_id_arg': licenseController.text,
          },
        );

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted! We will contact you soon.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e is PostgrestException ? e.message : e.toString()}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        ref.read(_becomePartnerLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = ref.watch(_becomePartnerLoadingProvider);

    final formKey = GlobalKey<FormState>();
    final nameParts = currentDisplayName.split(' ');
    final firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts.first : '',
    );
    final lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
    );
    final phoneController = TextEditingController(text: currentPhoneNumber);
    final addressController = TextEditingController();
    final nationalIdController = TextEditingController();
    final licenseController = TextEditingController();

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text('Partner Application', style: textTheme.headlineSmall),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nationalIdController,
                decoration:
                    const InputDecoration(labelText: 'National ID Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: licenseController,
                decoration:
                    const InputDecoration(labelText: 'Medical License Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () => _submitApplication(
                    context,
                    ref,
                    formKey,
                    firstNameController,
                    lastNameController,
                    phoneController,
                    addressController,
                    nationalIdController,
                    licenseController,
                  ),
          style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
