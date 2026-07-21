import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/audio_service_impl.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("AudioServiceImpl Unit Tests", () {
    test("createPlayer creates an AudioPlayerHandle instance", () {
      final service = AudioServiceImpl();
      final player = service.createPlayer();

      expect(player, isNotNull);
      expect(player, isA<AudioPlayerHandle>());
    });
  });
}
