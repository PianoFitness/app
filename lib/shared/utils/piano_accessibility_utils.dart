import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/accessibility/services/musical_announcements_service.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Utility class providing accessibility enhancements for piano widgets.
///
/// This class provides methods to generate semantic labels, descriptions,
/// and announcements for piano keyboards and musical interactions.
class PianoAccessibilityUtils {
  /// Creates a semantic description for a piano keyboard with highlighted notes.
  ///
  /// The [highlightedNotes] are the currently highlighted/active notes.
  /// Returns a comprehensive description suitable for screen readers.
  static String getPianoKeyboardDescription(
    List<NotePosition> highlightedNotes,
  ) {
    // Use default keyboard label for general interactive use
    // Since AccessibilityLabels.piano.keyboardLabel requires a mode,
    // we'll use a general interactive description here
    const baseDescription = "Interactive piano keyboard";

    // Get the highlighted notes part using the centralized labels
    final noteNames = highlightedNotes
        .map(_getNotePositionDisplayName)
        .toList();
    final highlightDescription = AccessibilityLabels.piano.highlightedNotes(
      noteNames,
    );

    return "$baseDescription. $highlightDescription.";
  }

  /// Helper method to join note display names with consistent formatting.
  ///
  /// The [notes] are the note positions to convert and join.
  /// Returns a comma-separated string of note names.
  static String _joinNoteDisplayNames(List<NotePosition> notes) {
    return notes.map(_getNotePositionDisplayName).join(", ");
  }

  /// Creates a semantic label for highlighted notes changes.
  ///
  /// This is used for live region announcements when the highlighted notes change.
  /// The [newHighlightedNotes] are the newly highlighted notes.
  /// Returns a string suitable for announcing changes to screen readers.
  static String getHighlightedNotesAnnouncement(
    List<NotePosition> newHighlightedNotes,
  ) {
    if (newHighlightedNotes.isEmpty) {
      return AccessibilityLabels.piano.highlightedNotes([]);
    } else if (newHighlightedNotes.length == 1) {
      final noteName = _getNotePositionDisplayName(newHighlightedNotes.first);
      return AccessibilityLabels.piano.highlightedNotes([noteName]);
    } else {
      final noteNames = newHighlightedNotes
          .map(_getNotePositionDisplayName)
          .toList();
      return AccessibilityLabels.piano.highlightedNotes(noteNames);
    }
  }

  /// Creates a semantic description for a piano key.
  ///
  /// The [position] specifies the note position on the keyboard.
  /// The [isHighlighted] indicates if the key is currently highlighted.
  /// Returns a description suitable for individual key accessibility.
  static String getPianoKeyDescription(
    NotePosition position,
    bool isHighlighted,
  ) {
    final noteName = _getNotePositionDisplayName(position);
    return AccessibilityLabels.piano.keyDescription(noteName, isHighlighted);
  }

  /// Creates an accessible wrapper widget for InteractivePiano.
  ///
  /// This wrapper adds semantic annotations and live region announcements
  /// to make the piano keyboard accessible to screen readers.
  ///
  /// The [child] should be the InteractivePiano widget.
  /// The [highlightedNotes] are the currently highlighted notes.
  /// The [mode] specifies the piano mode for context-appropriate labeling.
  /// The [semanticLabel] is an optional custom label for the piano.
  static Widget createAccessiblePianoWrapper({
    required Widget child,
    required List<NotePosition> highlightedNotes,
    required PianoMode mode,
    String? semanticLabel,
  }) {
    final description = getPianoKeyboardDescription(highlightedNotes);
    final label =
        semanticLabel ?? AccessibilityLabels.piano.keyboardLabel(mode);

    return Semantics(
      label: label,
      hint: AccessibilityLabels.piano.keyboardHint(mode),
      container: true,
      child: ExcludeSemantics(
        child: Semantics(liveRegion: true, value: description, child: child),
      ),
    );
  }

  /// Converts a NotePosition to a human-readable display name.
  ///
  /// This is an internal helper method that converts a NotePosition
  /// to a string like "C4", "F#3", etc.
  static String _getNotePositionDisplayName(NotePosition position) {
    try {
      final midiNumber = NoteUtils.convertNotePositionToMidi(position);
      final noteInfo = NoteUtils.midiNumberToNote(midiNumber);
      return NoteUtils.noteDisplayName(noteInfo.note, noteInfo.octave);
    } catch (e) {
      // Fallback to basic note name if conversion fails
      return "${position.note.name}${position.octave}";
    }
  }

  /// Announces highlighted notes changes to screen readers.
  ///
  /// This method uses the MusicalAnnouncementsService to announce changes
  /// in highlighted notes to assistive technologies. It analyzes the message
  /// content to determine if it's a note, chord, or general announcement.
  ///
  /// The [context] is required for directionality.
  /// The [newHighlightedNotes] are the newly highlighted notes.
  static void announceHighlightedNotesChange(
    BuildContext context,
    List<NotePosition> newHighlightedNotes,
  ) {
    final announcement = getHighlightedNotesAnnouncement(newHighlightedNotes);

    // Determine the appropriate announcement method based on content
    if (newHighlightedNotes.isEmpty) {
      MusicalAnnouncementsService.announceGeneral(context, announcement);
    } else if (newHighlightedNotes.length == 1) {
      final noteName = _getNotePositionDisplayName(newHighlightedNotes.first);
      MusicalAnnouncementsService.announceNote(context, noteName);
    } else {
      final noteNames = newHighlightedNotes
          .map(_getNotePositionDisplayName)
          .toList();
      MusicalAnnouncementsService.announceChord(context, noteNames);
    }
  }

  /// Creates semantic annotations for musical practice context.
  ///
  /// This method provides additional context for practice scenarios,
  /// such as target notes, correct notes, or incorrect notes.
  ///
  /// The [practiceMode] describes the type of practice (e.g., "scale practice").
  /// The [targetNotes] are the notes the user should play.
  /// The [correctNotes] are the correctly played notes.
  /// The [incorrectNotes] are the incorrectly played notes.
  static String getPracticeContextDescription({
    String? practiceMode,
    List<NotePosition>? targetNotes,
    List<NotePosition>? correctNotes,
    List<NotePosition>? incorrectNotes,
  }) {
    final parts = <String>[];

    if (practiceMode != null) {
      parts.add(practiceMode);
    }

    if (targetNotes != null && targetNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(targetNotes);
      parts.add("Target notes: $noteNames");
    }

    if (correctNotes != null && correctNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(correctNotes);
      parts.add("${correctNotes.length} correct notes: $noteNames");
    }

    if (incorrectNotes != null && incorrectNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(incorrectNotes);
      parts.add("${incorrectNotes.length} incorrect notes: $noteNames");
    }

    return parts.join(". ");
  }
}
