import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/metronome/beat_emphasis.dart";
import "package:piano_fitness/domain/models/metronome/time_signature.dart";
import "package:piano_fitness/domain/services/metronome/beat_tracker.dart";

void main() {
  group("BeatTracker", () {
    test("4/4 measure produces strong, weak, medium, weak", () {
      final tracker = BeatTracker(TimeSignature.fourFour);

      final beats = [for (var i = 0; i < 4; i++) tracker.beatAt(i)];

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
      final tracker = BeatTracker(TimeSignature.fourFour);

      final beat = tracker.beatAt(4); // first beat of the second measure

      expect(beat.beatNumber, equals(1));
      expect(beat.measureNumber, equals(2));
      expect(beat.isDownbeat, isTrue);
    });

    test(
      "beatAt is stateless - querying out of order gives consistent results",
      () {
        final tracker = BeatTracker(TimeSignature.threeFour);

        final beatFive = tracker.beatAt(5);
        final beatTwo = tracker.beatAt(2);

        expect(beatFive.beatNumber, equals(3));
        expect(beatFive.measureNumber, equals(2));
        expect(beatTwo.beatNumber, equals(3));
        expect(beatTwo.measureNumber, equals(1));
      },
    );

    test(
      "setTimeSignature changes the pattern used for subsequent queries",
      () {
        final tracker = BeatTracker(TimeSignature.fourFour);

        tracker.setTimeSignature(TimeSignature.threeFour);
        final beat = tracker.beatAt(2);

        expect(beat.beatNumber, equals(3));
        expect(beat.emphasis, equals(BeatEmphasis.weak));
      },
    );

    test("6/8 has a secondary accent on the second group of three", () {
      final tracker = BeatTracker(TimeSignature.sixEight);

      final beats = [for (var i = 0; i < 6; i++) tracker.beatAt(i)];

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
