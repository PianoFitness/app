import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/models/strategies/chords_by_key_strategy.dart";
import "package:piano_fitness/shared/models/configurations/chords_by_key_configuration.dart";
import "package:piano_fitness/shared/models/hand_selection.dart";
import "package:piano_fitness/shared/models/music_key.dart";
import "package:piano_fitness/shared/models/scale_type.dart";

class FakeChordsUtils {
  static List<int> getChordsByKey(
    MusicKey key,
    ScaleType scaleType, {
    required HandSelection hand,
  }) {
    // Placeholder: return a simple triad for C major
    if (key == MusicKey.c && scaleType == ScaleType.major) {
      return [60, 64, 67]; // C4, E4, G4
    }
    return [60];
  }
}

void main() {
  test("ChordsByKeyStrategy generates correct sequence for C major", () {
    final config = ChordsByKeyConfiguration(
      selectedKey: MusicKey.c,
      selectedScaleType: ScaleType.major,
      handSelection: HandSelection.right,
    );
    final strategy = ChordsByKeyStrategy(config);
    // Replace with actual chords_utils.getChordsByKey if available
    expect(strategy.generateSequence(), [60, 64, 67]);
    expect(strategy.getHighlightedNotes(0), [60]);
    expect(strategy.handleNotePressed(60, 0), true);
    expect(strategy.handleNoteReleased(60, 0), true);
  });
}
