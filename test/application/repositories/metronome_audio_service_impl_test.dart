import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/metronome_audio_service_impl.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("MetronomeAudioServiceImpl Tests", () {
    test("initializes with default parameter values", () {
      final service = MetronomeAudioServiceImpl();
      expect(
        service.assetPath,
        equals("audio/218851__kellyconidi__highbell.mp3"),
      );
      expect(service.minPlayers, equals(2));
      expect(service.maxPlayers, equals(4));
    });

    test("accepts custom parameters in constructor", () {
      final service = MetronomeAudioServiceImpl(
        assetPath: "audio/custom_click.mp3",
        minPlayers: 1,
        maxPlayers: 5,
      );
      expect(service.assetPath, equals("audio/custom_click.mp3"));
      expect(service.minPlayers, equals(1));
      expect(service.maxPlayers, equals(5));
    });

    test("dispose cancels and resets state cleanly", () async {
      final service = MetronomeAudioServiceImpl();
      await service.dispose();
      // Second dispose call should complete without error
      await service.dispose();
    });

    test(
      "playClick gracefully returns if disposed before pool ready",
      () async {
        final service = MetronomeAudioServiceImpl();
        await service.dispose();
        // Should return without attempting to play or throwing
        await service.playClick(volume: 0.8);
      },
    );
  });
}
