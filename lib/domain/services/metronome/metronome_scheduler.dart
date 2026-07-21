import "dart:async";

import "package:piano_fitness/domain/services/metronome/tempo_calculator.dart";

/// Fires [onBeat] at a steady tempo using a lookahead scheduling pattern:
/// a coarse periodic timer decides which beats are due soon, then a
/// short-lived one-shot [Timer] fires each one close to its exact due time,
/// computed from an absolute clock (a real [Stopwatch] by default) so error
/// never accumulates across a session.
///
/// See docs/specifications/metronome-component.md#lookahead-scheduling for
/// why this shape was chosen over an Isolate-based timer, and for the
/// realistic accuracy this design targets (this is not sample-accurate).
class MetronomeScheduler {
  /// Creates a scheduler. [elapsedTimeProvider] is a testing seam - it's
  /// only needed to drive the scheduler's reference clock from a
  /// `fakeAsync`-controlled clock in tests (`Stopwatch` itself isn't faked
  /// by `package:fake_async`, unlike `Timer`). Production code should omit
  /// it and get a real monotonic [Stopwatch].
  MetronomeScheduler({
    required this.onBeat,
    Duration Function()? elapsedTimeProvider,
  }) : _elapsedTimeProvider = elapsedTimeProvider,
       _ownedClock = elapsedTimeProvider == null ? Stopwatch() : null;

  /// Called when a beat is due, with its 0-based absolute index since
  /// [start]. This IS the timing-critical path - callers that trigger audio
  /// should do so synchronously, before any other work.
  final void Function(int beatIndex) onBeat;

  static const _tickInterval = Duration(milliseconds: 20);
  static const _scheduleAheadTime = Duration(milliseconds: 100);

  final Duration Function()? _elapsedTimeProvider;
  final Stopwatch? _ownedClock;

  Timer? _schedulerTimer;
  final List<Timer> _pendingBeatTimers = [];
  Duration _beatInterval = TempoCalculator.bpmToInterval(120);
  int _scheduledBeatIndex = 0;

  // Anchor point that _dueTime is computed relative to. Reset on start();
  // moved forward to the next unscheduled beat on every updateBpm() call so
  // a tempo change only affects beats not yet queued, instead of retroactively
  // shifting the whole timeline (which would cause a stutter/jump).
  Duration _anchorTime = Duration.zero;
  int _anchorBeatIndex = 0;

  Duration get _elapsed => _elapsedTimeProvider?.call() ?? _ownedClock!.elapsed;

  /// Whether the scheduler is currently running.
  bool get isRunning => _schedulerTimer != null;

  /// Starts firing beats at [bpm], beginning immediately with beat 0.
  void start({required int bpm}) {
    stop();
    _beatInterval = TempoCalculator.bpmToInterval(bpm);
    _scheduledBeatIndex = 0;
    _anchorBeatIndex = 0;
    _anchorTime = Duration.zero;
    _ownedClock
      ?..reset()
      ..start();
    _tick();
    _schedulerTimer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  /// Stops the scheduler and cancels any beats already queued to fire.
  void stop() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    _ownedClock?.stop();
    for (final timer in _pendingBeatTimers) {
      timer.cancel();
    }
    _pendingBeatTimers.clear();
  }

  /// Changes tempo without resetting phase - beats already queued keep
  /// their scheduled time; only beats scheduled after this call use the new
  /// interval, so tap-tempo and tempo gradation don't cause a stutter.
  void updateBpm(int bpm) {
    _anchorTime = _dueTime(_scheduledBeatIndex);
    _anchorBeatIndex = _scheduledBeatIndex;
    _beatInterval = TempoCalculator.bpmToInterval(bpm);
  }

  void _tick() {
    final now = _elapsed;
    while (_dueTime(_scheduledBeatIndex) < now + _scheduleAheadTime) {
      final beatIndex = _scheduledBeatIndex;
      final delay = _dueTime(beatIndex) - now;
      late final Timer beatTimer;
      beatTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
        _pendingBeatTimers.remove(beatTimer);
        onBeat(beatIndex);
      });
      _pendingBeatTimers.add(beatTimer);
      _scheduledBeatIndex++;
    }
  }

  Duration _dueTime(int beatIndex) =>
      _anchorTime + _beatInterval * (beatIndex - _anchorBeatIndex);
}
