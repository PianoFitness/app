#!/usr/bin/env dart

import "dart:io";
import "package:piano_fitness/scripts/commit_validator.dart";

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln("Error: No commit message file provided");
    exit(1);
  }

  final commitMsgFile = arguments[0];
  final file = File(commitMsgFile);

  if (!file.existsSync()) {
    stderr.writeln("Error: Commit message file not found: $commitMsgFile");
    exit(1);
  }

  try {
    final commitMessage = file.readAsStringSync().trim();

    if (CommitValidator.isValidCommitMessage(commitMessage)) {
      print("✅ Commit message format is valid");
      exit(0);
    } else {
      print(CommitValidator.generateHelpText(commitMessage));
      exit(1);
    }
  } catch (e) {
    stderr.writeln("Error reading commit message file: $e");
    exit(1);
  }
}
