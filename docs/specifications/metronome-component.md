# Metronome Component Specification

## Overview

The Metronome component is a precision timing tool essential for piano practice. It provides audible and visual beat references with high temporal accuracy, independent of Flutter's rendering cycle. The metronome must maintain consistent timing even under system load, making it suitable for professional music practice and exercise timing validation.

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

- **Timing accuracy**: ±1 ms maximum deviation from the target interval.
- **Jitter**: Less than 0.5 ms between beats.
- **Long-term stability**: No measurable drift over 60+ minutes of continuous use.
- **Load independence**: Timing must remain consistent regardless of UI complexity or system load.
- **Audio latency**: Click-to-sound delay under 20 ms.
- **Background operation**: Timing must be maintained when the app is backgrounded.

## Critical Timing Requirements

### Precision Standards

- **Timing Accuracy**: ±1ms deviation maximum from target interval
- **Timing Consistency**: &lt;0.5ms jitter between beats
- **Long-term Stability**: No drift over extended periods (60+ minutes)
- **Load Independence**: Consistent timing regardless of UI complexity
- **Background Operation**: Maintain timing when app is backgrounded

### Musical Timing Context

- **Human Perception**: Musicians notice timing variations >3ms
- **Professional Standards**: Recording studios require &lt;1ms accuracy
- **Practice Effectiveness**: Inconsistent timing disrupts muscle memory
- **Exercise Validation**: Timing analysis requires precise reference
- **Ensemble Coordination**: Group practice depends on stable timing

## Architecture Design

### Isolation Strategy

The metronome must run independently from Flutter's render loop to avoid timing corruption from UI updates, animations, or garbage collection.

```dart
class PrecisionMetronome {
  late ReliableIntervalTimer _timer;
  late Isolate _metronomeIsolate;
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  
  // Configuration
  int _bpm = 120;
  TimeSignature _timeSignature = TimeSignature.fourFour;
  MetronomeSound _sound = MetronomeSound.click;
  bool _isPlaying = false;
  
  // Precision timing
  Duration get _interval => Duration(microseconds: (60000000 / _bpm).round());
  
  Future<void> initialize() async {
    _receivePort = ReceivePort();
    _metronomeIsolate = await Isolate.spawn(
      _metronomeIsolateEntry,
      _receivePort.sendPort,
    );
    
    _sendPort = await _receivePort.first;
    _setupTimer();
  }
  
  void _setupTimer() {
    _timer = ReliableIntervalTimer(
      interval: _interval,
      callback: _onBeat,
    );
  }
}
```

### Isolate Implementation

```dart
// Isolate entry point - runs on separate thread
static void _metronomeIsolateEntry(SendPort mainSendPort) {
  final isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);
  
  ReliableIntervalTimer? timer;
  
  isolateReceivePort.listen((message) {
    switch (message['command']) {
      case 'start':
        timer = ReliableIntervalTimer(
          interval: Duration(microseconds: message['intervalMicros']),
          callback: (elapsed) {
            mainSendPort.send({
              'type': 'beat',
              'elapsed': elapsed,
              'beatNumber': message['beatNumber'],
            });
          },
        );
        break;
      case 'stop':
        timer?.cancel();
        timer = null;
        break;
      case 'updateTempo':
        timer?.cancel();
        timer = ReliableIntervalTimer(
          interval: Duration(microseconds: message['intervalMicros']),
          callback: (elapsed) {
            mainSendPort.send({
              'type': 'beat',
              'elapsed': elapsed,
              'beatNumber': message['beatNumber'],
            });
          },
        );
        break;
    }
  });
}
```

## Timing Implementation

### ReliableIntervalTimer Integration

```dart
class MetronomeTimer {
  ReliableIntervalTimer? _timer;
  final Function(int elapsedMilliseconds) onBeat;
  Duration _interval;
  
  MetronomeTimer({
    required this.onBeat,
    required Duration interval,
  }) : _interval = interval;
  
  void start() {
    _timer = ReliableIntervalTimer(
      interval: _interval,
      callback: onBeat,
    );
  }
  
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
  
  void updateInterval(Duration newInterval) {
    final wasPlaying = _timer != null;
    stop();
    _interval = newInterval;
    if (wasPlaying) start();
  }
}
```

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

### Sound Generation

