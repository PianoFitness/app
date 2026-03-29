import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";

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

    final semanticLabel = "$modeLabel — $description · $handLabel · $timeLabel";

    return Semantics(
      label: semanticLabel,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(modeLabel, style: theme.textTheme.labelSmall),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
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
              Text(
                handLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
      case PracticeMode.chordProgressions:
        return "Chord Progressions";
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
        final note = e.musicalNote != null
            ? _musicalNoteName(e.musicalNote!)
            : "?";
        final type = e.arpeggioType != null
            ? _arpeggioTypeName(e.arpeggioType!)
            : "?";
        final octaves = e.arpeggioOctaves == ArpeggioOctaves.two ? "2" : "1";
        return "$note $type Arpeggio ($octaves oct)";

      case PracticeMode.chordProgressions:
        final key = e.musicalKey?.displayName ?? "?";
        final prog = e.chordProgressionId ?? "?";
        return "$key — $prog";

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
