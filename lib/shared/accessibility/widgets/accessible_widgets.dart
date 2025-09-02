import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/accessibility/services/piano_semantics_service.dart";

/// An accessible wrapper for the InteractivePiano widget.
///
/// This widget automatically applies appropriate semantic annotations
/// based on the piano mode and highlighted notes, making the piano
/// keyboard accessible to screen readers.
class AccessiblePiano extends StatelessWidget {
  /// Creates an accessible piano widget.
  const AccessiblePiano({
    required this.child,
    required this.mode,
    required this.highlightedNotes,
    super.key,
  });

  /// The InteractivePiano widget to wrap with accessibility features.
  final Widget child;

  /// The current piano mode (play, practice, reference).
  final PianoMode mode;

  /// The currently highlighted notes on the piano.
  final List<NotePosition> highlightedNotes;

  @override
  Widget build(BuildContext context) {
    return PianoSemanticsService.createAccessibleWrapper(
      child: child,
      mode: mode,
      highlightedNotes: highlightedNotes,
    );
  }
}

/// An accessible header widget with proper semantic markup.
///
/// This widget ensures headers are properly identified by screen readers
/// and maintain consistent styling.
class AccessibleHeader extends StatelessWidget {
  /// Creates an accessible header widget.
  const AccessibleHeader({required this.text, this.style, super.key});

  /// The header text to display.
  final String text;

  /// Optional text style for the header.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: style ?? Theme.of(context).textTheme.titleLarge),
    );
  }
}

/// A text widget with live region semantics for dynamic content.
///
/// This widget automatically announces text changes to screen readers,
/// making it ideal for status displays and dynamic information.
class LiveRegionText extends StatelessWidget {
  /// Creates a live region text widget.
  const LiveRegionText({
    required this.text,
    this.semanticLabel,
    this.style,
    this.textAlign,
    super.key,
  });

  /// The text to display.
  final String text;

  /// Optional semantic label override.
  final String? semanticLabel;

  /// Optional text style.
  final TextStyle? style;

  /// Optional text alignment.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      liveRegion: true,
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

/// An accessible icon button with enhanced semantic information.
///
/// This widget provides comprehensive accessibility information including
/// labels, hints, and enabled/disabled states.
class AccessibleIconButton extends StatelessWidget {
  /// Creates an accessible icon button.
  const AccessibleIconButton({
    required this.icon,
    required this.label,
    this.hint,
    this.onPressed,
    this.tooltip,
    super.key,
  });

  /// The icon to display.
  final IconData icon;

  /// The semantic label for the button.
  final String label;

  /// Optional hint providing additional context.
  final String? hint;

  /// The callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional tooltip text.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: hint,
      child: ExcludeSemantics(child: button),
    );
  }
}

/// An accessible container widget for grouping related content.
///
/// This widget provides semantic container markup with optional
/// labels and descriptions for screen reader navigation.
class AccessibleContainer extends StatelessWidget {
  /// Creates an accessible container widget.
  const AccessibleContainer({
    required this.child,
    this.label,
    this.hint,
    this.padding,
    this.margin,
    this.decoration,
    super.key,
  });

  /// The child widget to contain.
  final Widget child;

  /// Optional semantic label for the container.
  final String? label;

  /// Optional hint providing additional context.
  final String? hint;

  /// Optional padding for the container.
  final EdgeInsetsGeometry? padding;

  /// Optional margin for the container.
  final EdgeInsetsGeometry? margin;

  /// Optional decoration for the container.
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (label != null) {
      return Semantics(
        label: label,
        hint: hint,
        container: true,
        child: container,
      );
    }

    return container;
  }
}
