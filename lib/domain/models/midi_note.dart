/// Value object representing a valid MIDI note number.
///
/// MIDI notes are numbered 0-127, where 60 is middle C (C4).
/// This class ensures that note values are always within the valid range.
class MidiNote {
  /// Creates a MIDI note with the given value.
  ///
  /// Throws [RangeError] if [value] is not in the range 0-127 (inclusive).
  MidiNote(this.value) {
    if (value < min || value > max) {
      throw RangeError(
        "MIDI note must be between $min and $max (inclusive), but got $value",
      );
    }
  }

  /// The MIDI note number (0-127).
  final int value;

  /// The minimum valid MIDI note number (C-1).
  static const int min = 0;

  /// The maximum valid MIDI note number (G9).
  static const int max = 127;

  /// Validates a note value and returns it if valid.
  ///
  /// Throws [RangeError] if the note is not in the range 0-127.
  static int validate(int note) {
    if (note < min || note > max) {
      throw RangeError(
        "MIDI note must be between $min and $max (inclusive), but got $note",
      );
    }
    return note;
  }

  /// Checks if a note value is valid without throwing.
  static bool isValid(int note) => note >= min && note <= max;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNote &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "MidiNote($value)";
}
