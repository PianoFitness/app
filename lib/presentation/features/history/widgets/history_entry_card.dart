import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/broken_chord_pattern.dart";
import "package:intl/intl.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/practice/tempo_consistency_interpreter.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// A general-purpose card that displays one [ExerciseHistoryEntry].
///
/// Handles all six [PracticeMode] variants and formats the exercise parameters
/// into a human-readable description. All entries share this single widget —
/// no subclassing per mode is needed.
class HistoryEntryCard extends StatelessWidget {
  /// Creates a history entry card for the given [entry].
  const HistoryEntryCard({required this.entry, super.key});

  /// The history entry to display.
  final ExerciseHistoryEntry entry;

  static final _dateFormat = DateFormat("MMM d, yyyy  h:mm a");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = _buildDescription(entry);
    final handLabel = _handLabel(entry.handSelection);
    final timeLabel = _dateFormat.format(entry.completedAt.toLocal());
    final modeLabel = _modeLabel(entry.practiceMode);

    final accuracy = entry.accuracyPercentage;
    final accuracyLabel = accuracy != null
        ? "${accuracy.toStringAsFixed(0)}% accuracy"
        : "";
    final tempoBpm = entry.measuredTempoBpm;
    final tempoLabel = tempoBpm != null
        ? "${tempoBpm.toStringAsFixed(1)} BPM"
        : null;
    final tempoConsistency = TempoConsistencyInterpreter.assess(
      coefficientOfVariation: entry.tempoCoefficientOfVariation,
      meanInterOnsetMicroseconds: entry.meanInterOnsetMicroseconds,
      interOnsetStandardDeviationMicroseconds:
          entry.interOnsetStandardDeviationMicroseconds,
      intervalCount: entry.tempoIntervalCount,
      measurementQuality: entry.tempoMeasurementQuality,
    );
    final tempoQualityLabel = tempoBpm != null
        ? _tempoFeedbackLabel(
            assessment: tempoConsistency,
            fallbackQuality: entry.tempoMeasurementQuality,
          ).toLowerCase()
        : null;

    final semanticLabel = accuracy != null
        ? "$modeLabel — $description · $handLabel · $accuracyLabel${tempoLabel != null ? " · $tempoLabel, $tempoQualityLabel" : ""} · $timeLabel"
        : "$modeLabel — $description · $handLabel${tempoLabel != null ? " · $tempoLabel, $tempoQualityLabel" : ""} · $timeLabel";

