import "package:fake_async/fake_async.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/metronome/metronome_scheduler.dart";

void main() {
  group("MetronomeScheduler", () {
    // Stopwatch itself isn't controlled by fake_async (only Timer/microtasks
    // are), so every test drives the scheduler's reference clock from the
    // FakeAsync instance's own simulated elapsed time via elapsedTimeProvider.
    test("fires beat 0 immediately on start", () {
      fakeAsync((async) {
        final firedBeats = <int>[];
        final scheduler = MetronomeScheduler(
          onBeat: firedBeats.add,
          elapsedTimeProvider: () => async.elapsed,
        );

        scheduler.start(bpm: 120);
        async.elapse(const Duration(milliseconds: 10));

        expect(firedBeats, equals([0]));
      });
    });

    test("fires beats at exact steady intervals with no drift", () {
      fakeAsync((async) {
        final firedAt = <int, Duration>{};
        final scheduler = MetronomeScheduler(
          onBeat: (beatIndex) => firedAt[beatIndex] = async.elapsed,
          elapsedTimeProvider: () => async.elapsed,
        );

        scheduler.start(bpm: 120); // 500ms/beat
        async.elapse(const Duration(milliseconds: 2050));

        expect(
          firedAt,
          equals({
            0: Duration.zero,
            1: const Duration(milliseconds: 500),
            2: const Duration(milliseconds: 1000),
            3: const Duration(milliseconds: 1500),
            4: const Duration(milliseconds: 2000),
          }),
        );
      });
    });

    test("stop() cancels beats already queued to fire", () {
      fakeAsync((async) {
        final firedBeats = <int>[];
        final scheduler = MetronomeScheduler(
          onBeat: firedBeats.add,
          elapsedTimeProvider: () => async.elapsed,
        );

        scheduler.start(bpm: 120);
        async.elapse(const Duration(milliseconds: 50)); // beat 0 fired
        scheduler.stop();
        async.elapse(const Duration(seconds: 2)); // beats 1+ must not fire

        expect(firedBeats, equals([0]));
        expect(scheduler.isRunning, isFalse);
      });
    });

    test("isRunning reflects start/stop state", () {
      fakeAsync((async) {
        final scheduler = MetronomeScheduler(
          onBeat: (_) {},
          elapsedTimeProvider: () => async.elapsed,
        );

        expect(scheduler.isRunning, isFalse);
        scheduler.start(bpm: 120);
        expect(scheduler.isRunning, isTrue);
        scheduler.stop();
        expect(scheduler.isRunning, isFalse);
      });
    });

    test("updateBpm changes spacing only for beats not yet scheduled "
        "(phase-continuous, no retroactive jump)", () {
      fakeAsync((async) {
        final firedAt = <int, Duration>{};
        final scheduler = MetronomeScheduler(
          onBeat: (beatIndex) => firedAt[beatIndex] = async.elapsed,
          elapsedTimeProvider: () => async.elapsed,
        );

        // 120 BPM = 500ms/beat. By t=450ms, beats 0 and 1 are already
        // queued (their due times, 0ms and 500ms, are within the 100ms
        // lookahead window) but beat 2 (due at 1000ms) is not yet queued.
        scheduler.start(bpm: 120);
        async.elapse(const Duration(milliseconds: 450));
        scheduler.updateBpm(60); // 1000ms/beat, from here on

        async.elapse(const Duration(milliseconds: 2600));

        expect(
          firedAt,
          equals({
            0: Duration.zero,
            1: const Duration(milliseconds: 500),
            // Already implied under the old tempo when updateBpm() was
            // called - keeps its due time instead of jumping.
            2: const Duration(milliseconds: 1000),
            // Beats after the change use the new, slower interval.
            3: const Duration(milliseconds: 2000),
            4: const Duration(milliseconds: 3000),
          }),
        );
      });
    });
  });
}
