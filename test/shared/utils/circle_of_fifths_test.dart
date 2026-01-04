import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/utils/circle_of_fifths.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

void main() {
  group("CircleOfFifths", () {
    group("circleOfFifths constant", () {
      test("contains exactly 12 keys", () {
        expect(CircleOfFifths.circleOfFifths.length, equals(12));
      });

      test("starts with C", () {
        expect(CircleOfFifths.circleOfFifths.first, equals(music.Key.c));
      });

      test("ends with F", () {
        expect(CircleOfFifths.circleOfFifths.last, equals(music.Key.f));
      });

      test("follows correct circle of fifths order", () {
        final expectedOrder = [
          music.Key.c, // C
          music.Key.g, // G
          music.Key.d, // D
          music.Key.a, // A
          music.Key.e, // E
          music.Key.b, // B
          music.Key.fSharp, // F♯/G♭
          music.Key.cSharp, // C♯/D♭
          music.Key.gSharp, // G♯/A♭
          music.Key.dSharp, // D♯/E♭
          music.Key.aSharp, // A♯/B♭
          music.Key.f, // F
        ];

        expect(CircleOfFifths.circleOfFifths, equals(expectedOrder));
      });

      test("contains all 12 chromatic keys exactly once", () {
        final allKeys = music.Key.values.toSet();
        final circleKeys = CircleOfFifths.circleOfFifths.toSet();

        // All keys in the circle should be valid Key enum values
        expect(circleKeys.difference(allKeys), isEmpty);

        // All keys should appear exactly once (no duplicates)
        expect(CircleOfFifths.circleOfFifths.length, equals(circleKeys.length));
      });
    });

    group("getNextKey", () {
      test("C → G", () {
        expect(CircleOfFifths.getNextKey(music.Key.c), equals(music.Key.g));
      });

      test("G → D", () {
        expect(CircleOfFifths.getNextKey(music.Key.g), equals(music.Key.d));
      });

      test("D → A", () {
        expect(CircleOfFifths.getNextKey(music.Key.d), equals(music.Key.a));
      });

      test("A → E", () {
        expect(CircleOfFifths.getNextKey(music.Key.a), equals(music.Key.e));
      });

      test("E → B", () {
        expect(CircleOfFifths.getNextKey(music.Key.e), equals(music.Key.b));
      });

      test("B → F♯", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.b),
          equals(music.Key.fSharp),
        );
      });

      test("F♯ → C♯", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.fSharp),
          equals(music.Key.cSharp),
        );
      });

      test("C♯ → G♯", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.cSharp),
          equals(music.Key.gSharp),
        );
      });

      test("G♯ → D♯", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.gSharp),
          equals(music.Key.dSharp),
        );
      });

      test("D♯ → A♯", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.dSharp),
          equals(music.Key.aSharp),
        );
      });

      test("A♯ → F", () {
        expect(
          CircleOfFifths.getNextKey(music.Key.aSharp),
          equals(music.Key.f),
        );
      });

      test("F → C (wraps around)", () {
        expect(CircleOfFifths.getNextKey(music.Key.f), equals(music.Key.c));
      });

      test("complete cycle returns to starting key", () {
        music.Key current = music.Key.c;

        // Advance through all 12 keys
        for (int i = 0; i < 12; i++) {
          current = CircleOfFifths.getNextKey(current);
        }

        // Should be back to C
        expect(current, equals(music.Key.c));
      });

      test("multiple cycles maintain correct order", () {
        music.Key current = music.Key.c;
        final keysVisited = <music.Key>[];

        // Go through 3 complete cycles
        for (int i = 0; i < 36; i++) {
          current = CircleOfFifths.getNextKey(current);
          keysVisited.add(current);
        }

        // First 12 should match second 12 and third 12
        expect(keysVisited.sublist(0, 12), equals(keysVisited.sublist(12, 24)));
        expect(keysVisited.sublist(0, 12), equals(keysVisited.sublist(24, 36)));
      });
    });

    group("getPreviousKey", () {
      test("G → C", () {
        expect(CircleOfFifths.getPreviousKey(music.Key.g), equals(music.Key.c));
      });

      test("C → F (wraps around)", () {
        expect(CircleOfFifths.getPreviousKey(music.Key.c), equals(music.Key.f));
      });

      test("F → A♯", () {
        expect(
          CircleOfFifths.getPreviousKey(music.Key.f),
          equals(music.Key.aSharp),
        );
      });

      test("complete backward cycle returns to starting key", () {
        music.Key current = music.Key.c;

        // Go backward through all 12 keys
        for (int i = 0; i < 12; i++) {
          current = CircleOfFifths.getPreviousKey(current);
        }

        // Should be back to C
        expect(current, equals(music.Key.c));
      });

      test("forward then backward returns to starting key", () {
        music.Key current = music.Key.d;

        // Go forward 5 steps
        for (int i = 0; i < 5; i++) {
          current = CircleOfFifths.getNextKey(current);
        }

        // Go backward 5 steps
        for (int i = 0; i < 5; i++) {
          current = CircleOfFifths.getPreviousKey(current);
        }

        // Should be back to D
        expect(current, equals(music.Key.d));
      });
    });

    group("edge cases", () {
      test("getNextKey and getPreviousKey are inverses", () {
        for (final key in CircleOfFifths.circleOfFifths) {
          final next = CircleOfFifths.getNextKey(key);
          final backToOriginal = CircleOfFifths.getPreviousKey(next);
          expect(
            backToOriginal,
            equals(key),
            reason: "next($key) = $next, previous($next) should equal $key",
          );
        }
      });

      test("getPreviousKey and getNextKey are inverses", () {
        for (final key in CircleOfFifths.circleOfFifths) {
          final previous = CircleOfFifths.getPreviousKey(key);
          final backToOriginal = CircleOfFifths.getNextKey(previous);
          expect(
            backToOriginal,
            equals(key),
            reason:
                "previous($key) = $previous, next($previous) should equal $key",
          );
        }
      });
    });
  });
}
