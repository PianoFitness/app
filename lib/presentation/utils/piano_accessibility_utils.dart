import "package:flutter/material.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/accessibility/services/musical_announcements_service.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Utility class providing accessibility enhancements for piano widgets.
///
/// This class provides methods to generate semantic labels, descriptions,
/// and announcements for piano keyboards and musical interactions.
class PianoAccessibilityUtils {
  /// Creates a semantic description for a piano keyboard with highlighted notes.
  ///
  /// The [highlightedMidiNotes] are the currently highlighted/active notes.
  /// Returns a comprehensive description suitable for screen readers.
  static String getPianoKeyboardDescription(List<int> highlightedMidiNotes) {
    // Use default keyboard label for general interactive use
    // Since AccessibilityLabels.piano.keyboardLabel requires a mode,
    // we'll use a general interactive description here
    const baseDescription = "Interactive piano keyboard";

    // Get the highlighted notes part using the centralized labels
    final noteNames = highlightedMidiNotes.map(_getNoteDisplayName).toList();
    final highlightDescription = AccessibilityLabels.piano.highlightedNotes(
      noteNames,
    );

    return "$baseDescription. $highlightDescription.";
  }

  /// Helper method to join note display names with consistent formatting.
  ///
  /// The [midiNotes] are the notes to convert and join.
  /// Returns a comma-separated string of note names.
  static String _joinNoteDisplayNames(List<int> midiNotes) {
    return midiNotes.map(_getNoteDisplayName).join(", ");
  }

  /// Creates a semantic label for highlighted notes changes.
  ///
  /// This is used for live region announcements when the highlighted notes change.
  /// The [newHighlightedMidiNotes] are the newly highlighted notes.
  /// Returns a string suitable for announcing changes to screen readers.
  static String getHighlightedNotesAnnouncement(
    List<int> newHighlightedMidiNotes,
  ) {
    if (newHighlightedMidiNotes.isEmpty) {
      return AccessibilityLabels.piano.highlightedNotes([]);
    } else if (newHighlightedMidiNotes.length == 1) {
      final noteName = _getNoteDisplayName(newHighlightedMidiNotes.first);
      return AccessibilityLabels.piano.highlightedNotes([noteName]);
    } else {
      final noteNames = newHighlightedMidiNotes
          .map(_getNoteDisplayName)
          .toList();
      return AccessibilityLabels.piano.highlightedNotes(noteNames);
    }
  }

  /// Creates a semantic description for a piano key.
  ///
  /// The [midiNote] specifies the note on the keyboard.
  /// The [isHighlighted] indicates if the key is currently highlighted.
  /// Returns a description suitable for individual key accessibility.
  static String getPianoKeyDescription(int midiNote, bool isHighlighted) {
    final noteName = _getNoteDisplayName(midiNote);
    return AccessibilityLabels.piano.keyDescription(noteName, isHighlighted);
  }

  /// Creates an accessible wrapper widget for PianoKeyboard.
  ///
  /// This wrapper adds semantic annotations and live region announcements
  /// to make the piano keyboard accessible to screen readers.
  ///
  /// The [child] should be the PianoKeyboard widget.
  /// The [highlightedMidiNotes] are the currently highlighted notes.
  /// The [mode] specifies the piano mode for context-appropriate labeling.
  /// The [semanticLabel] is an optional custom label for the piano.
  static Widget createAccessiblePianoWrapper({
    required Widget child,
    required List<int> highlightedMidiNotes,
    required PianoMode mode,
    String? semanticLabel,
  }) {
    final description = getPianoKeyboardDescription(highlightedMidiNotes);
    final label =
        semanticLabel ?? AccessibilityLabels.piano.keyboardLabel(mode);

    return Semantics(
      label: label,
      hint: AccessibilityLabels.piano.keyboardHint(mode),
      container: true,
      child: Semantics(liveRegion: true, value: description, child: child),
    );
  }

  /// Converts a MIDI note number to a human-readable display name.
  ///
  /// This is an internal helper method that converts a MIDI note number
  /// to a string like "C4", "F#3", etc.
  static String _getNoteDisplayName(int midiNote) {
    try {
      return NoteUtils.midiNumberToNote(midiNote).displayName;
    } catch (e) {
      // Fallback for out-of-range MIDI values.
      return "note $midiNote";
    }
  }

  /// Announces highlighted notes changes to screen readers.
  ///
  /// This method uses the MusicalAnnouncementsService to announce changes
  /// in highlighted notes to assistive technologies. It analyzes the message
  /// content to determine if it's a note, chord, or general announcement.
  ///
  /// The [context] is required for directionality.
  /// The [newHighlightedMidiNotes] are the newly highlighted notes.
  static void announceHighlightedNotesChange(
    BuildContext context,
    List<int> newHighlightedMidiNotes,
  ) {
    final announcement = getHighlightedNotesAnnouncement(
      newHighlightedMidiNotes,
    );

    // Determine the appropriate announcement method based on content
    if (newHighlightedMidiNotes.isEmpty) {
      MusicalAnnouncementsService.announceGeneral(context, announcement);
    } else if (newHighlightedMidiNotes.length == 1) {
      final noteName = _getNoteDisplayName(newHighlightedMidiNotes.first);
      MusicalAnnouncementsService.announceNote(context, noteName);
    } else {
      final noteNames = newHighlightedMidiNotes
          .map(_getNoteDisplayName)
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
  /// The [targetMidiNotes] are the notes the user should play.
  /// The [correctMidiNotes] are the correctly played notes.
  /// The [incorrectMidiNotes] are the incorrectly played notes.
  static String getPracticeContextDescription({
    String? practiceMode,
    List<int>? targetMidiNotes,
    List<int>? correctMidiNotes,
    List<int>? incorrectMidiNotes,
  }) {
    final parts = <String>[];

    if (practiceMode != null) {
      parts.add(practiceMode);
    }

    if (targetMidiNotes != null && targetMidiNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(targetMidiNotes);
      parts.add("Target notes: $noteNames");
    }

    if (correctMidiNotes != null && correctMidiNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(correctMidiNotes);
      parts.add("${correctMidiNotes.length} correct notes: $noteNames");
    }

    if (incorrectMidiNotes != null && incorrectMidiNotes.isNotEmpty) {
      final noteNames = _joinNoteDisplayNames(incorrectMidiNotes);
      parts.add("${incorrectMidiNotes.length} incorrect notes: $noteNames");
    }

    return parts.join(". ");
  }
}
