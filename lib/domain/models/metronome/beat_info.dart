import "package:piano_fitness/domain/models/metronome/beat_emphasis.dart";

/// Describes a single metronome beat: its position within the measure and
/// how it should be emphasized.
class BeatInfo {
  const BeatInfo({
    required this.beatNumber,
    required this.measureNumber,
    required this.emphasis,
    required this.isDownbeat,
  });

  /// 1-based position of this beat within the measure.
  final int beatNumber;

  /// 1-based measure count since the metronome started.
  final int measureNumber;

  /// How strongly this beat should sound/pulse.
  final BeatEmphasis emphasis;

  /// Whether this is beat 1 of the measure.
  final bool isDownbeat;
}
