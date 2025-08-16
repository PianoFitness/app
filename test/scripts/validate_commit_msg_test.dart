// ignore_for_file: avoid_print

import "package:piano_fitness/scripts/commit_validator.dart";

void main() {
  group("CommitValidator Tests", () {
    test("should accept valid conventional commit messages", () {
      final validMessages = [
        "feat: add new feature",
        "fix(ui): resolve button alignment",
        "docs: update README",
        "style: format code",
        "refactor(core): simplify logic",
        "perf: optimize database queries",
        "test: add unit tests",
        "build: update dependencies",
        "ci: configure GitHub Actions",
        "chore: update version",
        "revert: undo previous change",
      ];

      for (final message in validMessages) {
        expect(
          CommitValidator.isValidCommitMessage(message),
          isTrue,
          reason: "Message should be valid: $message",
        );
      }
    });

    test("should reject invalid commit messages", () {
      final invalidMessages = [
        "invalid message",
        "FEAT: uppercase type",
        "feat",
        "feat:",
        "feat: ",
        "unknown: invalid type",
        "feat: this is a very long commit message that exceeds fifty characters limit",
      ];

      for (final message in invalidMessages) {
        expect(
          CommitValidator.isValidCommitMessage(message),
          isFalse,
          reason: "Message should be invalid: $message",
        );
      }
    });

    test("should generate helpful error messages", () {
      const invalidMessage = "bad commit message";
      final helpText = CommitValidator.generateHelpText(invalidMessage);

      expect(helpText, contains("❌ Commit message should follow"));
      expect(helpText, contains("feat     - new feature"));
      expect(helpText, contains("Your message: $invalidMessage"));
      expect(helpText, contains("Examples:"));
    });

    test("should build correct regex pattern", () {
      final pattern = CommitValidator.buildRegexPattern();
      final regex = RegExp(pattern);

      expect(regex.hasMatch("feat: valid message"), isTrue);
      expect(regex.hasMatch("fix(scope): valid message"), isTrue);
      expect(regex.hasMatch("invalid: bad type"), isFalse);
    });
  });
}

// Mock test framework functions for demonstration
void group(String description, void Function() tests) {
  print("Running: $description");
  tests();
}

void test(String description, void Function() testFunction) {
  try {
    testFunction();
    print("  ✅ $description");
  } catch (e) {
    print("  ❌ $description - $e");
  }
}

void expect(dynamic actual, Matcher matcher, {String? reason}) {
  if (!matcher.matches(actual)) {
    throw Exception(reason ?? "Expected $actual to match $matcher");
  }
}

abstract class Matcher {
  bool matches(dynamic actual);
}

class _IsTrue extends Matcher {
  @override
  bool matches(dynamic actual) => actual == true;
  @override
  String toString() => "true";
}

class _IsFalse extends Matcher {
  @override
  bool matches(dynamic actual) => actual == false;
  @override
  String toString() => "false";
}

class _Contains extends Matcher {
  _Contains(this.substring);
  final String substring;

  @override
  bool matches(dynamic actual) =>
      actual is String && actual.contains(substring);

  @override
  String toString() => 'contains "$substring"';
}

final isTrue = _IsTrue();
final isFalse = _IsFalse();
Matcher contains(String substring) => _Contains(substring);
