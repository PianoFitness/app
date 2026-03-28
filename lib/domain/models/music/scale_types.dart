/// The different types of musical scales supported by the Piano Fitness app.
///
/// Each scale type represents a different pattern of intervals that creates
/// a unique musical character and sound.
enum ScaleType {
  /// The major scale (Ionian mode) - bright, happy sound
  major,

  /// The natural minor scale - darker, more melancholic sound
  minor,

  /// The Dorian mode - minor scale with raised 6th degree
  dorian,

  /// The Phrygian mode - minor scale with lowered 2nd degree
  phrygian,

  /// The Lydian mode - major scale with raised 4th degree
  lydian,

  /// The Mixolydian mode - major scale with lowered 7th degree
  mixolydian,

  /// The Aeolian mode - same as natural minor scale
  aeolian,

  /// The Locrian mode - diminished scale with lowered 2nd and 5th degrees
  locrian,
}

/// The twelve chromatic musical keys supported by the Piano Fitness app.
///
/// Each key represents a different starting pitch for scales and exercises.
/// Keys are named using the sharp (#) notation for black keys.
enum Key {
  /// C natural
  c,

  /// C sharp / D flat
  cSharp,

  /// D natural
  d,

  /// D sharp / E flat
  dSharp,

  /// E natural
  e,

  /// F natural
  f,

  /// F sharp / G flat
  fSharp,

  /// G natural
  g,

  /// G sharp / A flat
  gSharp,

  /// A natural
  a,

  /// A sharp / B flat
  aSharp,

  /// B natural
  b,
}

/// Represents the display names for a musical key.
///
/// This data structure co-locates the primary (conventional) name and
/// secondary (alternative) name for each key, making it easy to verify
/// musical conventions and maintain consistency.
class _KeyNames {
  const _KeyNames({required this.primary, this.secondary});

  /// The primary/conventional display name (uses flat notation for black keys)
  final String primary;

  /// The secondary/alternative display name (sharp notation for black keys)
  /// Null for natural keys that have no enharmonic equivalent
  final String? secondary;
}

/// Extension on [Key] to provide consistent display names across the app.
///
/// This centralizes the logic for displaying key names and follows musical
/// conventions for enharmonic equivalents.
extension KeyDisplay on Key {
  /// Mapping of keys to their display names, co-locating primary and secondary names.
  ///
  /// This makes it easy to verify that musical conventions are followed:
  /// - Natural keys (C, D, E, F, G, A, B) have no secondary name
  /// - Black keys use flat notation as primary (following key signature conventions)
  /// - Black keys include sharp notation as secondary (alternative notation)
  static const Map<Key, _KeyNames> _keyNameMap = {
    // Natural keys (white keys) - no enharmonic equivalents
    Key.c: _KeyNames(primary: "C"),
    Key.d: _KeyNames(primary: "D"),
    Key.e: _KeyNames(primary: "E"),
    Key.f: _KeyNames(primary: "F"),
    Key.g: _KeyNames(primary: "G"),
    Key.a: _KeyNames(primary: "A"),
    Key.b: _KeyNames(primary: "B"),

    // Black keys (enharmonic keys) - flat primary, sharp secondary
    Key.cSharp: _KeyNames(primary: "D♭", secondary: "C#"),
    Key.dSharp: _KeyNames(primary: "E♭", secondary: "D#"),
    Key.fSharp: _KeyNames(primary: "G♭", secondary: "F#"),
    Key.gSharp: _KeyNames(primary: "A♭", secondary: "G#"),
    Key.aSharp: _KeyNames(primary: "B♭", secondary: "A#"),
  };

  /// Returns the conventional display name for the key.
  ///
  /// For enharmonic keys (black keys), returns the more commonly used
  /// flat notation (D♭, E♭, G♭, A♭, B♭) rather than sharp notation.
  /// This follows standard musical key signature conventions where flat
  /// notation is preferred for most practical applications, as it aligns
  /// with how key signatures are typically written and taught in music theory.
  String get displayName {
    return _keyNameMap[this]!.primary;
  }

  /// Returns the full display name with enharmonic equivalent in parentheses.
  ///
  /// For natural keys (white keys), returns just the key name.
  /// For enharmonic keys (black keys), returns the conventional flat name
  /// followed by the sharp alternative in parentheses (e.g., "D♭ (C#)").
  /// This provides both notations while maintaining the preference for flat
  /// notation as the primary display format.
  String get fullDisplayName {
    final keyNames = _keyNameMap[this]!;
    final secondary = keyNames.secondary;

    // If there's a secondary name (enharmonic equivalent), include it in parentheses
    return secondary != null
        ? "${keyNames.primary} ($secondary)"
        : keyNames.primary;
  }
}
