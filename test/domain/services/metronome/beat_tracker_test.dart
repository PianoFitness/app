import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/metronome/beat_emphasis.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/domain/services/metronome/beat_tracker.dart";

void main() {
  group("BeatTracker", () {
    test("4/4 measure produces strong, weak, medium, weak", () {
      final beats = [
        for (var i = 0; i < 4; i++)
          BeatTracker.beatAt(i, TimeSignature.fourFour),
      ];

      expect(beats.map((b) => b.emphasis), [
        BeatEmphasis.strong,
        BeatEmphasis.weak,
        BeatEmphasis.medium,
        BeatEmphasis.weak,
      ]);
      expect(beats.map((b) => b.beatNumber), [1, 2, 3, 4]);
      expect(beats.every((b) => b.measureNumber == 1), isTrue);
      expect(beats.first.isDownbeat, isTrue);
      expect(beats.skip(1).every((b) => !b.isDownbeat), isTrue);
    });

    test("beat index wraps into a new measure", () {
      // Beat index 4 is the first beat of the second measure.
      final beat = BeatTracker.beatAt(4, TimeSignature.fourFour);

      expect(beat.beatNumber, equals(1));
      expect(beat.measureNumber, equals(2));
      expect(beat.isDownbeat, isTrue);
    });

    test("querying out of order gives consistent, independent results", () {
      final beatFive = BeatTracker.beatAt(5, TimeSignature.threeFour);
      final beatTwo = BeatTracker.beatAt(2, TimeSignature.threeFour);

      expect(beatFive.beatNumber, equals(3));
      expect(beatFive.measureNumber, equals(2));
      expect(beatTwo.beatNumber, equals(3));
      expect(beatTwo.measureNumber, equals(1));
    });

    test(
      "the same beat index is reinterpreted under a different signature",
      () {
        final beat = BeatTracker.beatAt(2, TimeSignature.threeFour);

        expect(beat.beatNumber, equals(3));
        expect(beat.emphasis, equals(BeatEmphasis.weak));
      },
    );

    test("6/8 has a secondary accent on the second group of three", () {
      final beats = [
        for (var i = 0; i < 6; i++)
          BeatTracker.beatAt(i, TimeSignature.sixEight),
      ];

      expect(beats.map((b) => b.emphasis), [
        BeatEmphasis.strong,
        BeatEmphasis.weak,
        BeatEmphasis.weak,
        BeatEmphasis.medium,
        BeatEmphasis.weak,
        BeatEmphasis.weak,
      ]);
    });
  });
}
