import "dart:async";

import "package:flutter/foundation.dart";
import "package:piano_fitness/domain/models/metronome/beat_info.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/domain/services/metronome/beat_tracker.dart";
import "package:piano_fitness/domain/services/metronome/metronome_scheduler.dart";
import "package:piano_fitness/domain/services/metronome/tempo_calculator.dart";

/// App-wide metronome state, shared across every page (see [MidiState] for
/// the same pattern applied to MIDI).
///
/// A student may want a tempo reference in Free Play, Reference, or a
/// Practice session alike, so this is provided once at the app root rather
/// than scoped to a single page - starting it in one place keeps it running
/// as they navigate elsewhere. Facade that wires [MetronomeScheduler] (when
/// a beat fires), [BeatTracker] (which beat / what emphasis), and
/// [IMetronomeAudioService] (the click sound) into the state and controls
/// the UI binds to. See
/// docs/specifications/metronome-component.md#putting-it-together.
class MetronomeState extends ChangeNotifier {
  /// Creates the state and starts pre-warming the click sound so the first
  /// beat isn't slower than the rest.
  MetronomeState({required IMetronomeAudioService audioService})
    : _audioService = audioService {
    unawaited(_audioService.initialize());
  }

  static const int _defaultBpm = 120;

  final IMetronomeAudioService _audioService;
  final BeatTracker _beatTracker = BeatTracker(TimeSignature.fourFour);
  late final MetronomeScheduler _scheduler = MetronomeScheduler(
    onBeat: _onSchedulerBeat,
  );

  int _bpm = _defaultBpm;
  TimeSignature _timeSignature = TimeSignature.fourFour;
  bool _isPlaying = false;
  bool _isMuted = false;
  BeatInfo? _currentBeat;

  /// Current tempo in beats per minute.
  int get bpm => _bpm;

  /// Active time signature.
  TimeSignature get timeSignature => _timeSignature;

  /// Whether the metronome is currently running.
  bool get isPlaying => _isPlaying;

  /// Whether audio playback is muted (visual pulse only).
  bool get isMuted => _isMuted;

  /// The most recently fired beat, if any.
  BeatInfo? get currentBeat => _currentBeat;

  /// Slowest supported tempo, for slider bounds.
  int get minBpm => TempoCalculator.minBpm;

  /// Fastest supported tempo, for slider bounds.
  int get maxBpm => TempoCalculator.maxBpm;

  /// Time signature presets available for selection.
  List<TimeSignature> get availableTimeSignatures => TimeSignature.common;

  /// Sets the tempo, clamped to [minBpm]-[maxBpm]. Takes effect immediately
  /// if already playing, without resetting phase (see
  /// [MetronomeScheduler.updateBpm]).
  void setBpm(int bpm) {
    final clamped = TempoCalculator.clampBpm(bpm);
    if (clamped == _bpm) return;
    _bpm = clamped;
    if (_isPlaying) {
      _scheduler.updateBpm(_bpm);
    }
    notifyListeners();
  }

  /// Changes the time signature. Takes effect from the next beat.
  void setTimeSignature(TimeSignature timeSignature) {
    if (timeSignature == _timeSignature) return;
    _timeSignature = timeSignature;
    _beatTracker.setTimeSignature(timeSignature);
    notifyListeners();
  }

  /// Toggles mute (visual pulse only, no click sound).
  void toggleMuted() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  /// Starts the metronome from beat 1.
  void start() {
    if (_isPlaying) return;
    _isPlaying = true;
    _currentBeat = null;
    _scheduler.start(bpm: _bpm);
    notifyListeners();
  }

  /// Stops the metronome.
  void stop() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _scheduler.stop();
    notifyListeners();
  }

  /// Starts if stopped, stops if running.
  void toggle() {
    if (_isPlaying) {
      stop();
    } else {
      start();
    }
  }

  void _onSchedulerBeat(int beatIndex) {
    // Timing-critical: trigger playback before any other work.
    final beat = _beatTracker.beatAt(beatIndex);
    if (!_isMuted) {
      unawaited(_audioService.playClick(volume: beat.emphasis.intensity));
    }
    _currentBeat = beat;
    notifyListeners();
  }

  @override
  void dispose() {
    _scheduler.stop();
    unawaited(_audioService.dispose());
    super.dispose();
  }
}
