// ignore_for_file: avoid_print

import "dart:io";

/// Helper script to summarize lcov.info metrics cleanly by layer and calculate
/// handwritten application layer coverage excluding generated code.
void main(List<String> args) {
  final lcovFile = File("coverage/lcov.info");
  if (!lcovFile.existsSync()) {
    print(
      "Error: coverage/lcov.info does not exist. Run 'flutter test --coverage' first.",
    );
    exit(1);
  }

  final lines = lcovFile.readAsLinesSync();
  String? currentFile;
  var totalLf = 0;
  var totalLh = 0;
  var appHandwrittenLf = 0;
  var appHandwrittenLh = 0;

  final fileStats = <String, Map<String, int>>{};
  final groupStats = <String, Map<String, int>>{};

  var currentLf = 0;
  var currentLh = 0;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith("SF:")) {
      var path = trimmed.substring(3).replaceAll("\\", "/");
      final libIndex = path.indexOf("lib/");
      if (libIndex != -1) {
        path = path.substring(libIndex);
      }
      currentFile = path;
      currentLf = 0;
      currentLh = 0;
    } else if (trimmed.startsWith("LF:")) {
      currentLf = int.parse(trimmed.substring(3));
      totalLf += currentLf;
    } else if (trimmed.startsWith("LH:")) {
      currentLh = int.parse(trimmed.substring(3));
      totalLh += currentLh;

      if (currentFile != null) {
        fileStats[currentFile] = {"lf": currentLf, "lh": currentLh};

        final parts = currentFile.split("/");
        final grp = parts.length > 2 ? "${parts[0]}/${parts[1]}" : currentFile;
        groupStats.putIfAbsent(grp, () => {"lf": 0, "lh": 0});
        groupStats[grp]!["lf"] = (groupStats[grp]!["lf"] ?? 0) + currentLf;
        groupStats[grp]!["lh"] = (groupStats[grp]!["lh"] ?? 0) + currentLh;

        if (currentFile.startsWith("lib/application") &&
            !currentFile.endsWith(".g.dart") &&
            !currentFile.endsWith(".steps.dart")) {
          appHandwrittenLf += currentLf;
          appHandwrittenLh += currentLh;
        }
      }
    }
  }

  print("=========================================================");
  print("                  CODE COVERAGE REPORT                   ");
  print("=========================================================");
  final totalPct = totalLf > 0
      ? (totalLh / totalLf * 100).toStringAsFixed(2)
      : "0.00";
  print("OVERALL COVERAGE: $totalLh / $totalLf ($totalPct%)");
  print("---------------------------------------------------------");

  for (final entry
      in groupStats.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
    final grp = entry.key;
    final lf = entry.value["lf"]!;
    final lh = entry.value["lh"]!;
    final pct = lf > 0 ? (lh / lf * 100).toStringAsFixed(2) : "0.00";
    print(
      "${grp.padRight(25)} : ${lh.toString().padLeft(4)} / ${lf.toString().padLeft(4)} (${pct.padLeft(6)}%)",
    );
  }

  final appPct = appHandwrittenLf > 0
      ? (appHandwrittenLh / appHandwrittenLf * 100).toStringAsFixed(2)
      : "0.00";
  print("---------------------------------------------------------");
  print(
    "HANDWRITTEN APPLICATION  : $appHandwrittenLh / $appHandwrittenLf (${appPct.padLeft(6)}%)",
  );
  print("=========================================================\n");

  print("--- TOP APPLICATION LAYER GAPS (< 85%) ---");
  final appGaps =
      fileStats.entries.where((e) {
        final path = e.key;
        return path.startsWith("lib/application") &&
            !path.endsWith(".g.dart") &&
            !path.endsWith(".steps.dart");
      }).toList()..sort((a, b) {
        final pctA = a.value["lf"]! > 0 ? a.value["lh"]! / a.value["lf"]! : 0;
        final pctB = b.value["lf"]! > 0 ? b.value["lh"]! / b.value["lf"]! : 0;
        return pctA.compareTo(pctB);
      });

  for (final entry in appGaps) {
    final path = entry.key;
    final lf = entry.value["lf"]!;
    final lh = entry.value["lh"]!;
    final missing = lf - lh;
    final pct = lf > 0 ? (lh / lf * 100).toStringAsFixed(2) : "0.00";
    if (double.parse(pct) < 85.0 && missing > 0) {
      print(
        "${pct.padLeft(6)}% (${lh.toString().padLeft(4)}/$lf) [missing ${missing.toString().padLeft(3)} lines] : $path",
      );
    }
  }
}
