import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/accessibility/services/musical_announcements_service.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

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
    const baseDescription = "Interactive piano keyboard";

    if (highlightedNotes.isEmpty) {
      return "$baseDescription. No notes highlighted.";
    } else if (highlightedNotes.length == 1) {
      final noteName = _getNotePositionDisplayName(highlightedNotes.first);
      return "$baseDescription. $noteName is highlighted.";
    } else {
      final noteNames = highlightedNotes
          .map(_getNotePositionDisplayName)
          .join(", ");
      return "$baseDescription. ${highlightedNotes.length} notes highlighted: $noteNames.";
    }
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
      return "No notes highlighted";
    } else if (newHighlightedNotes.length == 1) {
      final noteName = _getNotePositionDisplayName(newHighlightedNotes.first);
      return "$noteName highlighted";
    } else {
      final noteNames = newHighlightedNotes
          .map(_getNotePositionDisplayName)
          .join(", ");
      return "${newHighlightedNotes.length} notes highlighted: $noteNames";
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
    final keyType =
        "piano key"; // Simplified since we can't easily determine white vs black
    final highlightStatus = isHighlighted ? " highlighted" : "";

    return "$noteName $keyType$highlightStatus";
  }

  /// Creates an accessible wrapper widget for InteractivePiano.
  ///
  /// This wrapper adds semantic annotations and live region announcements
  /// to make the piano keyboard accessible to screen readers.
  ///
  /// The [child] should be the InteractivePiano widget.
  /// The [highlightedNotes] are the currently highlighted notes.
  /// The [semanticLabel] is an optional custom label for the piano.
  static Widget createAccessiblePianoWrapper({
    required Widget child,
    required List<NotePosition> highlightedNotes,
    String? semanticLabel,
  }) {
    final description = getPianoKeyboardDescription(highlightedNotes);
    final label = semanticLabel ?? "Interactive piano keyboard";

    return Semantics(
      label: label,
      hint: "Piano keyboard for musical interaction and practice",
      container: true,
      child: Semantics(liveRegion: true, label: description, child: child),
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
      final noteNames = targetNotes.map(_getNotePositionDisplayName).join(", ");
      parts.add("Target notes: $noteNames");
    }

    if (correctNotes != null && correctNotes.isNotEmpty) {
      final noteNames = correctNotes
          .map(_getNotePositionDisplayName)
          .join(", ");
      parts.add("${correctNotes.length} correct notes: $noteNames");
    }

    if (incorrectNotes != null && incorrectNotes.isNotEmpty) {
      final noteNames = incorrectNotes
          .map(_getNotePositionDisplayName)
          .join(", ");
      parts.add("${incorrectNotes.length} incorrect notes: $noteNames");
    }

    return parts.join(". ");
  }
}
