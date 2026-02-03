import "package:flutter/material.dart";
import "package:piano_fitness/features/repertoire/repertoire_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Enhanced header widget for the repertoire page.
///
/// Displays the page title, description, and info button in a visually
/// appealing gradient container with responsive sizing.
class RepertoireHeader extends StatelessWidget {
  /// Creates a repertoire header widget.
  const RepertoireHeader({
    required this.isSmallHeight,
    required this.onInfoTap,
    super.key,
  });

  /// Whether the screen has compact height.
  final bool isSmallHeight;

  /// Callback for info button tap.
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      child: Container(
        padding: EdgeInsets.all(
          isSmallHeight
              ? RepertoireUIConstants.headerPaddingCompact
              : Spacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(
                alpha: OpacityValues.gradientStart,
              ),
              colorScheme.secondary.withValues(
                alpha: OpacityValues.gradientStart,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          border: Border.all(
            color: colorScheme.primary.withValues(
              alpha: OpacityValues.borderSubtle,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: OpacityValues.shadowMedium,
                    ),
                    blurRadius: 8.0, // Standard card shadow blur
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.library_music,
                color: colorScheme.primary,
                size: isSmallHeight
                    ? ComponentDimensions.iconSizeMedium
                    : ComponentDimensions.iconSizeLarge,
              ),
            ),
            SizedBox(width: isSmallHeight ? Spacing.sm : Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Repertoire Practice",
                    style: TextStyle(
                      fontSize: isSmallHeight
                          ? theme.textTheme.headlineSmall?.fontSize
                          : theme.textTheme.headlineMedium?.fontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: RepertoireUIConstants.titleLetterSpacing,
                    ),
                  ),
                  if (!isSmallHeight)
                    Text(
                      "Build your musical repertoire",
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium?.fontSize,
                        color: colorScheme.primary.withValues(
                          alpha: OpacityValues.textMuted,
                        ),
                      ),
                    ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    "Switch to your repertoire app for focused practice",
                    style: TextStyle(
                      fontSize: isSmallHeight
                          ? RepertoireUIConstants.helperFontSizeCompact
                          : theme.textTheme.bodySmall?.fontSize,
                      color: colorScheme.tertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
                onTap: onInfoTap,
                child: Semantics(
                  button: true,
                  label: "About repertoire practice and recommended apps",
                  hint:
                      "Opens modal with practice guidance and app recommendations",
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.sm),
                    child: Icon(
                      Icons.help_outline,
                      color: colorScheme.primary,
                      size: isSmallHeight
                          ? RepertoireUIConstants.helpIconSizeCompact
                          : ComponentDimensions.iconSizeMedium,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
