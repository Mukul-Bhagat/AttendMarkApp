import 'package:flutter/material.dart';

/// Empty State Widget
/// Reusable widget for displaying empty states across the app
/// Theme-aware, clean design, no animations
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final EdgeInsets? padding;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultPadding = padding ?? const EdgeInsets.all(24.0);
    
    return Center(
      child: Padding(
        padding: defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


