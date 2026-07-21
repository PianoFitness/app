import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/domain/services/metronome/tempo_calculator.dart";

import "../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MetronomeState", () {
    late MockIMetronomeAudioService mockAudioService;
    late MetronomeState state;

    setUp(() {
      mockAudioService = MockIMetronomeAudioService();
      when(mockAudioService.initialize()).thenAnswer((_) async {});
      when(
        mockAudioService.playClick(volume: anyNamed("volume")),
      ).thenAnswer((_) async {});
      when(mockAudioService.dispose()).thenAnswer((_) async {});

      state = MetronomeState(audioService: mockAudioService);
    });

    tearDown(() {
      state.dispose();
    });

    test("initializes with sensible defaults", () {
      expect(state.bpm, equals(120));
      expect(state.timeSignature, equals(TimeSignature.fourFour));
      expect(state.isPlaying, isFalse);
      expect(state.isMuted, isFalse);
      expect(state.currentBeat, isNull);
      expect(state.minBpm, equals(TempoCalculator.minBpm));
      expect(state.maxBpm, equals(TempoCalculator.maxBpm));
    });

    test("pre-warms the audio service on creation", () {
      verify(mockAudioService.initialize()).called(1);
    });

    test("setBpm updates the tempo and notifies listeners", () {
      var notified = false;
      state.addListener(() => notified = true);

      state.setBpm(90);

      expect(state.bpm, equals(90));
      expect(notified, isTrue);
    });

    test("setBpm clamps below the minimum", () {
      state.setBpm(1);
      expect(state.bpm, equals(TempoCalculator.minBpm));
    });

    test("setBpm clamps above the maximum", () {
      state.setBpm(999);
      expect(state.bpm, equals(TempoCalculator.maxBpm));
    });

    test("setBpm is a no-op for an unchanged value", () {
      var notifyCount = 0;
      state.addListener(() => notifyCount++);

      state.setBpm(state.bpm);

      expect(notifyCount, equals(0));
    });

    test("setTimeSignature updates the signature and notifies listeners", () {
      var notified = false;
      state.addListener(() => notified = true);

      state.setTimeSignature(TimeSignature.threeFour);

      expect(state.timeSignature, equals(TimeSignature.threeFour));
      expect(notified, isTrue);
    });

    test("availableTimeSignatures exposes the common presets", () {
      expect(state.availableTimeSignatures, equals(TimeSignature.common));
    });

    test("toggleMuted flips isMuted", () {
      expect(state.isMuted, isFalse);
      state.toggleMuted();
      expect(state.isMuted, isTrue);
      state.toggleMuted();
      expect(state.isMuted, isFalse);
    });

    test("start() sets isPlaying and is idempotent while already playing", () {
      state.start();
      expect(state.isPlaying, isTrue);

      // Calling start() again while playing must not throw or restart.
      state.start();
      expect(state.isPlaying, isTrue);
    });

    test("stop() clears isPlaying and is safe when not playing", () {
      state.stop(); // not playing yet - should be a no-op, not throw
      expect(state.isPlaying, isFalse);

      state.start();
      state.stop();
      expect(state.isPlaying, isFalse);
    });

    test("toggle() starts when stopped and stops when playing", () {
      expect(state.isPlaying, isFalse);
      state.toggle();
      expect(state.isPlaying, isTrue);
      state.toggle();
      expect(state.isPlaying, isFalse);
    });

    test("dispose() releases the audio service", () {
      // Uses its own mock/instance so tearDown's dispose() call on the
      // shared state doesn't double-dispose this one.
      final scopedMock = MockIMetronomeAudioService();
      when(scopedMock.initialize()).thenAnswer((_) async {});
      when(scopedMock.dispose()).thenAnswer((_) async {});
      final scopedState = MetronomeState(audioService: scopedMock);

      scopedState.dispose();

      verify(scopedMock.dispose()).called(1);
    });
  });
}
