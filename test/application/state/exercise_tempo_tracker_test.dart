import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/state/exercise_tempo_tracker.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";

void main() {
  group("ExerciseTempoTracker", () {
    test("records one onset per step and produces reliable timing", () {
      final tracker = ExerciseTempoTracker();
      for (var step = 0; step < 6; step++) {
        tracker.recordStepOnset(
          stepIndex: step,
          occurredAt: Duration(milliseconds: step * 400),
          source: ExerciseInputSource.externalMidi,
        );
      }

      final result = tracker.complete();
      expect(result.quality, TempoMeasurementQuality.reliable);
      expect(result.measuredTempoBpm, closeTo(150, 0.000001));
    });

    test("rejects duplicate step onsets", () {
      final tracker = ExerciseTempoTracker()
        ..recordStepOnset(
          stepIndex: 0,
          occurredAt: Duration.zero,
          source: ExerciseInputSource.externalMidi,
        )
        ..recordStepOnset(
          stepIndex: 0,
          occurredAt: const Duration(milliseconds: 400),
          source: ExerciseInputSource.externalMidi,
        );

      expect(tracker.complete().quality, TempoMeasurementQuality.unavailable);
    });

    test("marks virtual or mixed input unavailable", () {
      final tracker = ExerciseTempoTracker()
        ..recordStepOnset(
          stepIndex: 0,
          occurredAt: Duration.zero,
          source: ExerciseInputSource.externalMidi,
        )
        ..recordStepOnset(
          stepIndex: 1,
          occurredAt: const Duration(milliseconds: 400),
          source: ExerciseInputSource.virtualPiano,
        );

      expect(tracker.complete().quality, TempoMeasurementQuality.unavailable);
    });

    test("reset discards the previous attempt", () {
      final tracker = ExerciseTempoTracker()
        ..recordStepOnset(
          stepIndex: 0,
          occurredAt: Duration.zero,
          source: ExerciseInputSource.externalMidi,
        )
        ..reset();

      expect(tracker.complete().quality, TempoMeasurementQuality.unavailable);
    });
  });
}