```dart
class MetronomeAudioEngine {
  late AudioPlayer _audioPlayer;
  final Map<MetronomeSound, String> _soundPaths = {
    MetronomeSound.click: 'sounds/metronome_click.wav',
    MetronomeSound.bell: 'sounds/metronome_bell.wav',
    MetronomeSound.woodBlock: 'sounds/metronome_wood.wav',
    MetronomeSound.digitalBeep: 'sounds/metronome_beep.wav',
  };
  
  Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    await _preloadSounds();
  }
  
  Future<void> _preloadSounds() async {
    // Preload all sounds to minimize latency
    for (final soundPath in _soundPaths.values) {
      await _audioPlayer.setAsset(soundPath);
    }
  }
  
  Future<void> playBeat(MetronomeSound sound, BeatEmphasis emphasis) async {
    final soundPath = _soundPaths[sound]!;
    await _audioPlayer.setAsset(soundPath);
    await _audioPlayer.setVolume(emphasis.intensity);
    await _audioPlayer.play();
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

### Low-Latency Audio Requirements

- **Audio Buffer Size**: Minimize to reduce latency (&lt;128 samples)
- **Sample Rate**: Use 44.1kHz or 48kHz for quality
- **Preloading**: Cache all sound files in memory
- **Audio Thread**: Separate thread for audio processing
- **Platform Audio**: Use native audio APIs for best performance

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
      isAccurate: maxDeviation < 3000, // 3ms tolerance
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

## Exercise Integration

### Timing Reference for Practice

```dart
class ExerciseMetronome extends PrecisionMetronome {
  final Function(BeatInfo) onExerciseBeat;
  final Function(TimingAnalysis) onTimingAnalysis;
  
  ExerciseMetronome({
    required this.onExerciseBeat,
    required this.onTimingAnalysis,
  });
  
  void startExercise(Exercise exercise) {
    setBpm(exercise.targetTempo);
    setTimeSignature(exercise.timeSignature);
    start();
    
    // Provide timing reference to exercise system
    beatStream.listen((beat) {
      onExerciseBeat(beat);
      
      // Analyze timing for exercise validation
      if (beat.beatNumber == 1) {
        final analysis = _timingValidator.analyze(_interval);
        onTimingAnalysis(analysis);
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

### iOS Implementation

- **Core Audio**: Use Audio Units for lowest latency
- **CADisplayLink**: Precise timing synchronization
- **Background Audio**: Maintain timing when backgrounded
- **Audio Session**: Configure for low-latency playback

### Android Implementation

- **AAudio/OpenSL ES**: Low-latency audio APIs
- **Choreographer**: Frame timing synchronization
- **AudioTrack**: Direct audio buffer management
- **Foreground Service**: Maintain timing in background

### Flutter/Dart Considerations

- **Isolate Overhead**: Account for message passing latency
- **Garbage Collection**: Minimize allocations in timing-critical code  
- **Platform Channels**: Use for native audio integration
- **Timer Precision**: Dart Timer is insufficient for precision timing

## Testing and Validation

### Precision Testing

```dart
class MetronomeTimingTest {
  static Future<void> testTimingAccuracy() async {
    final metronome = PrecisionMetronome();
    final validator = TimingValidator();
    final testDuration = Duration(minutes: 5);
    
    metronome.setBpm(120);
    metronome.beatStream.listen((beat) {
      validator.recordBeat(DateTime.now().duration);
    });
    
    metronome.start();
    await Future.delayed(testDuration);
    metronome.stop();
    
    final analysis = validator.analyze(Duration(milliseconds: 500)); // 120 BPM
    expect(analysis.isAccurate, true);
    expect(analysis.maxDeviation.inMilliseconds, lessThan(3));
  }
}
```

### Performance Benchmarks

- **Timing Accuracy**: &lt;1ms deviation under normal load
- **Timing Consistency**: &lt;0.5ms jitter
- **CPU Usage**: &lt;2% on modern devices
- **Memory Usage**: &lt;10MB for metronome subsystem
- **Battery Impact**: Minimal when using efficient audio APIs

## Dependencies

### Required Packages

```yaml
dependencies:
  # Precise interval timing
  reliable_interval_timer: ^1.0.0
  
  # Audio playback
  just_audio: ^0.9.34
  
  # Platform-specific audio
  flutter_native_audio: ^1.0.0
  
  # Background processing
  workmanager: ^0.5.1
```

### Platform-Specific Dependencies

- **iOS**: Core Audio framework integration
- **Android**: AAudio/OpenSL ES integration
- **Web**: Web Audio API (with limitations)
- **Desktop**: Platform-specific audio libraries

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

1. **Timing Independence**: Must run independently of UI thread
2. **Sub-millisecond Precision**: Professional-grade timing accuracy
3. **Platform Integration**: Native audio API utilization
4. **Resource Efficiency**: Minimal CPU and battery impact
5. **Reliability**: Consistent performance across extended use
6. **Exercise Integration**: Seamless timing validation for practice exercises
