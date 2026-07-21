import "package:piano_fitness/domain/models/metronome/beat_info.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";

/// Tracks position within a measure as beats arrive from the scheduler,
/// translating a beat index into [BeatInfo] (beat number, measure number,
/// emphasis).
class BeatTracker {
  BeatTracker(this._timeSignature);

  TimeSignature _timeSignature;

  /// Computes the [BeatInfo] for the given absolute [beatIndex] (0-based,
  /// as produced by MetronomeScheduler) without mutating any state -
  /// callers may query beats out of order or replay history.
  BeatInfo beatAt(int beatIndex) {
    final beatInMeasure = beatIndex % _timeSignature.numerator;
    final measureNumber = beatIndex ~/ _timeSignature.numerator + 1;

    return BeatInfo(
      beatNumber: beatInMeasure + 1,
      measureNumber: measureNumber,
      emphasis: _timeSignature.pattern[beatInMeasure],
      isDownbeat: beatInMeasure == 0,
    );
  }

  /// Changes the active time signature; takes effect from the next beat
  /// index queried (an in-progress measure's beat count doesn't retroactively
  /// change).
  void setTimeSignature(TimeSignature timeSignature) {
    _timeSignature = timeSignature;
  }
}
