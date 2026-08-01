/// The notated rhythmic value between one practice-step onset and the next.
enum PracticeStepNoteValue { whole, half, quarter, eighth, sixteenth }

/// Musical conversions for [PracticeStepNoteValue].
extension PracticeStepNoteValueX on PracticeStepNoteValue {
  /// The duration expressed as quarter-note beats.
  double get quarterNoteBeats => switch (this) {
    PracticeStepNoteValue.whole => 4.0,
    PracticeStepNoteValue.half => 2.0,
    PracticeStepNoteValue.quarter => 1.0,
    PracticeStepNoteValue.eighth => 0.5,
    PracticeStepNoteValue.sixteenth => 0.25,
  };
}
