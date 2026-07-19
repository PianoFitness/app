import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";

PracticeNote _note(
  int midiNote, {
  PracticeHand hand = PracticeHand.right,
  int? fingerNumber,
}) {
  return PracticeNote(
    pitch: MidiNote(midiNote),
    hand: hand,
    fingerNumber: fingerNumber,
  );
}

void main() {
  group("PracticeNote", () {
    test("round-trips complete guidance through JSON", () {
      final note = PracticeNote(
        pitch: MidiNote(61),
        hand: PracticeHand.left,
        fingerNumber: 2,
        annotations: {"spelling": "D-flat", "degree": 2},
      );

      expect(PracticeNote.fromJson(note.toJson()), note);
      expect(note.toJson(), {
        "midiNote": 61,
        "hand": "left",
        "fingerNumber": 2,
        "annotations": {"spelling": "D-flat", "degree": 2},
      });
    });

    test("validates optional finger number", () {
      expect(() => _note(60, fingerNumber: 0), throwsArgumentError);
      expect(() => _note(60, fingerNumber: 6), throwsArgumentError);
      expect(_note(60).fingerNumber, isNull);
    });

    test("makes annotations read-only", () {
      final note = PracticeNote(
        pitch: MidiNote(60),
        hand: PracticeHand.right,
        annotations: {"degree": 1},
      );

      expect(() => note.annotations!["degree"] = 2, throwsUnsupportedError);
    });
  });

  group("HandGroupedMidiNotes", () {
    test("assigns one hand to a single-hand voicing", () {
      final notes = [MidiNote(60), MidiNote(64), MidiNote(67)].toPracticeNotes(
        handSelection: HandSelection.right,
        fingerNumbers: [1, 3, 5],
      );

      expect(notes.map((note) => note.hand), everyElement(PracticeHand.right));
      expect(notes.map((note) => note.fingerNumber), [1, 3, 5]);
    });

    test("splits grouped both-hand voicings at the midpoint", () {
      final notes =
          [
            MidiNote(48),
            MidiNote(52),
            MidiNote(55),
            MidiNote(60),
            MidiNote(64),
            MidiNote(67),
          ].toPracticeNotes(
            handSelection: HandSelection.both,
            fingerNumbers: [5, 3, 1, 1, 3, 5],
          );

      expect(notes.map((note) => note.hand), [
        PracticeHand.left,
        PracticeHand.left,
        PracticeHand.left,
        PracticeHand.right,
        PracticeHand.right,
        PracticeHand.right,
      ]);
    });

    test("rejects mismatched fingers and uneven both-hand groups", () {
      expect(
        () => [MidiNote(60)].toPracticeNotes(
          handSelection: HandSelection.right,
          fingerNumbers: [1, 2],
        ),
        throwsArgumentError,
      );
      expect(
        () => [
          MidiNote(48),
          MidiNote(52),
          MidiNote(60),
        ].toPracticeNotes(handSelection: HandSelection.both),
        throwsArgumentError,
      );
    });
  });

  group("PracticeStep", () {
    test("derives deterministic and set-shaped MIDI views", () {
      final step = PracticeStep(
        notes: [
          _note(60, fingerNumber: 1),
          _note(64, fingerNumber: 3),
          _note(67, fingerNumber: 5),
        ],
        metadata: {"displayName": "C major"},
      );

      expect(step.midiNotes, [60, 64, 67]);
      expect(step.expectedMidiNotes, {60, 64, 67});
    });

    test("rejects empty steps and duplicate MIDI pitches", () {
      expect(() => PracticeStep(notes: []), throwsArgumentError);
      expect(
        () => PracticeStep(
          notes: [
            _note(60, hand: PracticeHand.left),
            _note(60),
          ],
        ),
        throwsArgumentError,
      );
    });

    test("rejects one hand assigning a finger twice", () {
      expect(
        () => PracticeStep(
          notes: [_note(60, fingerNumber: 1), _note(64, fingerNumber: 1)],
        ),
        throwsArgumentError,
      );

      expect(
        PracticeStep(
          notes: [
            _note(48, hand: PracticeHand.left, fingerNumber: 1),
            _note(60, fingerNumber: 1),
          ],
        ),
        isA<PracticeStep>(),
      );
    });

    test("round-trips without StepType or note-level metadata arrays", () {
      final step = PracticeStep(
        notes: [
          _note(48, hand: PracticeHand.left, fingerNumber: 5),
          _note(60, fingerNumber: 1),
        ],
        metadata: {"displayName": "Hands together"},
      );
      final json = step.toJson();

      expect(PracticeStep.fromJson(json), step);
      expect(json, isNot(contains("type")));
      expect(json["metadata"], isNot(contains("hand")));
      expect(json["metadata"], isNot(contains("fingers")));
    });

    test("makes note and metadata collections read-only", () {
      final step = PracticeStep(
        notes: [_note(60)],
        metadata: {"displayName": "C"},
      );

      expect(() => step.notes.add(_note(62)), throwsUnsupportedError);
      expect(() => step.metadata!["displayName"] = "D", throwsUnsupportedError);
    });
  });

  group("PracticeExercise", () {
    test("collects unique pitches and round-trips through JSON", () {
      final exercise = PracticeExercise(
        steps: [
          PracticeStep(notes: [_note(60)]),
          PracticeStep(notes: [_note(60), _note(64)]),
        ],
        metadata: {"exerciseType": "test"},
      );

      expect(exercise.getAllNotes().map((note) => note.value), {60, 64});
      expect(PracticeExercise.fromJson(exercise.toJson()), exercise);
    });
  });
}
