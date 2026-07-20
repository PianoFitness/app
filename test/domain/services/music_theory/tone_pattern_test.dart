import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/services/music_theory/tone_pattern.dart";

/// Flattens tokens into their bare degree numbers for easy comparison,
/// asserting every token in [tokens] is a singleton (no groups).
List<int> _flatten(List<PatternToken> tokens) {
  for (final token in tokens) {
    expect(token, hasLength(1), reason: "expected only singleton tokens");
  }
  return tokens.map((t) => t.single.degree).toList();
}

void main() {
  group("TonePattern.parse", () {
    test("parses a rolling broken pattern string", () {
      final tokens = TonePattern.parse(
        "1,2,3,2,3,4,3,4,5,4,5,6",
        n: 3,
      );
      expect(_flatten(tokens), [1, 2, 3, 2, 3, 4, 3, 4, 5, 4, 5, 6]);
    });

    test("parses a rolling blocked pattern string", () {
      final tokens = TonePattern.parse("(1,2,3),(2,3,4),(3,4,5)", n: 3);
      expect(tokens, [
        [const DegreeNote(1), const DegreeNote(2), const DegreeNote(3)],
        [const DegreeNote(2), const DegreeNote(3), const DegreeNote(4)],
        [const DegreeNote(3), const DegreeNote(4), const DegreeNote(5)],
      ]);
    });

    test("parses the arbitrary mixed pattern from the requirements", () {
      final tokens = TonePattern.parse("1,(2,3),4,2,(3,4),5", n: 3);
      expect(tokens, [
        [const DegreeNote(1)],
        [const DegreeNote(2), const DegreeNote(3)],
        [const DegreeNote(4)],
        [const DegreeNote(2)],
        [const DegreeNote(3), const DegreeNote(4)],
        [const DegreeNote(5)],
      ]);
    });

    test("parses hand-tagged degrees", () {
      final tokens = TonePattern.parse("(1L,1),2,3,(1L,2),3,4", n: 3);
      expect(tokens.first, [
        const DegreeNote(1, PracticeHand.left),
        const DegreeNote(1),
      ]);
      expect(tokens[3], [
        const DegreeNote(1, PracticeHand.left),
        const DegreeNote(2),
      ]);
    });

    test("ignores surrounding whitespace", () {
      final tokens = TonePattern.parse(" 1, 2 , (3, 4) ", n: 3);
      expect(tokens, [
        [const DegreeNote(1)],
        [const DegreeNote(2)],
        [const DegreeNote(3), const DegreeNote(4)],
      ]);
    });

    test("throws on an unclosed group", () {
      expect(() => TonePattern.parse("1,(2,3", n: 3), throwsFormatException);
    });

    test("throws on a non-numeric degree", () {
      expect(() => TonePattern.parse("1,x,3", n: 3), throwsFormatException);
    });

    test("resolves apostrophe octave marks relative to the chord size", () {
      // For a triad (n=3), 1' means "root, one octave up" == degree 4.
      final tokens = TonePattern.parse("1,2,3,1'", n: 3);
      expect(_flatten(tokens), [1, 2, 3, 4]);
    });

    test("stacks multiple octave marks", () {
      // 1'' means two octaves up == degree 1 + 3*2 = 7 for a triad.
      final tokens = TonePattern.parse("1''", n: 3);
      expect(_flatten(tokens), [7]);
    });

    test("resolves octave marks against the seventh-chord tone count", () {
      // For a seventh chord (n=4), 1' == degree 5.
      final tokens = TonePattern.parse("1,2,3,4,1'", n: 4);
      expect(_flatten(tokens), [1, 2, 3, 4, 5]);
    });

    test("applies octave marks before a hand suffix", () {
      final tokens = TonePattern.parse("1'L", n: 3);
      expect(tokens.single, [const DegreeNote(4, PracticeHand.left)]);
    });

    test("octave marks produce the same result as writing the degree out", () {
      final marked = TonePattern.parse("1,2,3,1',2',3'", n: 3);
      final spelled = TonePattern.parse("1,2,3,4,5,6", n: 3);
      expect(marked, spelled);
    });
  });

  group("TonePattern.straightBroken", () {
    test("triad, 1 octave matches the legacy root-position shape", () {
      final tokens = TonePattern.straightBroken(n: 3, octaves: 1);
      expect(_flatten(tokens), [1, 2, 3, 4]);
    });

    test("triad, 3 octaves", () {
      final tokens = TonePattern.straightBroken(n: 3, octaves: 3);
      expect(_flatten(tokens), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test("seventh chord, 2 octaves", () {
      final tokens = TonePattern.straightBroken(n: 4, octaves: 2);
      expect(_flatten(tokens), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
  });

  group("TonePattern.rollingBroken", () {
    test("matches the requirements' worked example for a triad", () {
      final tokens = TonePattern.rollingBroken(n: 3, octaves: 3);
      expect(_flatten(tokens), [
        1, 2, 3, //
        2, 3, 4, //
        3, 4, 5, //
        4, 5, 6, //
        5, 6, 7, //
        6, 7, 8, //
        7, 8, 9, //
        8, 9, 10, //
      ]);
    });

    test("seventh chord, 1 octave", () {
      final tokens = TonePattern.rollingBroken(n: 4, octaves: 1);
      expect(_flatten(tokens), [1, 2, 3, 4, 2, 3, 4, 5]);
    });
  });

  group("TonePattern.straightBlocked", () {
    test("triad, 3 octaves produces one token per octave", () {
      final tokens = TonePattern.straightBlocked(n: 3, octaves: 3);
      expect(tokens, [
        [const DegreeNote(1), const DegreeNote(2), const DegreeNote(3)],
        [const DegreeNote(4), const DegreeNote(5), const DegreeNote(6)],
        [const DegreeNote(7), const DegreeNote(8), const DegreeNote(9)],
      ]);
    });
  });

  group("TonePattern.rollingBlocked", () {
    test("matches the requirements' worked example for a triad", () {
      final tokens = TonePattern.rollingBlocked(n: 3, octaves: 1);
      expect(tokens, [
        [const DegreeNote(1), const DegreeNote(2), const DegreeNote(3)],
        [const DegreeNote(2), const DegreeNote(3), const DegreeNote(4)],
      ]);
    });

    test("triad, 3 octaves has 7 overlapping groups", () {
      final tokens = TonePattern.rollingBlocked(n: 3, octaves: 3);
      expect(tokens, hasLength(8));
      expect(tokens.first, [
        const DegreeNote(1),
        const DegreeNote(2),
        const DegreeNote(3),
      ]);
      expect(tokens.last, [
        const DegreeNote(8),
        const DegreeNote(9),
        const DegreeNote(10),
      ]);
    });
  });

  group("TonePattern.mirrored", () {
    test("appends the reversed ascent, excluding the duplicated top token", () {
      final ascending = TonePattern.straightBroken(n: 3, octaves: 1);
      final mirroredResult = TonePattern.mirrored(ascending);
      expect(_flatten(mirroredResult), [1, 2, 3, 4, 3, 2, 1]);
    });
  });

  group("TonePattern.withLeftHandRootTap", () {
    test("inserts a left-hand root tap at every group boundary", () {
      final tokens = TonePattern.rollingBroken(n: 3, octaves: 1);
      final tapped = TonePattern.withLeftHandRootTap(tokens, 3);
      expect(tapped[0], [
        const DegreeNote(1, PracticeHand.left),
        const DegreeNote(1),
      ]);
      expect(tapped[1], [const DegreeNote(2)]);
      expect(tapped[2], [const DegreeNote(3)]);
      expect(tapped[3], [
        const DegreeNote(1, PracticeHand.left),
        const DegreeNote(2),
      ]);
    });

    test("groupSize 1 taps every token (blocked patterns)", () {
      final tokens = TonePattern.rollingBlocked(n: 3, octaves: 1);
      final tapped = TonePattern.withLeftHandRootTap(tokens, 1);
      for (final token in tapped) {
        expect(token.first, const DegreeNote(1, PracticeHand.left));
      }
    });
  });

  group("TonePattern.bothHands", () {
    test("duplicates every degree into left and right hands", () {
      final tokens = TonePattern.straightBroken(n: 3, octaves: 1);
      final both = TonePattern.bothHands(tokens);
      expect(both.first, [
        const DegreeNote(1, PracticeHand.left),
        const DegreeNote(1, PracticeHand.right),
      ]);
      expect(both, hasLength(tokens.length));
    });
  });

  group("TonePattern.toPracticeSteps", () {
    const coreIntervals = [0, 4, 7]; // major triad

    int rootMidiForHand(PracticeHand hand) =>
        hand == PracticeHand.left ? 36 : 48; // C2 / C3

    test("resolves degree formula to MIDI pitches", () {
      final tokens = TonePattern.rollingBroken(n: 3, octaves: 1);
      final steps = TonePattern.toPracticeSteps(
        tokens: tokens,
        coreIntervals: coreIntervals,
        rootMidiForHand: rootMidiForHand,
        defaultHand: PracticeHand.right,
      );

      expect(
        steps.map((s) => s.notes.single.pitch.value).toList(),
        [48, 52, 55, 52, 55, 60],
      );
      for (final step in steps) {
        expect(step.notes.single.hand, PracticeHand.right);
      }
    });

    test("keeps 3-4 octave spans within the MIDI range", () {
      // Highest root (B) at a typical start octave, seventh chord, 4 octaves.
      const sevenChordIntervals = [0, 4, 7, 10];
      final tokens = TonePattern.mirrored(
        TonePattern.rollingBroken(n: 4, octaves: 4),
      );
      final steps = TonePattern.toPracticeSteps(
        tokens: tokens,
        coreIntervals: sevenChordIntervals,
        rootMidiForHand: (_) => 71, // B4
        defaultHand: PracticeHand.right,
      );
      for (final step in steps) {
        for (final note in step.notes) {
          expect(note.pitch.value, inInclusiveRange(0, 127));
        }
      }
    });

    test("assigns fingers by position within each hand's notes in a step", () {
      final tokens = TonePattern.withLeftHandRootTap(
        TonePattern.rollingBroken(n: 3, octaves: 1),
        3,
      );
      final steps = TonePattern.toPracticeSteps(
        tokens: tokens,
        coreIntervals: coreIntervals,
        rootMidiForHand: rootMidiForHand,
        defaultHand: PracticeHand.right,
        fingerFor: (hand, stepIndex, positionInHand) =>
            hand == PracticeHand.left ? 5 : [1, 2, 3][positionInHand],
      );

      final firstStep = steps.first;
      final left = firstStep.notes.firstWhere(
        (n) => n.hand == PracticeHand.left,
      );
      final right = firstStep.notes.firstWhere(
        (n) => n.hand == PracticeHand.right,
      );
      expect(left.fingerNumber, 5);
      expect(right.fingerNumber, 1);
    });

    test("attaches step metadata by index", () {
      final tokens = TonePattern.straightBroken(n: 3, octaves: 1);
      final steps = TonePattern.toPracticeSteps(
        tokens: tokens,
        coreIntervals: coreIntervals,
        rootMidiForHand: rootMidiForHand,
        defaultHand: PracticeHand.right,
        metadataFor: (i) => {"position": i + 1},
      );
      expect(steps.first.metadata, {"position": 1});
      expect(steps.last.metadata, {"position": steps.length});
    });
  });
}
