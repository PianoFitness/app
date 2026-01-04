import "package:piano_fitness/shared/utils/scales.dart";

/// Utility class for navigating keys according to the Circle of Fifths.
///
/// The Circle of Fifths is a fundamental music theory concept that arranges
/// the twelve chromatic keys in a circle, where each key is a perfect fifth
/// (7 semitones) above the previous one. This creates a natural progression
/// that is widely used in music composition and practice.
///
/// Moving clockwise around the circle increases by a perfect fifth:
/// C → G → D → A → E → B → F♯/G♭ → D♭/C♯ → A♭/G♯ → E♭/D♯ → B♭/A♯ → F → C
///
/// This utility is particularly useful for systematic practice, where musicians
/// often want to practice patterns (scales, arpeggios, chords) in all twelve keys,
/// following the circle of fifths progression.
class CircleOfFifths {
  /// The twelve keys arranged in circle of fifths order.
  ///
  /// Each key is a perfect fifth (7 semitones) higher than the previous one.
  /// The progression starts at C and moves clockwise through all twelve keys
  /// before returning to C.
  ///
  /// Note: Enharmonic equivalents (e.g., F♯/G♭, C♯/D♭) are represented by a
  /// single Key enum value. The enum uses sharp naming (fSharp, cSharp, etc.)
  /// but these represent both the sharp and flat notations.
  static const List<Key> circleOfFifths = [
    Key.c, // C
    Key.g, // G
    Key.d, // D
    Key.a, // A
    Key.e, // E
    Key.b, // B
    Key.fSharp, // F♯/G♭
    Key.cSharp, // C♯/D♭
    Key.gSharp, // G♯/A♭
    Key.dSharp, // D♯/E♭
    Key.aSharp, // A♯/B♭
    Key.f, // F
  ];

  /// Returns the next key in the circle of fifths progression.
  ///
  /// Given a current key, returns the key that is a perfect fifth higher.
  /// When the end of the circle is reached (F), it wraps around to the
  /// beginning (C).
  ///
  /// Example:
  /// ```dart
  /// CircleOfFifths.getNextKey(Key.c) // Returns Key.g
  /// CircleOfFifths.getNextKey(Key.e) // Returns Key.b
  /// CircleOfFifths.getNextKey(Key.f) // Returns Key.c (wraps around)
  /// ```
  ///
  /// Parameters:
  /// - [current]: The current key in the progression
  ///
  /// Returns: The next key in the circle of fifths, or the first key if
  /// wrapping around from the end.
  static Key getNextKey(Key current) {
    final currentIndex = circleOfFifths.indexOf(current);

    // If the key is not found in the circle (shouldn't happen with valid Key enum),
    // default to returning the first key (C)
    if (currentIndex == -1) {
      return circleOfFifths.first;
    }

    // Get the next index, wrapping around to 0 if we've reached the end
    final nextIndex = (currentIndex + 1) % circleOfFifths.length;

    return circleOfFifths[nextIndex];
  }

  /// Returns the previous key in the circle of fifths progression.
  ///
  /// Given a current key, returns the key that is a perfect fifth lower.
  /// When the beginning of the circle is reached (C), it wraps around to
  /// the end (F).
  ///
  /// This method is provided for potential future use cases, such as
  /// backward navigation or counter-clockwise progression.
  ///
  /// Example:
  /// ```dart
  /// CircleOfFifths.getPreviousKey(Key.g) // Returns Key.c
  /// CircleOfFifths.getPreviousKey(Key.b) // Returns Key.e
  /// CircleOfFifths.getPreviousKey(Key.c) // Returns Key.f (wraps around)
  /// ```
  ///
  /// Parameters:
  /// - [current]: The current key in the progression
  ///
  /// Returns: The previous key in the circle of fifths, or the last key if
  /// wrapping around from the beginning.
  static Key getPreviousKey(Key current) {
    final currentIndex = circleOfFifths.indexOf(current);

    // If the key is not found in the circle (shouldn't happen with valid Key enum),
    // default to returning the last key (F)
    if (currentIndex == -1) {
      return circleOfFifths.last;
    }

    // Get the previous index, wrapping around to the end if we're at the beginning
    final previousIndex =
        (currentIndex - 1 + circleOfFifths.length) % circleOfFifths.length;

    return circleOfFifths[previousIndex];
  }
}
