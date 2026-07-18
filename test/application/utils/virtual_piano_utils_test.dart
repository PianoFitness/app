import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";
import "../../shared/midi_mocks.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("VirtualPianoUtils Unit Tests", () {
    late MidiState midiState;
    late MockIMidiRepository mockRepository;

    setUpAll(MidiMocks.setUp);

    setUp(() {
      midiState = MidiState();
      mockRepository = MockIMidiRepository();

      // Setup mock repository behavior
      when(mockRepository.sendNoteOn(any, any, any)).thenAnswer((_) async {});
      when(mockRepository.sendNoteOff(any, any)).thenAnswer((_) async {});
      when(mockRepository.sendData(any)).thenAnswer((_) async {});
    });

    tearDown(() {
      midiState.dispose();
    });

    tearDownAll(MidiMocks.tearDown);

    group("noteOn", () {
      test("sends a note-on and updates MIDI state", () async {
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);

        expect(midiState.lastNote.contains("Virtual Note ON: 60"), isTrue);
        expect(midiState.lastNote.contains("Ch: 1"), isTrue);
        expect(midiState.lastNote.contains("Vel: 64"), isTrue);
        verify(mockRepository.sendNoteOn(60, 64, 0)).called(1);
      });

      test("respects the selected MIDI channel", () async {
        midiState.setSelectedChannel(5);

        await VirtualPianoUtils.noteOn(67, mockRepository, midiState);

        expect(midiState.lastNote.contains("Ch: 6"), isTrue);
        verify(mockRepository.sendNoteOn(67, 64, 5)).called(1);
      });

      test("accepts a custom velocity", () async {
        await VirtualPianoUtils.noteOn(
          60,
          mockRepository,
          midiState,
          velocity: 100,
        );

        expect(midiState.lastNote.contains("Vel: 100"), isTrue);
        verify(mockRepository.sendNoteOn(60, 100, 0)).called(1);
      });

      test("handles repository errors gracefully", () async {
        when(
          mockRepository.sendNoteOn(any, any, any),
        ).thenThrow(Exception("MIDI send failed"));

        await expectLater(
          VirtualPianoUtils.noteOn(60, mockRepository, midiState),
          completes,
        );

        expect(midiState.lastNote.contains("Error"), isTrue);
      });

      test("supports rapid successive presses of the same note", () async {
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);

        verify(mockRepository.sendNoteOn(60, 64, 0)).called(3);
      });
    });

    group("noteOff", () {
      test("sends a note-off on the current channel", () async {
        await VirtualPianoUtils.noteOff(60, mockRepository, midiState);
        verify(mockRepository.sendNoteOff(60, 0)).called(1);
      });

      test("respects the selected MIDI channel", () async {
        midiState.setSelectedChannel(5);
        await VirtualPianoUtils.noteOff(67, mockRepository, midiState);
        verify(mockRepository.sendNoteOff(67, 5)).called(1);
      });

      test("handles repository errors gracefully", () async {
        when(
          mockRepository.sendNoteOff(any, any),
        ).thenThrow(Exception("MIDI note off failed"));

        await expectLater(
          VirtualPianoUtils.noteOff(60, mockRepository, midiState),
          completes,
        );
      });
    });

    group("dispose", () {
      test("completes without throwing", () async {
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);
        await expectLater(VirtualPianoUtils.dispose(mockRepository), completes);
      });

      test("is safe to call multiple times", () async {
        await VirtualPianoUtils.dispose(mockRepository);
        await VirtualPianoUtils.dispose(mockRepository);
        await VirtualPianoUtils.dispose(mockRepository);
      });

      test("sends All Notes Off across every MIDI channel", () async {
        await VirtualPianoUtils.dispose(mockRepository);
        verify(mockRepository.sendData(any)).called(16);
      });

      test("handles sendData errors gracefully", () async {
        when(
          mockRepository.sendData(any),
        ).thenThrow(Exception("MIDI sendData failed"));

        await expectLater(VirtualPianoUtils.dispose(mockRepository), completes);
        verify(mockRepository.sendData(any)).called(greaterThan(0));
      });
    });

    group("noteOn/noteOff integration", () {
      test("plays and releases a chord", () async {
        for (final note in [60, 64, 67]) {
          await VirtualPianoUtils.noteOn(note, mockRepository, midiState);
        }
        expect(midiState.lastNote.contains("Virtual Note ON: 67"), isTrue);

        for (final note in [60, 64, 67]) {
          await VirtualPianoUtils.noteOff(note, mockRepository, midiState);
        }

        verify(mockRepository.sendNoteOff(60, 0)).called(1);
        verify(mockRepository.sendNoteOff(64, 0)).called(1);
        verify(mockRepository.sendNoteOff(67, 0)).called(1);
      });

      test("noteOn followed by dispose still completes cleanly", () async {
        await VirtualPianoUtils.noteOn(60, mockRepository, midiState);
        await expectLater(VirtualPianoUtils.dispose(mockRepository), completes);

        // Still usable after dispose (dispose is a one-shot safety sweep,
        // not a teardown of VirtualPianoUtils itself).
        await VirtualPianoUtils.noteOn(72, mockRepository, midiState);
        expect(midiState.lastNote.contains("Virtual Note ON: 72"), isTrue);
      });
    });
  });
}
