import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Service for generating piano-specific semantic descriptions and announcements.
///
/// This service centralizes all piano keyboard accessibility logic, making it
/// easy to maintain consistent piano-related accessibility across the app.
class PianoSemanticsService {
  /// Creates a comprehensive semantic description for a piano keyboard.
  ///
  /// The [mode] determines the context-appropriate labeling.
  /// The [highlightedNotes] are the currently highlighted/active notes.
  /// Returns a complete description suitable for screen readers.
  static String getKeyboardDescription(
    PianoMode mode,
    List<NotePosition> highlightedNotes,
  ) {
    final baseDescription = AccessibilityLabels.piano.keyboardLabel(mode);
    final noteNames = highlightedNotes.map(_getNoteDisplayName).toList();

    if (noteNames.isEmpty) {
      return "$baseDescription. No notes highlighted.";
    }

    final highlightDescription = AccessibilityLabels.piano.highlightedNotes(
      noteNames,
    );
    return "$baseDescription. $highlightDescription";
  }

  /// Generates a semantic label for piano keyboard widgets.
  ///
  /// This creates the primary semantic label that screen readers will announce
  /// when the user first encounters the piano keyboard.
  static String getKeyboardLabel(PianoMode mode) {
    return AccessibilityLabels.piano.keyboardLabel(mode);
  }

  /// Generates a semantic hint for piano keyboard widgets.
  ///
  /// This provides additional context about how to interact with the piano
  /// in the current mode.
  static String getKeyboardHint(PianoMode mode) {
    return AccessibilityLabels.piano.keyboardHint(mode);
  }

  /// Creates a semantic description for an individual piano key.
  ///
  /// The [position] specifies the note position on the keyboard.
  /// The [isHighlighted] indicates if the key is currently highlighted.
  /// Returns a description suitable for individual key accessibility.
  static String getKeyDescription(NotePosition position, bool isHighlighted) {
    final noteName = _getNoteDisplayName(position);
    return AccessibilityLabels.piano.keyDescription(noteName, isHighlighted);
  }

  /// Generates an announcement for highlighted notes changes.
  ///
  /// This is used for live region announcements when the highlighted notes change.
  /// The [newHighlightedNotes] are the newly highlighted notes.
  /// Returns a string suitable for announcing changes to screen readers.
  static String getNotesChangeAnnouncement(
    List<NotePosition> newHighlightedNotes,
  ) {
    final noteNames = newHighlightedNotes.map(_getNoteDisplayName).toList();

    return AccessibilityLabels.piano.noteChange(noteNames);
  }

  /// Converts a NotePosition to a human-readable display name.
  ///
  /// This is an internal helper method that converts a NotePosition
  /// to a string like "C4", "F#3", etc.
  static String _getNoteDisplayName(NotePosition position) {
    try {
      final midiNumber = NoteUtils.convertNotePositionToMidi(position);
      final noteInfo = NoteUtils.midiNumberToNote(midiNumber);
      return NoteUtils.noteDisplayName(noteInfo.note, noteInfo.octave);
    } catch (e) {
      // Fallback to basic note name if conversion fails
      return "${position.note.name}${position.octave}";
    }
  }

  /// Creates a complete accessibility wrapper for piano widgets.
  ///
  /// This is a convenience method that applies all appropriate semantic
  /// annotations for a piano keyboard in the given mode.
  ///
  /// The [child] should be the InteractivePiano widget.
  /// The [mode] determines the accessibility context.
  /// The [highlightedNotes] are the currently highlighted notes.
  static Widget createAccessibleWrapper({
    required Widget child,
    required PianoMode mode,
    required List<NotePosition> highlightedNotes,
  }) {
    final label = getKeyboardLabel(mode);
    final hint = getKeyboardHint(mode);
    final description = getKeyboardDescription(mode, highlightedNotes);

    return Semantics(
      label: label,
      hint: hint,
      container: true,
      child: Semantics(liveRegion: true, label: description, child: child),
    );
  }
}
