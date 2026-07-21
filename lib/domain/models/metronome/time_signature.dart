import "package:piano_fitness/domain/models/metronome/beat_emphasis.dart";

/// A time signature and its per-beat accent pattern.
///
/// The [pattern] length always equals [numerator]; index 0 is always
/// [BeatEmphasis.strong] (the downbeat).
class TimeSignature {
  const TimeSignature._(this.numerator, this.denominator, this.pattern);

  /// Number of beats per measure.
  final int numerator;

  /// Note value that represents one beat (e.g. 4 = quarter note).
  final int denominator;

  /// Emphasis for each beat in the measure, index 0 is the downbeat.
  final List<BeatEmphasis> pattern;

  /// Common time: strong, weak, medium, weak.
  static const fourFour = TimeSignature._(4, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.medium,
    BeatEmphasis.weak,
  ]);

  /// Waltz time: strong, weak, weak.
  static const threeFour = TimeSignature._(3, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
  ]);

  /// March time: strong, weak.
  static const twoFour = TimeSignature._(2, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
  ]);

  /// Compound duple time: two groups of three, each with its own accent.
  static const sixEight = TimeSignature._(6, 8, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
    BeatEmphasis.medium,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
  ]);

  /// The presets available for selection in the metronome UI.
  static const List<TimeSignature> common = [
    fourFour,
    threeFour,
    twoFour,
    sixEight,
  ];

  /// Display label, e.g. "4/4".
  String get label => "$numerator/$denominator";

  @override
  bool operator ==(Object other) =>
      other is TimeSignature &&
      other.numerator == numerator &&
      other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}
