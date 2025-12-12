import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/accessibility/services/piano_semantics_service.dart";

/// Service for managing live region announcements in musical contexts.
///
/// This service handles real-time semantic announcements that keep screen reader
/// users informed about dynamic changes in the musical interface.
class MusicalAnnouncementsService {
  /// Centralized helper for sending announcements with proper guards.
  ///
  /// This method checks for platform support, View availability, and provides
  /// graceful degradation for missing Directionality context.
  static void _send(BuildContext context, String message) {
    // Guard against missing MediaQuery (tests, overlays, early lifecycle)
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;

    // Skip if platform doesn't support announcements
    if (!MediaQuery.supportsAnnounceOf(context)) return;

    // Gracefully handle missing View
    final view = View.maybeOf(context);
    if (view == null) return;

    // Use LTR as fallback if no Directionality ancestor
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    SemanticsService.sendAnnouncement(view, message, textDirection);
  }

  /// Announces highlighted notes changes to screen readers.
  ///
  /// This method uses the Flutter SemanticsService to announce changes
  /// in highlighted notes to assistive technologies.
  ///
  /// The [context] is required for directionality.
  /// The [newHighlightedNotes] are the newly highlighted notes.
  static void announceNotesChange(
    BuildContext context,
    List<NotePosition> newHighlightedNotes,
  ) {
    final announcement = PianoSemanticsService.getNotesChangeAnnouncement(
      newHighlightedNotes,
    );
    _send(context, announcement);
  }

  /// Announces mode changes (play, practice, reference).
  ///
  /// This provides feedback when users switch between different piano modes.
  ///
  /// The [context] is required for directionality.
  /// The [newMode] is the mode being switched to.
  static void announceModeChange(BuildContext context, PianoMode newMode) {
    final modeLabel = AccessibilityLabels.piano.keyboardLabel(newMode);
    _send(context, "Switched to $modeLabel");
  }

  /// Announces timer state changes.
  ///
  /// This keeps users informed about timer actions like start, pause, resume, reset.
  ///
  /// The [context] is required for directionality.
  /// The [timerState] describes the new timer state.
  static void announceTimerChange(BuildContext context, String timerState) {
    _send(context, timerState);
  }

  /// Announces MIDI device status changes.
  ///
  /// This provides feedback about MIDI device connections and status updates.
  ///
  /// The [context] is required for directionality.
  /// The [status] describes the MIDI status or change.
  static void announceMidiStatus(BuildContext context, String status) {
    _send(context, status);
  }

  /// Announces practice progress or feedback.
  ///
  /// This provides real-time feedback during practice sessions about
  /// correct/incorrect notes, progress, achievements, etc.
  ///
  /// The [context] is required for directionality.
  /// The [feedback] describes the practice feedback or progress.
  static void announcePracticeFeedback(BuildContext context, String feedback) {
    _send(context, feedback);
  }

  /// Announces general UI state changes.
  ///
  /// This provides feedback for other UI state changes not covered by
  /// the more specific announcement methods.
  ///
  /// The [context] is required for directionality.
  /// The [message] is the announcement to make.
  static void announceGeneral(BuildContext context, String message) {
    _send(context, message);
  }

  /// Announces a note being played (simplified method for mixins).
  static void announceNote(BuildContext context, String note) {
    _send(context, "Playing note $note");
  }

  /// Announces a chord being played (simplified method for mixins).
  static void announceChord(BuildContext context, List<String> notes) {
    if (notes.isEmpty) return;
    if (notes.length == 1) {
      announceNote(context, notes.first);
    } else {
      final noteList = notes.join(", ");
      _send(context, "Playing chord: $noteList");
    }
  }

  /// Announces a status change (simplified method for mixins).
  static void announceStatus(BuildContext context, String status) {
    _send(context, status);
  }

  /// Announces an error with appropriate emphasis (simplified method for mixins).
  static void announceError(BuildContext context, String error) {
    _send(context, "Error: $error");
  }
}
