/// A repeating left-hand broken-chord accompaniment figure.
///
/// The degree order is applied to each triad in a progression. Each pattern
/// fills one four-beat harmony unit with quarter-note onsets.
enum BrokenChordPattern {
  /// Root–fifth–third–fifth (1–5–3–5), a foundational accompaniment figure.
  rootFifthThirdFifth,

  /// Root–third–fifth–third (1–3–5–3), a close-position alternative.
  rootThirdFifthThird,
}

/// Musical information used by broken-chord accompaniment generators and UI.
extension BrokenChordPatternDetails on BrokenChordPattern {
  /// Zero-based chord-tone indexes in the order they are played.
  List<int> get chordToneIndexes => switch (this) {
    BrokenChordPattern.rootFifthThirdFifth => const [0, 2, 1, 2],
    BrokenChordPattern.rootThirdFifthThird => const [0, 1, 2, 1],
  };

  /// A compact, learner-facing description of the pattern.
  String get displayName => switch (this) {
    BrokenChordPattern.rootFifthThirdFifth => "1–5–3–5",
    BrokenChordPattern.rootThirdFifthThird => "1–3–5–3",
  };
}
