/// Accessibility utilities and components for Piano Fitness.
///
/// This library provides a comprehensive set of accessibility tools including:
/// - Centralized configuration for labels and messages
/// - Service classes for managing semantic announcements
/// - Reusable accessible widget components
/// - Mixins for common accessibility patterns
///
/// Usage:
/// ```dart
/// import "package:piano_fitness/shared/accessibility/accessibility.dart";
///
/// // Use accessible widgets
/// AccessiblePiano(child: myPiano, mode: PianoMode.play, highlightedNotes: []);
///
/// // Use mixins in your StatefulWidget
/// class MyWidget extends StatefulWidget {
///   // ...
/// }
///
/// class _MyWidgetState extends State<MyWidget>
///     with AccessibilityAnnouncementMixin {
///   void onNotePressed(String note) {
///     announceNote(note);
///   }
/// }
/// ```
library;

// Configuration
export "config/accessibility_labels.dart";

// Services
export "services/piano_semantics_service.dart";
export "services/musical_announcements_service.dart";
export "services/midi_accessibility_service.dart";

// Widgets
export "widgets/accessible_widgets.dart";

// Mixins
export "mixins/accessibility_mixins.dart";
