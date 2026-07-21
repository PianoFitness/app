import "package:piano_fitness/domain/models/metronome/beat_info.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";

/// Computes beat position/emphasis info from a beat index and time
/// signature.
///
/// Stateless by design: MetronomeScheduler's beat index is already an
/// absolute count from the start of playback, so beat/measure number and
/// emphasis can always be derived directly from it and the current time
/// signature - there's no running counter that needs to be kept in sync
/// with the caller's own state.
class BeatTracker {
  const BeatTracker._();

  /// Computes the [BeatInfo] for the given absolute [beatIndex] (0-based,
  /// as produced by MetronomeScheduler) under [timeSignature].
  static BeatInfo beatAt(int beatIndex, TimeSignature timeSignature) {
    final beatInMeasure = beatIndex % timeSignature.numerator;
    final measureNumber = beatIndex ~/ timeSignature.numerator + 1;

    return BeatInfo(
      beatNumber: beatInMeasure + 1,
      measureNumber: measureNumber,
      emphasis: timeSignature.pattern[beatInMeasure],
      isDownbeat: beatInMeasure == 0,
    );
  }
}
