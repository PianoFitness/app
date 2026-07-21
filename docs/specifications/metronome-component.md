# Metronome Component Specification

## Overview

The Metronome component is a precision timing tool essential for piano practice. It provides audible and visual beat references, scheduled ahead of time (see [Lookahead Scheduling](#lookahead-scheduling)) so brief UI activity on Flutter's rendering thread doesn't perceptibly disrupt timing. It targets the realistic accuracy bounds in [Precision Standards](#precision-standards) — good enough for practice tempo reference and exercise timing validation, not studio-grade sample accuracy.

## Requirements

### Functional Requirements

- **Tempo range**: 40–208 BPM with 1 BPM precision.
- **Time signatures**: Must support common signatures (4/4, 3/4, 2/4, 6/8, 9/8, 12/8), complex signatures (5/4, 7/8, 11/8), and custom numerator/denominator combinations.
- **Beat emphasis**: Downbeats must be accented; the pattern must support secondary accents and subdivisions per time signature.
- **Sound options**: Must offer at least click, bell, wood block, and digital beep sounds, plus a silent (visual-only) mode.
- **Tap tempo**: User must be able to set the tempo by tapping a rhythm; BPM is calculated from the tap interval.
- **Tempo gradation**: Must support configurable, automatic tempo increases during a practice session.
- **Subdivisions**: Must support quarter note, eighth note, triplet, and sixteenth note subdivisions.
- **Visual pulse**: A synchronized visual indicator must reflect each beat alongside audio output.

### Performance Requirements

See [Critical Timing Requirements](#critical-timing-requirements) below for the canonical timing constraints.

## Critical Timing Requirements

### Precision Standards

These targets are the actual acceptance criteria for this component. They are
set by what a `Timer`/`Stopwatch`-driven scheduler calling `audioplayers` can
realistically achieve on mobile hardware — see
[Architecture Design](#architecture-design) for why, and
[Testing and Validation](#testing-and-validation) for how they're measured.

- **Scheduling accuracy**: ≤10 ms average deviation, ≤25 ms worst-case
  deviation, between a beat's intended time and the moment playback is
  triggered, under normal UI load. This is an engineering target to validate
  empirically on real devices, not a physical guarantee.
- **Long-term drift**: Zero *cumulative* drift over 60+ minutes — beat times
  are computed from an absolute start time (`startTime + n × interval`), never
  by repeatedly adding an interval to the previous beat, so per-tick error
  cannot accumulate over a session even though it doesn't shrink to zero.
- **Load independence**: The scheduler uses a lookahead window (beats are
  queued up to ~100 ms before they're due) so brief UI jank doesn't cause a
  beat to be dropped or delayed beyond the deviation targets above; sustained
  heavy load can still push individual beats past the worst-case figure.
- **Audio latency**: Trigger-to-sound delay depends on `audioplayers`'
  `PlayerMode` and the device; use `PlayerMode.lowLatency` (see
  [Audio System](#audio-system)) and measure actual latency on target devices
  during implementation rather than assuming a number here.
- **Background operation**: Not attempted in this phase — see
  [Platform Considerations](#platform-considerations). Audio playback and the
  Dart event loop are both suspended or throttled when backgrounded on iOS/
  Android without additional native work (foreground service / background
  audio session), which is out of scope until there's a concrete need for it.

### Musical Timing Context

- **Human Perception**: Musicians notice timing variations >3ms
- **Professional Standards**: Recording studios require &lt;1ms accuracy
- **Practice Effectiveness**: Inconsistent timing disrupts muscle memory
- **Exercise Validation**: Timing analysis requires precise reference
- **Ensemble Coordination**: Group practice depends on stable timing

> **Honesty check**: the &lt;1ms figure above describes studio hardware (dedicated
> DSP chips, ASIO/CoreAudio callback-driven clocks), not a Flutter app calling a
> general-purpose audio plugin from Dart. Mobile OSes are not real-time
> operating systems, and `audioplayers` has no "play at sample N" API — every
> layer between a Dart `Timer` firing and sound actually leaving the speaker
> (Dart event loop → platform channel → OS audio pipeline) adds variable
> latency that this app cannot fully eliminate. Section
> [Critical Timing Requirements](#critical-timing-requirements) states the
> realistic targets this implementation is actually held to; treat the &lt;1ms
> and >3ms numbers above as context for *why* timing matters, not as this
> component's acceptance criteria.

## Architecture Design

### Why Not an Isolate

An earlier draft of this spec ran timing in a separate `Isolate`, on the
theory that isolating the timer from the UI thread would eliminate jitter.
That doesn't hold up: `audioplayers` is a platform-channel plugin, and
platform channel calls have to originate from the main isolate, so every beat
still has to cross back to the main isolate to actually trigger sound. That
round trip (isolate → `SendPort` → event loop → platform channel) adds message
latency without removing the one thing that actually causes audible jitter —
the UI thread being busy when the click needs to fire. An isolate would only
pay for itself if profiling showed the *scheduling decision* itself was being
stalled by heavy main-isolate work; that hasn't been demonstrated, so this
spec starts with the simpler single-isolate design and revisits an isolate
only if real measurements justify it.

### Lookahead Scheduling

Instead, this component uses the scheduling pattern proven out for Web Audio
metronomes (Chris Wilson's "A Tale of Two Clocks"): decouple *when the
scheduler runs* from *when a beat is due*. A cheap, imprecise `Timer.periodic`
wakes up frequently just to ask "which beats are due soon?" — it does not need
to be accurate itself. Any beat inside a short lookahead window gets its own
one-shot `Timer` set to fire close to its exact due time, computed from an
absolute clock (`Stopwatch`, not `DateTime.now()`, which can jump on NTP
adjustments) so error never accumulates across a session.

```dart
class MetronomeScheduler {
  MetronomeScheduler({required this.onBeat});

  /// Called on the main isolate when a beat is due; expected to trigger
  /// playback via AudioPool.start() (see Audio System) as quickly as
  /// possible — this call IS the timing-critical path.
  final void Function(int beatIndex) onBeat;

  static const _tickInterval = Duration(milliseconds: 20);
  static const _scheduleAheadTime = Duration(milliseconds: 100);

  final Stopwatch _clock = Stopwatch();
  Timer? _schedulerTimer;
  Duration _beatInterval = TempoCalculator.bpmToInterval(120);
  int _scheduledBeatIndex = 0;

  // Anchor that _dueTime is computed relative to. Reset on start(); moved
  // forward to the next unscheduled beat on every updateBpm() call so a
  // tempo change only affects beats not yet queued, instead of retroactively
  // recomputing the whole timeline (which would cause a stutter/jump — see
  // the callout below updateBpm).
  Duration _anchorTime = Duration.zero;
  int _anchorBeatIndex = 0;

  void start({required int bpm}) {
    _beatInterval = TempoCalculator.bpmToInterval(bpm);
    _clock
      ..reset()
      ..start();
    _scheduledBeatIndex = 0;
    _anchorBeatIndex = 0;
    _anchorTime = Duration.zero;
    _schedulerTimer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void stop() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    _clock.stop();
  }

  /// Changes tempo without resetting phase — the next beat still lands on
  /// schedule, only beats after it use the new interval.
  void updateBpm(int bpm) {
    _anchorTime = _dueTime(_scheduledBeatIndex);
    _anchorBeatIndex = _scheduledBeatIndex;
    _beatInterval = TempoCalculator.bpmToInterval(bpm);
  }

  void _tick() {
    final now = _clock.elapsed;
    while (_dueTime(_scheduledBeatIndex) < now + _scheduleAheadTime) {
      final beatIndex = _scheduledBeatIndex;
      final delay = _dueTime(beatIndex) - now;
      Timer(delay.isNegative ? Duration.zero : delay, () => onBeat(beatIndex));
      _scheduledBeatIndex++;
    }
  }

  Duration _dueTime(int beatIndex) =>
      _anchorTime + _beatInterval * (beatIndex - _anchorBeatIndex);
}
```

Key properties of this design:

- **No cumulative drift**: `_dueTime` is computed from `beatIndex × interval`,
  not by repeatedly adding to the previous beat's time, so rounding error
  can't accumulate.
- **Jank tolerance**: the 100 ms lookahead window means a scheduler tick that
  runs a few ms late (e.g. because of a dropped frame) still schedules
  upcoming beats on time — only sustained blocking of the main isolate for
  longer than the lookahead window causes an audible miss.
- **Tempo changes don't reset phase**: `updateBpm` changes the interval used
  for beats not yet scheduled, without restarting the clock, so tap-tempo and
  tempo gradation don't cause a stutter.
- **The remaining error is real, not a code bug**: the final `Timer(delay,
  ...)` is still a Dart `Timer`, bounded by the event loop and OS scheduler —
  this is why the target in
  [Precision Standards](#precision-standards) is single-digit-to-low-tens of
  milliseconds, not sub-millisecond.

## Timing Implementation

Beat-to-beat timing is `MetronomeScheduler`, defined above in
[Lookahead Scheduling](#lookahead-scheduling). This section covers the
supporting BPM/subdivision math it's built on.

### BPM Calculation and Conversion

```dart
class TempoCalculator {
  static Duration bpmToInterval(int bpm) {
    // 60,000,000 microseconds per minute / BPM = microseconds per beat
    final microseconds = (60000000 / bpm).round();
    return Duration(microseconds: microseconds);
  }
  
  static int intervalToBpm(Duration interval) {
    return (60000000 / interval.inMicroseconds).round();
  }
  
  static Duration subdivisionInterval(int bpm, NoteValue subdivision) {
    final quarterNoteInterval = bpmToInterval(bpm);
    return Duration(
      microseconds: (quarterNoteInterval.inMicroseconds / subdivision.ratio).round(),
    );
  }
}

enum NoteValue {
  whole(0.25),
  half(0.5),
  quarter(1.0),
  eighth(2.0),
  sixteenth(4.0),
  triplet(3.0);
  
  const NoteValue(this.ratio);
  final double ratio;
}
```

## Beat Pattern Management

### Time Signature Support

```dart
class TimeSignature {
  final int numerator;
  final int denominator;
  final List<BeatEmphasis> pattern;
  
  const TimeSignature._(this.numerator, this.denominator, this.pattern);
  
  static const fourFour = TimeSignature._(4, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.medium,
    BeatEmphasis.weak,
  ]);
  
  static const threeFour = TimeSignature._(3, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
  ]);
  
  static const twoFour = TimeSignature._(2, 4, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
  ]);
  
  // Compound time signatures
  static const sixEight = TimeSignature._(6, 8, [
    BeatEmphasis.strong,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
    BeatEmphasis.medium,
    BeatEmphasis.weak,
    BeatEmphasis.weak,
  ]);
}

enum BeatEmphasis {
  strong(1.0),    // Downbeat - highest volume/pitch
  medium(0.7),    // Secondary accent
  weak(0.4);      // Regular beat - lower volume/pitch
  
  const BeatEmphasis(this.intensity);
  final double intensity;
}
```

### Beat Tracking and Accent Patterns

```dart
class BeatTracker {
  TimeSignature _timeSignature;
  int _currentBeat = 0;
  int _currentMeasure = 0;
  
  BeatTracker(this._timeSignature);
  
  BeatInfo nextBeat() {
    _currentBeat = (_currentBeat + 1) % _timeSignature.numerator;
    if (_currentBeat == 0) {
      _currentMeasure++;
    }
    
    return BeatInfo(
      beatNumber: _currentBeat + 1,
      measureNumber: _currentMeasure + 1,
      emphasis: _timeSignature.pattern[_currentBeat],
      isDownbeat: _currentBeat == 0,
    );
  }
  
  void reset() {
    _currentBeat = 0;
    _currentMeasure = 0;
  }
}

class BeatInfo {
  final int beatNumber;
  final int measureNumber;
  final BeatEmphasis emphasis;
  final bool isDownbeat;
  
  const BeatInfo({
    required this.beatNumber,
    required this.measureNumber,
    required this.emphasis,
    required this.isDownbeat,
  });
}
```

## Audio System

This app already depends on `audioplayers` (see `pubspec.yaml`), which ships
`AudioPool` — a pool of pre-loaded players built specifically for "extremely
quick firing, repetitive ... sounds" (its own doc comment), plus
`PlayerMode.lowLatency` for lower trigger-to-sound latency than the default
`MediaPlayer`-backed mode. That's a direct fit for a metronome click, and it
means **no new audio dependency is needed** — the earlier draft's
`just_audio`/`flutter_native_audio` choices are dropped.

Only one sound asset currently exists —
`assets/audio/218851__kellyconidi__highbell.mp3` (a bell). The "click, bell,
wood block, digital beep" sound roster in
[Functional Requirements](#functional-requirements) needs three more assets
before it can ship; until they're sourced, implementation should start with
the bell as the single default sound plus the silent/visual-only mode, not
block on the full roster.

### Sound Playback

```dart
class MetronomeAudioEngine {
  MetronomeAudioEngine(this._soundAssetPaths);

  /// One AssetSource path per MetronomeSound (excluding `silent`).
  final Map<MetronomeSound, String> _soundAssetPaths;
  final Map<MetronomeSound, AudioPool> _pools = {};

  Future<void> initialize() async {
    for (final entry in _soundAssetPaths.entries) {
      _pools[entry.key] = await AudioPool.createFromAsset(
        path: entry.value,
        // A few pre-warmed players per sound lets closely-spaced beats
        // (fast tempos, subdivisions) overlap without waiting on the
        // previous click to finish.
        minPlayers: 2,
        maxPlayers: 4,
        playerMode: PlayerMode.lowLatency,
      );
    }
  }

  /// This IS the timing-critical call — invoke it directly from
  /// MetronomeScheduler.onBeat, with no `await`ed work ahead of it.
  Future<void> playBeat(MetronomeSound sound, BeatEmphasis emphasis) async {
    if (sound == MetronomeSound.silent) return;
    await _pools[sound]!.start(volume: emphasis.intensity);
  }

  Future<void> dispose() async {
    // Required for PlayerMode.lowLatency players — see AudioPool docs.
    for (final pool in _pools.values) {
      for (final player in pool.currentPlayers.values) {
        await player.dispose();
      }
    }
  }
}

enum MetronomeSound {
  click,
  bell,
  woodBlock,
  digitalBeep,
  silent,
}
```

### Low-Latency Audio Notes

- **`PlayerMode.lowLatency`**: reduces trigger-to-sound latency versus the
  default mode, at the cost of losing duration/completion callbacks and a
  short max clip length — both fine for a one-shot click, and why `dispose()`
  must be called explicitly instead of relying on `onPlayerComplete`.
  Actual latency is device- and platform-dependent; measure it on target
  devices rather than assuming a figure (see
  [Precision Standards](#precision-standards)).
- **Preloading**: `AudioPool.createFromAsset` loads and pre-instantiates
  players up front, avoiding first-hit decode/allocation latency on the first
  beat.
- **Pool size**: `minPlayers`/`maxPlayers` bound how many overlapping
  instances of a sound can play at once — relevant at fast tempos or with
  subdivisions where one click's tail may still be sounding when the next
  fires.

## Visual Synchronization

### Beat Indicator

```dart
class MetronomeBeatIndicator extends StatefulWidget {
  final Stream<BeatInfo> beatStream;
  final Color beatColor;
  final Color accentColor;
  final bool showMeasureNumbers;
  
  const MetronomeBeatIndicator({
    Key? key,
    required this.beatStream,
    this.beatColor = Colors.blue,
    this.accentColor = Colors.red,
    this.showMeasureNumbers = true,
  }) : super(key: key);
  
  @override
  State<MetronomeBeatIndicator> createState() => _MetronomeBeatIndicatorState();
}

class _MetronomeBeatIndicatorState extends State<MetronomeBeatIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  BeatInfo? _currentBeat;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    widget.beatStream.listen(_onBeat);
  }
  
  void _onBeat(BeatInfo beat) {
    setState(() {
      _currentBeat = beat;
    });
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }
}
```

### Timing Validation and Drift Detection

```dart
class TimingValidator {
  final List<Duration> _beatIntervals = [];
  final int _maxSamples = 100;
  Duration? _lastBeatTime;
  
  void recordBeat(Duration currentTime) {
    if (_lastBeatTime != null) {
      final interval = currentTime - _lastBeatTime!;
      _beatIntervals.add(interval);
      
      if (_beatIntervals.length > _maxSamples) {
        _beatIntervals.removeAt(0);
      }
    }
    _lastBeatTime = currentTime;
  }
  
  TimingAnalysis analyze(Duration expectedInterval) {
    if (_beatIntervals.length < 10) {
      return TimingAnalysis.insufficient();
    }
    
    final avgInterval = _beatIntervals.reduce((a, b) => a + b) ~/ _beatIntervals.length;
    final deviations = _beatIntervals.map((interval) => 
      (interval.inMicroseconds - expectedInterval.inMicroseconds).abs()
    ).toList();
    
    final maxDeviation = deviations.reduce(math.max);
    final avgDeviation = deviations.reduce((a, b) => a + b) / deviations.length;
    final drift = avgInterval.inMicroseconds - expectedInterval.inMicroseconds;
    
    return TimingAnalysis(
      averageInterval: avgInterval,
      maxDeviation: Duration(microseconds: maxDeviation),
      averageDeviation: Duration(microseconds: avgDeviation.round()),
      drift: Duration(microseconds: drift),
      isAccurate: maxDeviation < 25000, // 25ms worst-case tolerance, see Precision Standards
    );
  }
}

class TimingAnalysis {
  final Duration averageInterval;
  final Duration maxDeviation;
  final Duration averageDeviation;
  final Duration drift;
  final bool isAccurate;
  
  const TimingAnalysis({
    required this.averageInterval,
    required this.maxDeviation,
    required this.averageDeviation,
    required this.drift,
    required this.isAccurate,
  });
  
  TimingAnalysis.insufficient()
      : averageInterval = Duration.zero,
        maxDeviation = Duration.zero,
        averageDeviation = Duration.zero,
        drift = Duration.zero,
        isAccurate = false;
}
```

## Putting It Together

`PrecisionMetronome` is the public facade that wires
[`MetronomeScheduler`](#lookahead-scheduling) (when),
[`BeatTracker`](#beat-tracking-and-accent-patterns) (which beat, what
emphasis), and [`MetronomeAudioEngine`](#sound-playback) (what sound) into the
API the rest of the app uses.

```dart
class PrecisionMetronome {
  PrecisionMetronome({required MetronomeAudioEngine audioEngine})
      : _audioEngine = audioEngine;

  final MetronomeAudioEngine _audioEngine;
  final _beatController = StreamController<BeatInfo>.broadcast();

  late MetronomeScheduler _scheduler;
  BeatTracker _beatTracker = BeatTracker(TimeSignature.fourFour);
  MetronomeSound _sound = MetronomeSound.bell;
  int _bpm = 120;

  Stream<BeatInfo> get beatStream => _beatController.stream;

  void setBpm(int bpm) {
    _bpm = bpm;
    _scheduler.updateBpm(bpm);
  }

  void setTimeSignature(TimeSignature signature) {
    _beatTracker = BeatTracker(signature);
  }

  void setSound(MetronomeSound sound) => _sound = sound;

  void start() {
    _beatTracker.reset();
    _scheduler = MetronomeScheduler(onBeat: _onSchedulerBeat)
      ..start(bpm: _bpm);
  }

  void stop() => _scheduler.stop();

  void _onSchedulerBeat(int beatIndex) {
    // Timing-critical: trigger playback before touching the stream/UI.
    final beat = _beatTracker.nextBeat();
    unawaited(_audioEngine.playBeat(_sound, beat.emphasis));
    _beatController.add(beat);
  }
}
```

## Exercise Integration

### Timing Reference for Practice

```dart
class ExerciseMetronome extends PrecisionMetronome {
  ExerciseMetronome({
    required super.audioEngine,
    required this.onExerciseBeat,
    required this.onTimingAnalysis,
  });

  final Function(BeatInfo) onExerciseBeat;
  final Function(TimingAnalysis) onTimingAnalysis;

  final TimingValidator _timingValidator = TimingValidator();
  final Stopwatch _clock = Stopwatch();

  void startExercise(Exercise exercise) {
    setTimeSignature(exercise.timeSignature);
    setBpm(exercise.targetTempo);
    _clock
      ..reset()
      ..start();
    start();

    // Provide timing reference to exercise system
    beatStream.listen((beat) {
      onExerciseBeat(beat);
      _timingValidator.recordBeat(_clock.elapsed);

      // Analyze timing for exercise validation
      if (beat.beatNumber == 1) {
        final expectedInterval = TempoCalculator.bpmToInterval(exercise.targetTempo);
        onTimingAnalysis(_timingValidator.analyze(expectedInterval));
      }
    });
  }
}
```

### MIDI Timing Validation

```dart
class MidiTimingValidator {
  final PrecisionMetronome metronome;
  final List<MidiTimingEvent> _events = [];
  
  MidiTimingValidator(this.metronome);
  
  void recordMidiEvent(int midiNote, Duration timestamp) {
    final nearestBeat = _findNearestBeat(timestamp);
    final deviation = timestamp - nearestBeat.timestamp;
    
    _events.add(MidiTimingEvent(
      midiNote: midiNote,
      timestamp: timestamp,
      nearestBeat: nearestBeat,
      deviation: deviation,
    ));
  }
  
  TimingAccuracy analyzePerformance() {
    final deviations = _events.map((e) => e.deviation.inMilliseconds.abs()).toList();
    final averageDeviation = deviations.reduce((a, b) => a + b) / deviations.length;
    final maxDeviation = deviations.reduce(math.max);
    
    return TimingAccuracy(
      averageDeviation: averageDeviation,
      maxDeviation: maxDeviation,
      onBeatCount: deviations.where((d) => d < 50).length, // Within 50ms
      totalNotes: _events.length,
    );
  }
}

class MidiTimingEvent {
  final int midiNote;
  final Duration timestamp;
  final BeatReference nearestBeat;
  final Duration deviation;
  
  const MidiTimingEvent({
    required this.midiNote,
    required this.timestamp,
    required this.nearestBeat,
    required this.deviation,
  });
}
```

## Platform Considerations

This spec deliberately stays within `audioplayers` + Dart's own `Timer`/
`Stopwatch` (see [Architecture Design](#architecture-design)) rather than
reaching for native audio APIs. The items below are **not part of this
phase** — they're the escalation path if measured accuracy (per
[Testing and Validation](#testing-and-validation)) doesn't meet the targets
in [Precision Standards](#precision-standards) on real devices, or if
background operation becomes a real requirement.

### If Background Operation Is Needed

- **iOS**: requires a configured background audio session; the Dart event
  loop itself is throttled when backgrounded, so timing would need to move
  into native code (Audio Units / `AVAudioEngine`) rather than Dart.
- **Android**: requires a foreground service to avoid the process being
  suspended; same constraint on Dart-side timing while backgrounded.

### If Measured Accuracy Isn't Good Enough

- Move beat-triggered playback into a native platform-channel audio engine
  (`AVAudioEngine` on iOS, `AAudio`/Oboe on Android) that supports scheduling
  a buffer to play at a precise sample offset, instead of triggering
  `audioplayers` from a Dart `Timer`. This is a significant native-code
  investment and should only be taken on if real measurements show the
  current approach isn't good enough for practice use — not preemptively.
- Re-evaluate whether an `Isolate` for the scheduling loop actually helps
  once there's profiling data showing the main isolate is the bottleneck
  (see [Why Not an Isolate](#why-not-an-isolate)).

## Testing and Validation

### Precision Testing

Uses `Stopwatch`, not `DateTime.now()`, for the reference clock — wall-clock
time can jump (NTP sync, DST) and doesn't reflect elapsed monotonic time.

```dart
class MetronomeTimingTest {
  static Future<void> testTimingAccuracy() async {
    final clock = Stopwatch()..start();
    final scheduler = MetronomeScheduler(onBeat: (beatIndex) {
      // In production this triggers playback; for the test it just records
      // when the beat actually fired relative to the shared clock.
    });
    final validator = TimingValidator();
    final testDuration = Duration(minutes: 5);

    scheduler.start(bpm: 120);
    // Wrap onBeat (or hook a test seam) so every fired beat calls:
    //   validator.recordBeat(clock.elapsed);
    await Future.delayed(testDuration);
    scheduler.stop();

    final analysis = validator.analyze(Duration(milliseconds: 500)); // 120 BPM
    expect(analysis.isAccurate, true); // see Precision Standards for the threshold
    expect(analysis.maxDeviation.inMilliseconds, lessThan(25));
  }
}
```

Run this on real target devices (not just an emulator/simulator, whose timing
characteristics differ from real hardware) before treating the targets below
as met.

### Performance Benchmarks

Targets from [Precision Standards](#precision-standards), restated as
pass/fail benchmarks:

- **Scheduling Accuracy**: ≤10ms average deviation, ≤25ms worst-case, under
  normal UI load — measured empirically per [Precision Testing](#precision-testing).
- **CPU Usage**: &lt;2% on modern devices
- **Memory Usage**: &lt;10MB for metronome subsystem
- **Battery Impact**: Minimal — no background wake locks or continuous
  polling faster than the 20ms scheduler tick

## Dependencies

### Required Packages

No new dependencies are required. The design in
[Architecture Design](#architecture-design) and
[Audio System](#audio-system) is built entirely on packages already in
`pubspec.yaml`:

```yaml
dependencies:
  # Already present — AudioPool + PlayerMode.lowLatency cover click playback
  audioplayers: ^6.0.0
```

`dart:async` (`Timer`) and `dart:core` (`Stopwatch`) cover scheduling; no
isolate or third-party timer package is used (see
[Why Not an Isolate](#why-not-an-isolate)).

### If Escalating to Native Audio

Only relevant if [Platform Considerations](#platform-considerations)'
escalation path is taken:

- **iOS**: Core Audio / `AVAudioEngine` framework integration
- **Android**: AAudio/Oboe integration
- **Web**: Web Audio API (this app does not currently target web; the
  lookahead-scheduler pattern this spec uses originates from the Web Audio
  world and would carry over directly if web support is added)

## Future Enhancements

### Phase 2 Features

- **Polyrhythm Support**: Multiple simultaneous beat patterns
- **Swing Timing**: Jazz-style beat subdivision
- **Accelerando/Ritardando**: Gradual tempo changes
- **MIDI Clock Sync**: External device synchronization

### Phase 3 Features

- **Network Synchronization**: Multi-user synchronized practice
- **Adaptive Timing**: AI-adjusted tempo based on performance
- **Biometric Integration**: Heart rate synchronized timing
- **Spatial Audio**: 3D positioned metronome clicks

## Critical Success Factors

1. **Jank-tolerant scheduling**: Lookahead window absorbs brief UI stalls
   without dropping or delaying beats beyond the targets in
   [Precision Standards](#precision-standards)
2. **Realistic, measured accuracy**: ≤10ms average / ≤25ms worst-case
   scheduling deviation, verified on real devices — not an unverified
   sub-millisecond claim
3. **No new dependencies**: Built on `audioplayers`, already in `pubspec.yaml`
4. **Resource Efficiency**: Minimal CPU and battery impact
5. **Reliability**: No cumulative drift across extended use, by construction
   (absolute beat-time computation, not incremental)
6. **Exercise Integration**: Seamless timing validation for practice exercises
