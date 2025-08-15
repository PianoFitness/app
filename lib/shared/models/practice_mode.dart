/// Practice modes available in the Piano Fitness app.
///
/// Each mode focuses on different aspects of piano technique:
/// - [scales]: Practice major, minor, and modal scales
/// - [chords]: Practice chord progressions and triads
/// - [arpeggios]: Practice broken chord patterns across octaves
enum PracticeMode {
  /// Practice scales in various keys and modes
  scales,

  /// Practice chord progressions and triads
  chords,

  /// Practice arpeggio patterns across multiple octaves
  arpeggios,
}

/// Extension to provide JSON serialization support for [PracticeMode].
///
/// This extension enables converting enum values to/from strings for
/// persistence and API communication, replacing brittle index-based
/// serialization with robust name-based serialization.
extension PracticeModeJson on PracticeMode {
  /// Converts the enum value to its string name for JSON serialization.
  ///
  /// Returns the enum name (e.g., "scales", "chords", "arpeggios").
  String toJson() => name;

  /// Creates a [PracticeMode] from a JSON string value.
  ///
  /// Uses [PracticeMode.values.byName] for modern Dart versions, with
  /// fallback to manual search for compatibility.
  ///
  /// Throws [ArgumentError] if the provided string doesn't match any
  /// enum value.
  static PracticeMode fromJson(String json) {
    try {
      // Use byName if available (Dart 2.15+)
      return PracticeMode.values.byName(json);
    } catch (e) {
      // Fallback for older Dart versions
      for (final mode in PracticeMode.values) {
        if (mode.name == json) {
          return mode;
        }
      }
      throw ArgumentError('Invalid PracticeMode: $json');
    }
  }
}
