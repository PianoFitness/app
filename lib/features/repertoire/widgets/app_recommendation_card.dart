import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Compact card widget for displaying app recommendations.
///
/// Shows app name, description, icon, and a button to open the app's website.
class AppRecommendationCard extends StatelessWidget {
  /// Creates an app recommendation card.
  const AppRecommendationCard({
    required this.name,
    required this.description,
    required this.url,
    required this.icon,
    required this.color,
    required this.onOpenUrl,
    super.key,
  });

  /// Name of the recommended app.
  final String name;

  /// Brief description of the app's features.
  final String description;

  /// URL to the app's website.
  final String url;

  /// Icon representing the app.
  final IconData icon;

  /// Theme color for the card.
  final Color color;

  /// Callback when the open URL button is tapped.
  final VoidCallback onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            RepertoireUIConstants.containerBorderRadius,
          ),
          border: Border.all(
            color: color.withValues(alpha: OpacityValues.borderMedium),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(
                RepertoireUIConstants.appIconPadding,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: OpacityValues.backgroundLight),
                borderRadius: BorderRadius.circular(
                  RepertoireUIConstants.containerBorderRadius,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: RepertoireUIConstants.appRecommendationIconSize,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodyMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall?.fontSize,
                      height: RepertoireUIConstants.appDescriptionLineHeight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Semantics(
              button: true,
              label: "Open $name website",
              hint: "Opens $name in external browser or app",
              child: IconButton(
                onPressed: onOpenUrl,
                icon: Icon(
                  Icons.open_in_new,
                  color: color,
                  size: RepertoireUIConstants.appRecommendationIconSize,
                ),
                tooltip: "Open $name",
                padding: const EdgeInsets.all(Spacing.xs),
                constraints: const BoxConstraints(
                  minWidth: ComponentDimensions.iconSizeXLarge,
                  minHeight: ComponentDimensions.iconSizeXLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
