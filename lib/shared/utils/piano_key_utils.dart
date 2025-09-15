/// Utility functions for piano key identification and manipulation.
///
/// This file contains helper functions for working with piano keys,
/// including identifying black vs white keys from MIDI note numbers.
library;

/// Determines if a MIDI note represents a black key on a piano.
///
/// Uses the standard piano layout where black keys occur at semitone
/// positions 1, 3, 6, 8, and 10 within each octave (0-11).
///
/// Examples:
/// - 60 (C4) → false (white key)
/// - 61 (C#4) → true (black key)
/// - 62 (D4) → false (white key)
/// - 63 (D#4) → true (black key)
///
/// [midiNote] The MIDI note number (0-127)
/// Returns true if the note is a black key, false if it's a white key
bool isBlackKey(int midiNote) => const {1, 3, 6, 8, 10}.contains(midiNote % 12);

/// Determines if a MIDI note represents a white key on a piano.
///
/// This is the inverse of [isBlackKey].
///
/// [midiNote] The MIDI note number (0-127)
/// Returns true if the note is a white key, false if it's a black key
bool isWhiteKey(int midiNote) => !isBlackKey(midiNote);

/// Gets all white key MIDI notes within a given range.
///
/// [startNote] The first MIDI note in the range (inclusive)
/// [endNote] The last MIDI note in the range (inclusive)
/// Returns a list of MIDI note numbers that represent white keys
List<int> getWhiteKeysInRange(int startNote, int endNote) {
  if (endNote < startNote) return [];
  return List.generate(
    endNote - startNote + 1,
    (i) => startNote + i,
  ).where(isWhiteKey).toList();
}

/// Gets all black key MIDI notes within a given range.
///
/// [startNote] The first MIDI note in the range (inclusive)
/// [endNote] The last MIDI note in the range (inclusive)
/// Returns a list of MIDI note numbers that represent black keys
List<int> getBlackKeysInRange(int startNote, int endNote) {
  if (endNote < startNote) return [];
  return List.generate(
    endNote - startNote + 1,
    (i) => startNote + i,
  ).where(isBlackKey).toList();
}