    return Semantics(
      label: semanticLabel,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: [
                  Text(
                    modeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 2),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: [
                  Text(
                    accuracy != null
                        ? "$handLabel · $accuracyLabel"
                        : handLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: accuracy != null ? FontWeight.w500 : null,
                    ),
                  ),
                  if (tempoBpm != null)
                    _TempoBadge(
                      bpm: tempoBpm,
                      assessment: tempoConsistency,
                      fallbackQuality: entry.tempoMeasurementQuality,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Label helpers ───────────────────────────────────────────────────────

  String _modeLabel(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.scales:
        return "Scales";
      case PracticeMode.chordsByKey:
        return "Chords by Key";
      case PracticeMode.chordsByType:
        return "Chords by Type";
      case PracticeMode.arpeggios:
        return "Arpeggios";
      case PracticeMode.blockChords:
        return "Block Chords";
      case PracticeMode.chordProgressions:
        return "Chord Progressions";
      case PracticeMode.brokenChordAccompaniment:
        return "Broken-Chord Accompaniment";
      case PracticeMode.dominantCadence:
        return "Dominant Cadence";
    }
  }

  String _handLabel(HandSelection hand) {
    switch (hand) {
      case HandSelection.left:
        return "Left Hand";
      case HandSelection.right:
        return "Right Hand";
      case HandSelection.both:
        return "Both Hands";
    }
  }

  String _buildDescription(ExerciseHistoryEntry e) {
    switch (e.practiceMode) {
      case PracticeMode.scales:
        final key = e.musicalKey?.displayName ?? "?";
        final scale = _scaleTypeName(e.scaleType);
        return "$key $scale Scale";

      case PracticeMode.chordsByKey:
        final key = e.musicalKey?.displayName ?? "?";
        final suffix = e.includeSeventhChords ? ", with 7ths" : "";
        return "$key Chords$suffix";

      case PracticeMode.chordsByType:
        final type = e.chordType != null ? _chordTypeName(e.chordType!) : "?";
        final suffix = e.includeInversions ? ", with inversions" : "";
        return "$type Chords$suffix";

      case PracticeMode.arpeggios:
      case PracticeMode.blockChords:
        final note = e.musicalNote != null
            ? _musicalNoteName(e.musicalNote!)
            : "?";
        final type = e.arpeggioType != null
            ? _arpeggioTypeName(e.arpeggioType!)
            : "?";
        final octaves = e.arpeggioOctaves?.count ?? 1;
        final label = e.practiceMode == PracticeMode.arpeggios
            ? "Arpeggio"
            : "Block Chords";
        return "$note $type $label ($octaves oct)";

      case PracticeMode.chordProgressions:
        final key = e.musicalKey?.displayName ?? "?";
        final prog = e.chordProgressionId ?? "?";
        return "$key — $prog";

      case PracticeMode.brokenChordAccompaniment:
        final key = e.musicalKey?.displayName ?? "?";
        final progression = e.chordProgressionId ?? "?";
        final pattern = e.brokenChordPattern?.displayName ?? "?";
        return "$key — $progression ($pattern)";

      case PracticeMode.dominantCadence:
        final key = e.musicalKey?.displayName ?? "?";
        return "$key Dominant Cadence";
    }
  }

  // ── Per-type name formatters ─────────────────────────────────────────────

  String _scaleTypeName(music.ScaleType? type) {
    if (type == null) return "?";
    switch (type) {
      case music.ScaleType.major:
        return "Major";
      case music.ScaleType.minor:
        return "Minor";
      case music.ScaleType.dorian:
        return "Dorian";
      case music.ScaleType.phrygian:
        return "Phrygian";
      case music.ScaleType.lydian:
        return "Lydian";
      case music.ScaleType.mixolydian:
        return "Mixolydian";
      case music.ScaleType.aeolian:
        return "Aeolian";
      case music.ScaleType.locrian:
        return "Locrian";
    }
  }

  String _chordTypeName(ChordType type) {
    switch (type) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "Minor";
      case ChordType.diminished:
        return "Diminished";
      case ChordType.augmented:
        return "Augmented";
      case ChordType.suspended2:
        return "Suspended 2nd";
      case ChordType.suspended4:
        return "Suspended 4th";
      case ChordType.major7:
        return "Major 7th";
      case ChordType.dominant7:
        return "Dominant 7th";
      case ChordType.minor7:
        return "Minor 7th";
      case ChordType.halfDiminished7:
        return "Half-Diminished 7th";
      case ChordType.diminished7:
        return "Diminished 7th";
      case ChordType.minorMajor7:
        return "Minor-Major 7th";
      case ChordType.augmented7:
        return "Augmented 7th";
    }
  }

  String _arpeggioTypeName(ArpeggioType type) {
    switch (type) {
      case ArpeggioType.major:
        return "Major";
      case ArpeggioType.minor:
        return "Minor";
      case ArpeggioType.diminished:
        return "Diminished";
      case ArpeggioType.augmented:
        return "Augmented";
      case ArpeggioType.dominant7:
        return "Dominant 7th";
      case ArpeggioType.minor7:
        return "Minor 7th";
      case ArpeggioType.major7:
        return "Major 7th";
    }
  }

  String _musicalNoteName(MusicalNote note) {
    const names = {
      MusicalNote.c: "C",
      MusicalNote.cSharp: "C#",
      MusicalNote.d: "D",
      MusicalNote.dSharp: "D#",
      MusicalNote.e: "E",
      MusicalNote.f: "F",
      MusicalNote.fSharp: "F#",
      MusicalNote.g: "G",
      MusicalNote.gSharp: "G#",
      MusicalNote.a: "A",
      MusicalNote.aSharp: "A#",
      MusicalNote.b: "B",
    };
    return names[note] ?? note.name;
  }
}

class _TempoBadge extends StatelessWidget {
  const _TempoBadge({
    required this.bpm,
    required this.assessment,
    required this.fallbackQuality,
  });

