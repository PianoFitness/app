/// Represents which hand(s) should be used for practice exercises.
///
/// This enum is used throughout the practice system to filter and organize
/// musical exercises by hand. The system uses standard hand ranges:
/// - Left hand: typically plays lower octaves (C3-C4 range, MIDI 48-60)
/// - Right hand: typically plays higher octaves (C4-C5 range, MIDI 60-72)
/// - Both hands: full range or hands-together patterns
enum HandSelection {
  /// Practice with left hand only (lower octaves)
  left,

  /// Practice with right hand only (upper octaves)
  right,

  /// Practice with both hands together
  both,
}
