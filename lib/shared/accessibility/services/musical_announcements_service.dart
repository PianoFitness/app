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
    SemanticsService.announce(announcement, Directionality.of(context));
  }

  /// Announces mode changes (play, practice, reference).
  ///
  /// This provides feedback when users switch between different piano modes.
  ///
  /// The [context] is required for directionality.
  /// The [newMode] is the mode being switched to.
  static void announceModeChange(BuildContext context, PianoMode newMode) {
    final modeLabel = AccessibilityLabels.piano.keyboardLabel(newMode);
    SemanticsService.announce(
      "Switched to $modeLabel",
      Directionality.of(context),
    );
  }

  /// Announces timer state changes.
  ///
  /// This keeps users informed about timer actions like start, pause, resume, reset.
  ///
  /// The [context] is required for directionality.
  /// The [timerState] describes the new timer state.
  static void announceTimerChange(BuildContext context, String timerState) {
    SemanticsService.announce(timerState, Directionality.of(context));
  }

  /// Announces MIDI device status changes.
  ///
  /// This provides feedback about MIDI device connections and status updates.
  ///
  /// The [context] is required for directionality.
  /// The [status] describes the MIDI status or change.
  static void announceMidiStatus(BuildContext context, String status) {
    SemanticsService.announce(status, Directionality.of(context));
  }

  /// Announces practice progress or feedback.
  ///
  /// This provides real-time feedback during practice sessions about
  /// correct/incorrect notes, progress, achievements, etc.
  ///
  /// The [context] is required for directionality.
  /// The [feedback] describes the practice feedback or progress.
  static void announcePracticeFeedback(BuildContext context, String feedback) {
    SemanticsService.announce(feedback, Directionality.of(context));
  }

  /// Announces general UI state changes.
  ///
  /// This provides feedback for other UI state changes not covered by
  /// the more specific announcement methods.
  ///
  /// The [context] is required for directionality.
  /// The [message] is the announcement to make.
  static void announceGeneral(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  /// Announces a note being played (simplified method for mixins).
  static void announceNote(String note) {
    SemanticsService.announce("Playing note $note", TextDirection.ltr);
  }

  /// Announces a chord being played (simplified method for mixins).
  static void announceChord(List<String> notes) {
    if (notes.isEmpty) return;
    if (notes.length == 1) {
      announceNote(notes.first);
    } else {
      final noteList = notes.join(", ");
      SemanticsService.announce("Playing chord: $noteList", TextDirection.ltr);
    }
  }

  /// Announces a status change (simplified method for mixins).
  static void announceStatus(String status) {
    SemanticsService.announce(status, TextDirection.ltr);
  }

  /// Announces an error with appropriate emphasis (simplified method for mixins).
  static void announceError(String error) {
    SemanticsService.announce("Error: $error", TextDirection.ltr);
  }
}