  final double bpm;
  final TempoConsistencyAssessment? assessment;
  final TempoMeasurementQuality? fallbackQuality;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final presentation = switch (assessment?.band) {
      TempoConsistencyBand.steady => (
        icon: Icons.horizontal_rule_rounded,
        stateName: TempoConsistencyBand.steady.name,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
      ),
      TempoConsistencyBand.mostlySteady => (
        icon: Icons.graphic_eq_rounded,
        stateName: TempoConsistencyBand.mostlySteady.name,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      TempoConsistencyBand.varied => (
        icon: Icons.waves_rounded,
        stateName: TempoConsistencyBand.varied.name,
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
      ),
      TempoConsistencyBand.shortSample => (
        icon: Icons.timelapse_rounded,
        stateName: TempoConsistencyBand.shortSample.name,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      null => _fallbackPresentation(colors),
    };
    final bpmLabel = "${bpm.toStringAsFixed(1)} BPM";
    final feedbackLabel = _tempoFeedbackLabel(
      assessment: assessment,
      fallbackQuality: fallbackQuality,
    );
    final coefficient = assessment?.coefficientOfVariation;
    final tooltipLabel = coefficient != null
        ? "$feedbackLabel · ${(coefficient * 100).toStringAsFixed(1)}% timing variation"
        : feedbackLabel;

    return Tooltip(
      message: tooltipLabel,
      child: Semantics(
        label: "$bpmLabel, $tooltipLabel",
        child: ExcludeSemantics(
          child: DecoratedBox(
            key: Key("history_tempo_${presentation.stateName}"),
            decoration: BoxDecoration(
              color: presentation.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    presentation.icon,
                    size: ComponentDimensions.iconSizeSmall,
                    color: presentation.foreground,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    bpmLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: presentation.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({IconData icon, String stateName, Color background, Color foreground})
  _fallbackPresentation(ColorScheme colors) {
    return switch (fallbackQuality) {
      TempoMeasurementQuality.reliable => (
        icon: Icons.horizontal_rule_rounded,
        stateName: TempoMeasurementQuality.reliable.name,
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
      ),
      TempoMeasurementQuality.inconsistent => (
        icon: Icons.waves_rounded,
        stateName: TempoMeasurementQuality.inconsistent.name,
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
      ),
      TempoMeasurementQuality.insufficientData => (
        icon: Icons.timelapse_rounded,
        stateName: TempoMeasurementQuality.insufficientData.name,
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
      TempoMeasurementQuality.unavailable || null => (
        icon: Icons.speed_rounded,
        stateName: "measured",
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
      ),
    };
  }
}

String _tempoFeedbackLabel({
  required TempoConsistencyAssessment? assessment,
  required TempoMeasurementQuality? fallbackQuality,
}) {
  if (assessment != null) {
    return switch (assessment.band) {
      TempoConsistencyBand.steady => "Steady tempo",
      TempoConsistencyBand.mostlySteady => "Mostly steady",
      TempoConsistencyBand.varied => "Varied tempo",
      TempoConsistencyBand.shortSample => "Short tempo sample",
    };
  }
  return switch (fallbackQuality) {
    TempoMeasurementQuality.reliable => "Steady tempo",
    TempoMeasurementQuality.inconsistent => "Varied tempo",
    TempoMeasurementQuality.insufficientData => "Short tempo sample",
    TempoMeasurementQuality.unavailable || null => "Measured tempo",
  };
}
