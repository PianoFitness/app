import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/models/midi/midi_event.dart";

import "../../shared/test_helpers/mock_repositories.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  late MockIMidiRepository mockRepo;
  late MockMidiRepositoryHelper helper;
  late MidiState midiState;
  late MidiCoordinator coordinator;

  setUp(() {
    mockRepo = MockIMidiRepository();
    helper = MockMidiRepositoryHelper(mockRepo);
    midiState = MidiState();
    coordinator = MidiCoordinator(mockRepo);
  });

  tearDown(() {
    midiState.dispose();
  });

  group("MidiCoordinator.subscribe", () {
    test("registers a handler with the repository", () {
      coordinator.subscribe(midiState, (_) {});
      verify(mockRepo.registerDataHandler(any)).called(1);
    });

    test("dispatches parsed note-on event to callback", () {
      MidiEvent? received;
      coordinator.subscribe(midiState, (event) => received = event);

      // MIDI note-on: status=0x90, note=60, velocity=64
      helper.simulateMidiData(Uint8List.fromList([0x90, 60, 64]));

      expect(received, isNotNull);
      expect(received!.type, MidiEventType.noteOn);
      expect(received!.data1, 60);
    });

    test("dispatches parsed note-off event to callback", () {
      MidiEvent? received;
      coordinator.subscribe(midiState, (event) => received = event);

      helper.simulateMidiData(Uint8List.fromList([0x80, 60, 0]));

      expect(received, isNotNull);
      expect(received!.type, MidiEventType.noteOff);
    });

    test("multiple subscribers each receive events independently", () {
      final receivedA = <MidiEvent>[];
      final receivedB = <MidiEvent>[];
      coordinator.subscribe(midiState, receivedA.add);
      coordinator.subscribe(midiState, receivedB.add);

      helper.simulateMidiData(Uint8List.fromList([0x90, 60, 64]));

      expect(receivedA, hasLength(1));
      expect(receivedB, hasLength(1));
    });
  });

  group("MidiSubscription.cancel", () {
    test("unregisters the handler from the repository", () {
      final sub = coordinator.subscribe(midiState, (_) {});
      sub.cancel();
      verify(mockRepo.unregisterDataHandler(any)).called(1);
    });

    test("stops delivering events after cancellation", () {
      final received = <MidiEvent>[];
      final sub = coordinator.subscribe(midiState, received.add);
      sub.cancel();

      helper.simulateMidiData(Uint8List.fromList([0x90, 60, 64]));

      expect(received, isEmpty);
    });

    test("is idempotent — cancelling twice unregisters only once", () {
      final sub = coordinator.subscribe(midiState, (_) {});
      sub.cancel();
      sub.cancel();
      verify(mockRepo.unregisterDataHandler(any)).called(1);
    });
  });
}
