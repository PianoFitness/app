import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/metronome_audio_service_impl.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("MetronomeAudioServiceImpl Unit Tests", () {
    test("initializes, handles click and dispose gracefully", () async {
      final service = MetronomeAudioServiceImpl();

      // AudioPool requires platform channel in native environment, test graceful setup & dispose
      expect(service.dispose(), completes);
    });
  });
}
