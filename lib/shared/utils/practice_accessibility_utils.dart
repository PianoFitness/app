import "package:piano_fitness/domain/models/practice/exercise.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

/// Utilities for generating accessibility semantics for practice exercises.
///
/// Provides step-type-aware semantic labels and announcements to help
/// screen reader users understand how to interact with practice exercises.
class PracticeAccessibilityUtils {
  /// Generates a step-type-aware semantic label for a practice step.
  ///
  /// Returns a descriptive label that includes the step number, display name
  /// (if available), and hints about how to play the step based on its type.
  ///
  /// Example outputs:
  /// - "Step 1 of 8: Degree 1 (Right Hand). Play this note"
  /// - "Step 2 of 7: C Major. Play all notes together simultaneously"
  /// - "Step 1 of 4: I: C Major. Play all notes together simultaneously"
  static String getStepSemanticLabel(
    PracticeStep step,
    int stepNumber,
    int totalSteps,
  ) {
    final displayName =
        step.metadata?["displayName"] as String? ?? "Step $stepNumber";
    final stepTypeHint = _getStepTypeHint(step.type);

    return "Step $stepNumber of $totalSteps: $displayName. $stepTypeHint";
  }

  /// Generates a semantic announcement when advancing to a new step.
  ///
  /// Returns an announcement that includes the step's display name,
  /// an action hint based on step type, and the notes to be played.
  ///
  /// Example outputs:
  /// - "Degree 2 (Right Hand). Press: D4"
  /// - "C Major. Press and hold together: C4, E4, G4"
  /// - "I: C Major. Press and hold together: C4, E4, G4"
  static String getStepChangeAnnouncement(
    PracticeStep newStep,
    int stepNumber,
  ) {
    final displayName =
        newStep.metadata?["displayName"] as String? ?? "Step $stepNumber";
    final actionHint = _getActionHint(newStep.type);
    final noteNames = _formatNoteNames(newStep.notes);

    return "$displayName. $actionHint $noteNames";
  }

  /// Returns a hint describing how to play a step based on its type.
  static String _getStepTypeHint(StepType type) {
    switch (type) {
      case StepType.simultaneous:
        return "Play all notes together simultaneously";
      case StepType.sequential:
        return "Play this note";
      case StepType.paired:
        return "Play both notes together";
    }
  }

  /// Returns an action hint for announcing step changes.
  static String _getActionHint(StepType type) {
    switch (type) {
      case StepType.simultaneous:
        return "Press and hold together:";
      case StepType.sequential:
        return "Press:";
      case StepType.paired:
        return "Press both notes together:";
    }
  }

  /// Formats a list of MIDI note numbers into readable note names.
  ///
  /// Returns a comma-separated list of note names (e.g., "C4, E4, G4").
  static String _formatNoteNames(List<int> midiNotes) {
    return midiNotes
        .map((midi) {
          final noteInfo = NoteUtils.midiNumberToNote(midi);
          return NoteUtils.noteDisplayName(noteInfo.note, noteInfo.octave);
        })
        .join(", ");
  }
}
