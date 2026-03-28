import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_data_handler.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";

void main() {
  group("MidiDataHandler", () {
    late MidiState midiState;

    setUp(() {
      midiState = MidiState();
    });

    tearDown(() {
      midiState.dispose();
    });

    test("dispatches note-on event to callback", () {
      MidiEvent? received;
      // MIDI note-on: status=0x90 (ch1), note=60, velocity=64
      final data = Uint8List.fromList([0x90, 60, 64]);

      MidiDataHandler.dispatch(data, midiState, (event) {
        received = event;
      });

      expect(received, isNotNull);
      expect(received!.type, equals(MidiEventType.noteOn));
      expect(received!.data1, equals(60));
      expect(received!.data2, equals(64));
    });

    test("dispatches note-off event to callback", () {
      MidiEvent? received;
      // MIDI note-off: status=0x80 (ch1), note=60, velocity=0
      final data = Uint8List.fromList([0x80, 60, 0]);

      MidiDataHandler.dispatch(data, midiState, (event) {
        received = event;
      });

      expect(received, isNotNull);
      expect(received!.type, equals(MidiEventType.noteOff));
    });

    test("silently ignores empty data without calling callback", () {
      var called = false;
      MidiDataHandler.dispatch(Uint8List(0), midiState, (_) => called = true);
      expect(called, isFalse);
    });

    test("silently ignores timing clock messages without calling callback", () {
      var called = false;
      // 0xF8 = MIDI timing clock
      final data = Uint8List.fromList([0xF8]);
      MidiDataHandler.dispatch(data, midiState, (_) => called = true);
      expect(called, isFalse);
    });

    test("catches callback errors and updates midiState", () {
      // MIDI note-on to trigger the callback
      final data = Uint8List.fromList([0x90, 60, 64]);

      MidiDataHandler.dispatch(data, midiState, (_) {
        throw StateError("simulated handler error");
      });

      expect(midiState.lastNote, equals("Error processing MIDI event"));
    });

    test("does not throw when callback throws", () {
      final data = Uint8List.fromList([0x90, 60, 64]);

      expect(
        () => MidiDataHandler.dispatch(data, midiState, (_) {
          throw Exception("boom");
        }),
        returnsNormally,
      );
    });
  });
}
