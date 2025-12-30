// lib/settings_page/components/profile_card.dart

import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
    this.photoUrl,
    this.gender,
  });

  final String name;
  final String email;
  final VoidCallback onTap;
  final String? photoUrl;
  final String? gender;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Gender-based Avatar with native icons
                photoUrl != null && photoUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(photoUrl!),
                        backgroundColor: colorScheme.primary,
                      )
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor: gender?.toLowerCase() == 'male'
                            ? Colors.blue.shade50
                            : gender?.toLowerCase() == 'female'
                                ? Colors.pink.shade50
                                : colorScheme.surfaceVariant,
                        child: Icon(
                          gender?.toLowerCase() == 'male'
                              ? Icons.man
                              : gender?.toLowerCase() == 'female'
                                  ? Icons.woman
                                  : Icons.person,
                          size: 28,
                          color: gender?.toLowerCase() == 'male'
                              ? Colors.blue
                              : gender?.toLowerCase() == 'female'
                                  ? Colors.pink
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'User Profile',
                        style: textTheme.titleLarge,
                      ),
                      Text(
                        email,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
