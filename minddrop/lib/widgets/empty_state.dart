import 'package:flutter/material.dart';
import 'package:minddrop/utils/app_routes.dart'; // For navigation

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? ctaText;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    this.message = 'No ideas yet. Tap the button below to add one!',
    this.icon = Icons.lightbulb_outline_rounded, // Changed to rounded version
    this.ctaText, // Default CTA will be to add an idea
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine default CTA if specific one isn't provided
    final String actualCtaText = ctaText ?? 'Add Your First Idea';
    final VoidCallback actualOnCtaPressed = onCtaPressed ??
        () => Navigator.pushNamed(context, AppRoutes.addIdea);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Added padding around content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6), // Softer color
            ),
            const SizedBox(height: 24), // Increased spacing
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith( // Slightly larger text
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32), // Increased spacing before CTA
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(actualCtaText),
              onPressed: actualOnCtaPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: theme.textTheme.titleMedium,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
