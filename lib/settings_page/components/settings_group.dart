import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  children[index],
                  if (index != children.length - 1)
                    Divider(height: 1, color: colorScheme.outline, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
