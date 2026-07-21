import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Auto-progress key toggle widget.
class AutoProgressKeyToggleView extends StatelessWidget {
  /// Creates an auto progress key toggle view.
  const AutoProgressKeyToggleView({
    required this.autoProgressKeys,
    required this.onAutoProgressKeysChanged,
    super.key,
  });

  /// Whether auto-progress keys is enabled.
  final bool autoProgressKeys;

  /// Callback when auto-progress keys toggles.
  final ValueChanged<bool> onAutoProgressKeysChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            title: const Text("Auto-progress through keys"),
            subtitle: const Text("Follow circle of fifths after each exercise"),
            value: autoProgressKeys,
            onChanged: onAutoProgressKeysChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          ),
        ),
      ],
    );
  }
}

/// Settings widget for scales practice mode.
class ScalesSettingsView extends StatelessWidget {
  /// Creates a scales settings view.
  const ScalesSettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    required this.getScaleTypeString,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  /// Display string builder for scale types.
  final String Function(music.ScaleType) getScaleTypeString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<music.ScaleType>(
          key: ValueKey("scaleType_${configuration.scaleType}"),
          initialValue: configuration.scaleType,
          decoration: const InputDecoration(
            labelText: "Scale Type",
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          items: music.ScaleType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(getScaleTypeString(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigurationChanged(
                configuration.copyWith(scaleType: Field.set(value)),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Settings widget for chords by key practice mode.
class ChordsByKeySettingsView extends StatelessWidget {
  /// Creates a chords by key settings view.
  const ChordsByKeySettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    required this.getScaleTypeString,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  /// Display string builder for scale types.
  final String Function(music.ScaleType) getScaleTypeString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<music.ScaleType>(
          key: ValueKey("scaleType_${configuration.scaleType}"),
          initialValue: configuration.scaleType,
          decoration: const InputDecoration(
            labelText: "Scale Type",
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          items: music.ScaleType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(getScaleTypeString(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigurationChanged(
                configuration.copyWith(scaleType: Field.set(value)),
              );
            }
          },
        ),
        const SizedBox(height: Spacing.sm),
        Semantics(
          label: "Include seventh chords in chord-by-key exercises",
          child: Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              title: const Text("Include Seventh Chords"),
              subtitle: const Text("Add 7th note to triads"),
              value: configuration.includeSeventhChords,
              onChanged: (value) {
                if (value != null) {
                  onConfigurationChanged(
                    configuration.copyWith(includeSeventhChords: value),
                  );
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings widget for arpeggios practice mode.
class ArpeggiosSettingsView extends StatelessWidget {
  /// Creates an arpeggios settings view.
  const ArpeggiosSettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    required this.getArpeggioTypeString,
    required this.getArpeggioOctavesString,
    required this.getChordTonePatternString,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  /// String getter for arpeggio types.
  final String Function(ArpeggioType) getArpeggioTypeString;

  /// String getter for arpeggio octaves.
  final String Function(ArpeggioOctaves) getArpeggioOctavesString;

  /// String getter for chord tone patterns.
  final String Function(ChordTonePattern) getChordTonePatternString;

  @override
  Widget build(BuildContext context) {
    final showLeftHandRootToggle =
        configuration.handSelection == HandSelection.right &&
        (configuration.practiceMode == PracticeMode.blockChords ||
            configuration.pattern == ChordTonePattern.rolling);

    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ArpeggioType>(
                key: ValueKey("arpeggioType_${configuration.arpeggioType}"),
                initialValue: configuration.arpeggioType,
                decoration: const InputDecoration(
                  labelText: "Arpeggio Type",
                  border: OutlineInputBorder(),
                ),
                items: ArpeggioType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(getArpeggioTypeString(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onConfigurationChanged(
                      configuration.copyWith(arpeggioType: Field.set(value)),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: DropdownButtonFormField<ArpeggioOctaves>(
                key: ValueKey(
                  "arpeggioOctaves_${configuration.arpeggioOctaves}",
                ),
                initialValue: configuration.arpeggioOctaves,
                decoration: const InputDecoration(
                  labelText: "Octaves",
                  border: OutlineInputBorder(),
                ),
                items: ArpeggioOctaves.values.map((octaves) {
                  return DropdownMenuItem(
                    value: octaves,
                    child: Text(getArpeggioOctavesString(octaves)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onConfigurationChanged(
                      configuration.copyWith(arpeggioOctaves: value),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<ChordTonePattern>(
          key: ValueKey("pattern_${configuration.pattern}"),
          initialValue: configuration.pattern,
          decoration: const InputDecoration(
            labelText: "Pattern",
            border: OutlineInputBorder(),
          ),
          items: ChordTonePattern.values.map((pattern) {
            return DropdownMenuItem(
              value: pattern,
              child: Text(getChordTonePatternString(pattern)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigurationChanged(configuration.copyWith(pattern: value));
            }
          },
        ),
        if (showLeftHandRootToggle) ...[
          const SizedBox(height: Spacing.sm),
          Semantics(
            label:
                "Left hand taps the chord root once per rolling group, "
                "for hand-independence practice",
            child: Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                title: const Text("Left Hand Taps Root"),
                subtitle: const Text("Left hand plays the root once per group"),
                value: configuration.includeLeftHandRoot,
                onChanged: (value) {
                  if (value != null) {
                    onConfigurationChanged(
                      configuration.copyWith(includeLeftHandRoot: value),
                    );
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Settings widget for chord progressions practice mode.
class ChordProgressionsSettingsView extends StatelessWidget {
  /// Creates a chord progressions settings view.
  const ChordProgressionsSettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    required this.getChordProgressionString,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  /// String getter for chord progression types.
  final String Function(ChordProgression?) getChordProgressionString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<ChordProgression>(
          key: ValueKey("chordProgression_${configuration.chordProgressionId}"),
          initialValue: configuration.chordProgressionId != null
              ? ChordProgressionLibrary.getProgressionByName(
                  configuration.chordProgressionId!,
                )
              : null,
          decoration: const InputDecoration(
            labelText: "Chord Progression",
            border: OutlineInputBorder(),
          ),
          items: ChordProgressionLibrary.getAllProgressions().map((
            progression,
          ) {
            return DropdownMenuItem(
              value: progression,
              child: Text(getChordProgressionString(progression)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigurationChanged(
                configuration.copyWith(
                  chordProgressionId: Field.set(value.name),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Settings widget for dominant cadence practice mode.
class DominantCadenceSettingsView extends StatelessWidget {
  /// Creates a dominant cadence settings view.
  const DominantCadenceSettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        Semantics(
          label: "Include dominant seventh chord (V7→Imaj7) instead of triads",
          child: Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              title: const Text("Include 7th Chords (V7→Imaj7)"),
              subtitle: const Text("Dominant 7th resolves to major 7th tonic"),
              value: configuration.includeSeventhChords,
              onChanged: (value) {
                if (value != null) {
                  onConfigurationChanged(
                    configuration.copyWith(includeSeventhChords: value),
                  );
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings widget for chords by type practice mode.
class ChordsByTypeSettingsView extends StatelessWidget {
  /// Creates a chords by type settings view.
  const ChordsByTypeSettingsView({
    required this.configuration,
    required this.onConfigurationChanged,
    super.key,
  });

  /// Current exercise configuration.
  final ExerciseConfiguration configuration;

  /// Callback when configuration changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Spacing.sm),
        Semantics(
          label: "Include 1st and 2nd inversions in chord exercises",
          child: Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              title: const Text("Include Inversions"),
              subtitle: const Text("Add 1st and 2nd inversions"),
              value: configuration.includeInversions,
              onChanged: (value) {
                if (value != null) {
                  onConfigurationChanged(
                    configuration.copyWith(includeInversions: value),
                  );
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
      ],
    );
  }
}
