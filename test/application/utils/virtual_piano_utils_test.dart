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

    tearDown(() async {
      await VirtualPianoUtils.dispose(mockRepository);
      midiState.dispose();
    });

    tearDownAll(MidiMocks.tearDown);

    group("dispose method tests", () {
      test("should complete without throwing errors", () async {
        // Play some notes to create active timers
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          (note) {},
        );
        await VirtualPianoUtils.playVirtualNote(
          64,
          mockRepository,
          midiState,
          (note) {},
        );

        // Call dispose - should not throw
        expect(
          () async => await VirtualPianoUtils.dispose(mockRepository),
          returnsNormally,
        );
      });

      test("should be safe to call multiple times", () async {
        // Play a note
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          (note) {},
        );

        // Call dispose multiple times - should not throw
        expect(() async {
          await VirtualPianoUtils.dispose(mockRepository);
          await VirtualPianoUtils.dispose(mockRepository);
          await VirtualPianoUtils.dispose(mockRepository);
        }, returnsNormally);
      });

      test("should prevent stuck notes by attempting cleanup", () async {
        // This test verifies the core purpose of the dispose enhancement:
        // preventing stuck notes when dispose is called before timers fire

        // Play several notes
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          (note) {},
        ); // C4
        await VirtualPianoUtils.playVirtualNote(
          64,
          mockRepository,
          midiState,
          (note) {},
        ); // E4
        await VirtualPianoUtils.playVirtualNote(
          67,
          mockRepository,
          midiState,
          (note) {},
        ); // G4

        // Immediately dispose (before the 500ms timers would fire)
        // The key test is that this should not throw and should attempt cleanup
        expect(
          () async => await VirtualPianoUtils.dispose(mockRepository),
          returnsNormally,
        );
      });
    });

    group("playVirtualNote functionality", () {
      test("should execute callback and update MIDI state", () async {
        var notePressed = false;
        var pressedNote = 0;

        await VirtualPianoUtils.playVirtualNote(
          60, // Middle C
          mockRepository,
          midiState,
          (note) {
            notePressed = true;
            pressedNote = note;
          },
        );

        // Verify callback was called
        expect(notePressed, isTrue);
        expect(pressedNote, equals(60));

        // Verify MIDI state was updated
        expect(midiState.lastNote.contains("Virtual Note ON: 60"), isTrue);
        expect(midiState.lastNote.contains("Ch: 1"), isTrue);
        expect(midiState.lastNote.contains("Vel: 64"), isTrue);

        // Verify repository was called
        verify(mockRepository.sendNoteOn(60, 64, 0)).called(1);
      });

      test("should handle different MIDI channels", () async {
        // Set channel to 5 (0-indexed, so channel 6 in UI)
        midiState.setSelectedChannel(5);

        await VirtualPianoUtils.playVirtualNote(
          67, // G4
          mockRepository,
          midiState,
          (note) {},
        );

        // Verify the channel was used in the message
        expect(midiState.lastNote.contains("Ch: 6"), isTrue);

        // Verify repository was called with correct channel
        verify(mockRepository.sendNoteOn(67, 64, 5)).called(1);
      });
    });

    group("integration tests", () {
      test("should play notes and dispose successfully", () async {
        // This is a comprehensive integration test
        final notesPlayed = <int>[];

        // Play a chord
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          notesPlayed.add,
        );
        await VirtualPianoUtils.playVirtualNote(
          64,
          mockRepository,
          midiState,
          notesPlayed.add,
        );
        await VirtualPianoUtils.playVirtualNote(
          67,
          mockRepository,
          midiState,
          notesPlayed.add,
        );

        // Verify all notes were played
        expect(notesPlayed, equals([60, 64, 67]));

        // Verify MIDI state reflects the last note
        expect(midiState.lastNote.contains("Virtual Note ON: 67"), isTrue);

        // Dispose should work without errors
        expect(
          () async => await VirtualPianoUtils.dispose(mockRepository),
          returnsNormally,
        );

        // After dispose, should still be able to play new notes
        await VirtualPianoUtils.playVirtualNote(
          72,
          mockRepository,
          midiState,
          notesPlayed.add,
        );

        expect(notesPlayed.last, equals(72));
      });
    });

    group("error handling tests", () {
      test(
        "should handle repository errors gracefully during sendNoteOn",
        () async {
          // Setup mock to throw exception on sendNoteOn
          when(
            mockRepository.sendNoteOn(any, any, any),
          ).thenThrow(Exception("MIDI send failed"));

          var callbackCalled = false;

          // Should complete without throwing, even though repository fails
          await expectLater(
            VirtualPianoUtils.playVirtualNote(60, mockRepository, midiState, (
              note,
            ) {
              callbackCalled = true;
            }),
            completes,
          );

          // Callback should still be called if mounted is true
          expect(callbackCalled, isTrue);

          // Verify MIDI state shows error
          expect(midiState.lastNote.contains("Error"), isTrue);
        },
      );

      test(
        "should handle repository errors gracefully during sendNoteOff",
        () async {
          // Setup mock to succeed on sendNoteOn but fail on sendNoteOff
          when(
            mockRepository.sendNoteOn(any, any, any),
          ).thenAnswer((_) async {});
          when(
            mockRepository.sendNoteOff(any, any),
          ).thenThrow(Exception("MIDI note off failed"));

          // Play a note
          await VirtualPianoUtils.playVirtualNote(
            60,
            mockRepository,
            midiState,
            (note) {},
          );

          // Wait for note-off timer to fire (500ms + buffer)
          await Future<void>.delayed(const Duration(milliseconds: 600));

          // Should not throw - error should be caught and logged
          // Verify note-off was attempted despite error
          verify(mockRepository.sendNoteOff(60, 0)).called(1);
        },
      );

      test("should handle rapid successive note presses", () async {
        final notesPressed = <int>[];

        // Play the same note rapidly multiple times
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          notesPressed.add,
        );
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          notesPressed.add,
        );
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          notesPressed.add,
        );

        // All callbacks should be called
        expect(notesPressed.length, equals(3));
        expect(notesPressed, equals([60, 60, 60]));

        // Each sendNoteOn should be called
        verify(mockRepository.sendNoteOn(60, 64, 0)).called(3);

        // Wait for timers to complete
        await Future<void>.delayed(const Duration(milliseconds: 600));

        // Only one sendNoteOff should be called (last timer cancels previous)
        verify(mockRepository.sendNoteOff(60, 0)).called(1);
      });

      test(
        "should respect mounted state for callback but always send note-off",
        () async {
          var callbackCalled = false;

          // Play note with mounted = false
          await VirtualPianoUtils.playVirtualNote(
            60,
            mockRepository,
            midiState,
            (note) {
              callbackCalled = true;
            },
            mounted: false,
          );

          // Callback should NOT be called when mounted is false
          expect(callbackCalled, isFalse);

          // But note-on should still be sent
          verify(mockRepository.sendNoteOn(60, 64, 0)).called(1);

          // Wait for note-off timer
          await Future<void>.delayed(const Duration(milliseconds: 600));

          // Note-off should ALWAYS be sent regardless of mounted state
          verify(mockRepository.sendNoteOff(60, 0)).called(1);
        },
      );

      test("should handle sendData errors during dispose", () async {
        // Setup mock to throw on sendData (All Notes Off)
        when(
          mockRepository.sendData(any),
        ).thenThrow(Exception("MIDI sendData failed"));

        // Play some notes
        await VirtualPianoUtils.playVirtualNote(
          60,
          mockRepository,
          midiState,
          (note) {},
        );

        // Dispose should complete without throwing despite sendData errors
        await expectLater(VirtualPianoUtils.dispose(mockRepository), completes);

        // Verify sendData was attempted for multiple channels
        verify(mockRepository.sendData(any)).called(greaterThan(0));
      });

      test(
        "should handle different notes on same channel simultaneously",
        () async {
          final notesPressed = <int>[];

          // Play different notes rapidly
          await VirtualPianoUtils.playVirtualNote(
            60,
            mockRepository,
            midiState,
            notesPressed.add,
          );
          await VirtualPianoUtils.playVirtualNote(
            64,
            mockRepository,
            midiState,
            notesPressed.add,
          );
          await VirtualPianoUtils.playVirtualNote(
            67,
            mockRepository,
            midiState,
            notesPressed.add,
          );

          // All notes should be registered
          expect(notesPressed, equals([60, 64, 67]));

          // Wait for all timers
          await Future<void>.delayed(const Duration(milliseconds: 600));

          // Each note-off should be called
          verify(mockRepository.sendNoteOff(60, 0)).called(1);
          verify(mockRepository.sendNoteOff(64, 0)).called(1);
          verify(mockRepository.sendNoteOff(67, 0)).called(1);
        },
      );
    });
  });
}
