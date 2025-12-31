import "package:piano_fitness/shared/models/practice_configuration.dart";

/// Base interface for all practice strategies.
abstract class PracticeStrategy {
  /// Called to generate the MIDI note sequence for the exercise.
  List<int> generateSequence();

  /// Returns the notes to highlight for the current step.
  List<int> getHighlightedNotes(int currentIndex);

  /// Handles a note-on event. Returns true if the note was correct.
  bool handleNotePressed(int midiNote, int currentIndex);

  /// Handles a note-off event. Returns true if the note was released correctly.
  bool handleNoteReleased(int midiNote, int currentIndex);

  /// Returns the configuration for this strategy.
  PracticeConfiguration get configuration;
}
