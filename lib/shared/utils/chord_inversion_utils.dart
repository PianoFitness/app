import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;

/// Utility class for chord inversion calculations and MIDI note generation.
///
/// This class provides a centralized, tested implementation for chord inversions
/// that ensures proper voice leading and ascending note order. It abstracts
/// the complexity of chord theory to provide simple, reliable methods for
/// generating chord progressions and individual chord voicings.
class ChordInversionUtils {
  /// Gets MIDI note numbers for a chord with proper inversion voicing.
  ///
  /// This method ensures that:
  /// - All notes in a chord ascend from left to right
  /// - Inversions progress naturally (bass notes ascend across inversions)
  /// - No notes wrap to lower octaves inappropriately
  /// - Chord spans remain reasonable (within 2 octaves)
  ///
  /// Returns a list of MIDI note numbers in ascending order.
  static List<int> getChordMidiNotes({
    required MusicalNote rootNote,
    required ChordType chordType,
    required ChordInversion inversion,
    required int octave,
  }) {
    final chord = ChordDefinitions.getChord(rootNote, chordType, inversion);
    return chord.getMidiNotes(octave);
  }

  /// Gets MIDI note numbers for a scale.
  ///
  /// Returns all notes of the specified scale across multiple octaves,
  /// starting from the given octave and spanning the specified range.
  ///
  /// The [octaveSpan] parameter determines how many octaves to include.
  /// For example, octaveSpan of 2 will include notes from the base octave
  /// and the next octave up.
  static Set<int> getScaleMidiNotes({
    required scales.Key key,
    required scales.ScaleType scaleType,
    required int baseOctave,
    int octaveSpan = 2,
  }) {
    final scale = scales.ScaleDefinitions.getScale(key, scaleType);
    final scaleNotes = scale.getNotes();
    final midiNotes = <int>{};

    for (var octave = baseOctave; octave < baseOctave + octaveSpan; octave++) {
      for (final note in scaleNotes) {
        final midiNote = NoteUtils.noteToMidiNumber(note, octave);
        if (midiNote >= 0 && midiNote <= 127) {
          midiNotes.add(midiNote);
        }
      }
    }

    return midiNotes;
  }

  /// Validates that a chord's MIDI notes are properly voiced.
  ///
  /// Checks that:
  /// - Notes are in ascending order
  /// - Chord span is reasonable (≤ 24 semitones)
  /// - All notes are within valid MIDI range (0-127)
  ///
  /// Returns true if the voicing is valid, false otherwise.
  static bool validateChordVoicing(List<int> midiNotes) {
    if (midiNotes.isEmpty || midiNotes.length < 2) {
      return false;
    }

    // Check ascending order
    for (var i = 1; i < midiNotes.length; i++) {
      if (midiNotes[i] <= midiNotes[i - 1]) {
        return false;
      }
    }

    // Check reasonable span (within 2 octaves)
    final span = midiNotes.last - midiNotes.first;
    if (span > 24) {
      return false;
    }

    // Check MIDI range
    if (midiNotes.any((note) => note < 0 || note > 127)) {
      return false;
    }

    return true;
  }

  /// Gets a progression of chord inversions that flow smoothly.
  ///
  /// Returns a list of chord progressions where each chord transitions
  /// smoothly to its inversions, maintaining good voice leading.
  ///
  /// This is useful for practice exercises where students need to
  /// practice chord inversions in a musical context.
  static List<List<int>> getInversionProgression({
    required MusicalNote rootNote,
    required ChordType chordType,
    required int octave,
  }) {
    final root = getChordMidiNotes(
      rootNote: rootNote,
      chordType: chordType,
      inversion: ChordInversion.root,
      octave: octave,
    );

    final first = getChordMidiNotes(
      rootNote: rootNote,
      chordType: chordType,
      inversion: ChordInversion.first,
      octave: octave,
    );

    final second = getChordMidiNotes(
      rootNote: rootNote,
      chordType: chordType,
      inversion: ChordInversion.second,
      octave: octave,
    );

    return [root, first, second];
  }

  /// Converts a scales.Key to a MusicalNote.
  ///
  /// This is a utility method to bridge between the scales module
  /// and the chord/note utilities.
  static MusicalNote keyToMusicalNote(scales.Key key) {
    switch (key) {
      case scales.Key.c:
        return MusicalNote.c;
      case scales.Key.cSharp:
        return MusicalNote.cSharp;
      case scales.Key.d:
        return MusicalNote.d;
      case scales.Key.dSharp:
        return MusicalNote.dSharp;
      case scales.Key.e:
        return MusicalNote.e;
      case scales.Key.f:
        return MusicalNote.f;
      case scales.Key.fSharp:
        return MusicalNote.fSharp;
      case scales.Key.g:
        return MusicalNote.g;
      case scales.Key.gSharp:
        return MusicalNote.gSharp;
      case scales.Key.a:
        return MusicalNote.a;
      case scales.Key.aSharp:
        return MusicalNote.aSharp;
      case scales.Key.b:
        return MusicalNote.b;
    }
  }

  /// Gets the display name for a chord inversion.
  ///
  /// Returns user-friendly names like "Root Position", "1st Inversion", etc.
  static String getInversionDisplayName(ChordInversion inversion) {
    switch (inversion) {
      case ChordInversion.root:
        return "Root Position";
      case ChordInversion.first:
        return "1st Inversion";
      case ChordInversion.second:
        return "2nd Inversion";
    }
  }

  /// Gets the display name for a chord type.
  ///
  /// Returns user-friendly names like "Major", "Minor", etc.
  static String getChordTypeDisplayName(ChordType type) {
    switch (type) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "Minor";
      case ChordType.diminished:
        return "Diminished";
      case ChordType.augmented:
        return "Augmented";
    }
  }
}
