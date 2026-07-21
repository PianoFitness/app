/// Converts between BPM and beat interval durations.
class TempoCalculator {
  const TempoCalculator._();

  /// Slowest supported tempo, in beats per minute.
  static const int minBpm = 40;

  /// Fastest supported tempo, in beats per minute.
  static const int maxBpm = 208;

  static const int _microsecondsPerMinute = 60000000;

  /// Converts [bpm] to the duration between beats.
  static Duration bpmToInterval(int bpm) {
    assert(bpm > 0, "bpm must be positive");
    final microseconds = (_microsecondsPerMinute / bpm).round();
    return Duration(microseconds: microseconds);
  }

  /// Clamps [bpm] to the supported [minBpm]-[maxBpm] range.
  static int clampBpm(int bpm) => bpm.clamp(minBpm, maxBpm);
}
