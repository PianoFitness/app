import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/domain/services/metronome/tempo_calculator.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page_view_model.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MetronomePageViewModel", () {
    late MockIMetronomeAudioService mockAudioService;
    late MetronomePageViewModel viewModel;

    setUp(() {
      mockAudioService = MockIMetronomeAudioService();
      when(mockAudioService.initialize()).thenAnswer((_) async {});
      when(
        mockAudioService.playClick(volume: anyNamed("volume")),
      ).thenAnswer((_) async {});
      when(mockAudioService.dispose()).thenAnswer((_) async {});

      viewModel = MetronomePageViewModel(audioService: mockAudioService);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test("initializes with sensible defaults", () {
      expect(viewModel.bpm, equals(120));
      expect(viewModel.timeSignature, equals(TimeSignature.fourFour));
      expect(viewModel.isPlaying, isFalse);
      expect(viewModel.isMuted, isFalse);
      expect(viewModel.currentBeat, isNull);
      expect(viewModel.minBpm, equals(TempoCalculator.minBpm));
      expect(viewModel.maxBpm, equals(TempoCalculator.maxBpm));
    });

    test("pre-warms the audio service on creation", () {
      verify(mockAudioService.initialize()).called(1);
    });

    test("setBpm updates the tempo and notifies listeners", () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setBpm(90);

      expect(viewModel.bpm, equals(90));
      expect(notified, isTrue);
    });

    test("setBpm clamps below the minimum", () {
      viewModel.setBpm(1);
      expect(viewModel.bpm, equals(TempoCalculator.minBpm));
    });

    test("setBpm clamps above the maximum", () {
      viewModel.setBpm(999);
      expect(viewModel.bpm, equals(TempoCalculator.maxBpm));
    });

    test("setBpm is a no-op for an unchanged value", () {
      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.setBpm(viewModel.bpm);

      expect(notifyCount, equals(0));
    });

    test("setTimeSignature updates the signature and notifies listeners", () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setTimeSignature(TimeSignature.threeFour);

      expect(viewModel.timeSignature, equals(TimeSignature.threeFour));
      expect(notified, isTrue);
    });

    test("availableTimeSignatures exposes the common presets", () {
      expect(viewModel.availableTimeSignatures, equals(TimeSignature.common));
    });

    test("toggleMuted flips isMuted", () {
      expect(viewModel.isMuted, isFalse);
      viewModel.toggleMuted();
      expect(viewModel.isMuted, isTrue);
      viewModel.toggleMuted();
      expect(viewModel.isMuted, isFalse);
    });

    test("start() sets isPlaying and is idempotent while already playing", () {
      viewModel.start();
      expect(viewModel.isPlaying, isTrue);

      // Calling start() again while playing must not throw or restart.
      viewModel.start();
      expect(viewModel.isPlaying, isTrue);
    });

    test("stop() clears isPlaying and is safe when not playing", () {
      viewModel.stop(); // not playing yet - should be a no-op, not throw
      expect(viewModel.isPlaying, isFalse);

      viewModel.start();
      viewModel.stop();
      expect(viewModel.isPlaying, isFalse);
    });

    test("toggle() starts when stopped and stops when playing", () {
      expect(viewModel.isPlaying, isFalse);
      viewModel.toggle();
      expect(viewModel.isPlaying, isTrue);
      viewModel.toggle();
      expect(viewModel.isPlaying, isFalse);
    });

    test("dispose() releases the audio service", () {
      // Uses its own mock/instance so tearDown's dispose() call on the
      // shared viewModel doesn't double-dispose this one.
      final scopedMock = MockIMetronomeAudioService();
      when(scopedMock.initialize()).thenAnswer((_) async {});
      when(scopedMock.dispose()).thenAnswer((_) async {});
      final scopedViewModel = MetronomePageViewModel(audioService: scopedMock);

      scopedViewModel.dispose();

      verify(scopedMock.dispose()).called(1);
    });
  });
}
