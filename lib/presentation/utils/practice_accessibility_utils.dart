import "package:piano_fitness/domain/models/practice/exercise.dart";

/// Utilities for generating accessibility semantics for practice exercises.
///
/// Provides semantic labels and announcements to help screen reader users
/// understand how to interact with practice exercises.
class PracticeAccessibilityUtils {
  /// Generates a semantic label for a practice step.
  ///
  /// Returns a descriptive label that includes the step number, display name
  /// (if available), and a hint based on the number of simultaneous notes.
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
    final stepHint = _getStepHint(step.notes.length);

    return "Step $stepNumber of $totalSteps: $displayName. $stepHint";
  }

  /// Generates a semantic announcement when advancing to a new step.
  ///
  /// Returns an announcement that includes the step's display name,
  /// an action hint based on step size, and the notes to be played.
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
    final actionHint = _getActionHint(newStep.notes.length);
    final noteNames = _formatNoteNames(newStep.notes);

    return "$displayName. $actionHint $noteNames";
  }

  /// Returns a hint describing how to play a simultaneous onset step.
  static String _getStepHint(int noteCount) {
    if (noteCount == 1) return "Play this note";
    if (noteCount == 2) return "Play both notes together";
    return "Play all notes together simultaneously";
  }

  /// Returns an action hint for announcing step changes.
  static String _getActionHint(int noteCount) {
    if (noteCount == 1) return "Press:";
    if (noteCount == 2) return "Press both notes together:";
    return "Press and hold together:";
  }

  /// Formats a list of practice notes into readable note names.
  ///
  /// Returns a comma-separated list of note names (e.g., "C4, E4, G4").
  static String _formatNoteNames(List<PracticeNote> notes) {
    return notes.map((note) => note.pitch.displayName).join(", ");
  }
}
