/// Practice modes available in the Piano Fitness app.
///
/// Each mode focuses on different aspects of piano technique:
/// - [scales]: Practice major, minor, and modal scales
/// - [chordsByKey]: Practice individual chord triads and inversions
/// - [arpeggios]: Practice broken chord patterns across octaves
/// - [chordProgressions]: Practice chord progressions using roman numeral notation
enum PracticeMode {
  /// Practice scales in various keys and modes
  scales,

  /// Practice individual chord triads and inversions
  chordsByKey,

  /// Practice arpeggio patterns across multiple octaves
  arpeggios,

  /// Practice chord progressions using roman numeral notation
  chordProgressions,
}

/// Extension to provide JSON serialization support for [PracticeMode].
///
/// This extension enables converting enum values to/from strings for
/// persistence and API communication, replacing brittle index-based
/// serialization with robust name-based serialization.
extension PracticeModeJson on PracticeMode {
  /// Converts the enum value to its string name for JSON serialization.
  ///
  /// Returns the enum name (e.g., "scales", "chordsByKey", "arpeggios").
  String toJson() => name;

  /// Creates a [PracticeMode] from a JSON string value.
  ///
  /// Uses [PracticeMode.values.byName] to find the enum value by name.
  ///
  /// Throws [ArgumentError] if the provided string doesn't match any
  /// enum value.
  static PracticeMode fromJson(String json) {
    try {
      return PracticeMode.values.byName(json);
    } on ArgumentError {
      throw ArgumentError(
        'Invalid PracticeMode: $json. Valid values are: ${PracticeMode.values.map((e) => e.name).join(', ')}',
      );
    }
  }
}
