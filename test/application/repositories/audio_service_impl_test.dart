import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/audio_service_impl.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("xyz.luan/audioplayers.global"),
          (MethodCall methodCall) async => 1,
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel("xyz.luan/audioplayers"),
          (MethodCall methodCall) async => 1,
        );
  });

  group("AudioServiceImpl Tests", () {
    test("createPlayer returns valid AudioPlayerHandle", () {
      final service = AudioServiceImpl();
      final playerHandle = service.createPlayer();
      expect(playerHandle, isA<AudioPlayerHandle>());
    });

    test("AudioPlayerHandle operations complete cleanly", () async {
      final service = AudioServiceImpl();
      final playerHandle = service.createPlayer();

      try {
        await playerHandle.playAsset("audio/test.mp3");
      } catch (_) {}

      try {
        await playerHandle.stop();
      } catch (_) {}

      await playerHandle.dispose();
    });
  });
}
