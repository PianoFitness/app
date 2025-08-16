/// Library for validating conventional commit messages
library;

/// Conventional commit types with their descriptions
const Map<String, String> commitTypes = {
  "feat": "new feature for the user",
  "fix": "bug fix for the user",
  "docs": "changes to documentation",
  "style": "formatting, missing semi colons, etc; no code change",
  "refactor": "refactoring production code",
  "perf": "performance improvements",
  "test": "adding missing tests, refactoring tests",
  "build": "changes to build system or external dependencies",
  "ci": "changes to CI configuration files and scripts",
  "chore": "updating grunt tasks etc; no production code change",
  "revert": "reverting a previous commit",
};

/// Examples of valid commit messages for different contexts
const List<String> examples = [
  "feat(piano): add chord progression practice",
  "fix(midi): resolve timing issues",
  "docs: update README with lefthook setup",
  "perf(audio): optimize MIDI processing",
  "test(practice): add unit tests for chord validation",
];

/// Utility class for validating conventional commit messages
class CommitValidator {
  /// Validates a commit message against conventional commit format
  static bool isValidCommitMessage(String message) {
    final typePattern = commitTypes.keys.join("|");
    final regex = RegExp(r"^(" + typePattern + r")(\(.+\))?: .{1,50}$");
    return regex.hasMatch(message);
  }

  /// Generates a regex pattern from available commit types
  static String buildRegexPattern() {
    final typePattern = commitTypes.keys.join("|");
    return "^($typePattern)(\\(.+\\))?: .{1,50}\$";
  }

  /// Generates help text for invalid commit messages
  static String generateHelpText(String invalidMessage) {
    final buffer = StringBuffer()
      ..writeln("❌ Commit message should follow conventional commits format:")
      ..writeln("   type(scope): description")
      ..writeln()
      ..writeln("Allowed types:");

    // Find the longest type name for proper alignment
    final maxTypeLength = commitTypes.keys
        .map((type) => type.length)
        .reduce((max, length) => length > max ? length : max);

    for (final entry in commitTypes.entries) {
      final type = entry.key.padRight(maxTypeLength);
      buffer.writeln("   $type - ${entry.value}");
    }

    buffer
      ..writeln()
      ..writeln("Examples:");
    for (final example in examples) {
      buffer.writeln("   $example");
    }

    buffer
      ..writeln()
      ..writeln("Your message: $invalidMessage");

    return buffer.toString();
  }
}
