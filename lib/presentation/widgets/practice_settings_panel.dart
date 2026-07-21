import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/widgets/practice_settings/practice_mode_settings.dart";
import "package:piano_fitness/presentation/widgets/practice_settings/practice_settings_hand_selector.dart";
import "package:piano_fitness/presentation/widgets/practice_settings/practice_settings_status_control.dart";

/// A comprehensive settings panel for configuring piano practice exercises.
///
/// This widget provides controls for selecting practice modes (scales, chords, arpeggios),
/// musical keys, scale types, and other exercise-specific parameters. It adapts its
/// interface based on the selected practice mode to show relevant options.
class PracticeSettingsPanel extends StatelessWidget {
  /// Creates a practice settings panel with unified exercise configuration.
  ///
  /// The panel adapts its interface based on the practice mode in [configuration]
  /// to show relevant options. When settings change, [onConfigurationChanged] is
  /// called with the updated configuration.
  const PracticeSettingsPanel({
    required this.configuration,
    required this.onConfigurationChanged,
    required this.practiceActive,
    required this.onResetPractice,
    required this.autoProgressKeys,
    required this.onAutoProgressKeysChanged,
    super.key,
  });

  /// Key for the main panel container
  static const Key panelKey = Key("practiceSettingsPanel");

  /// Key for the practice status container
  static const Key statusKey = Key("practiceStatusContainer");

  /// Whether to automatically progress through keys following the circle of fifths.
  final bool autoProgressKeys;

  /// Callback when auto-progress keys setting changes.
  final ValueChanged<bool> onAutoProgressKeysChanged;

  /// The unified exercise configuration containing all practice settings.
  final ExerciseConfiguration configuration;

  /// Callback fired when any configuration setting changes.
  final ValueChanged<ExerciseConfiguration> onConfigurationChanged;

  /// Whether a practice session is currently active.
  final bool practiceActive;

  /// Callback fired when the user taps the Reset button.
  final VoidCallback onResetPractice;

  Widget _buildRootNoteDropdown() {
    return DropdownButtonFormField<MusicalNote>(
      key: ValueKey("rootNote_${configuration.musicalNote}"),
      initialValue: configuration.musicalNote,
      decoration: const InputDecoration(
        labelText: "Root Note",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: MusicalNote.values.map((note) {
        return DropdownMenuItem(
          value: note,
          child: Text(_getRootNoteString(note)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onConfigurationChanged(
            configuration.copyWith(musicalNote: Field.set(value)),
          );
        }
      },
    );
  }

  Widget _buildChordTypeDropdown() {
    return DropdownButtonFormField<ChordType>(
      key: ValueKey("chordType_${configuration.chordType}"),
      initialValue: configuration.chordType,
      decoration: const InputDecoration(
        labelText: "Chord Type",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: ChordType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getChordTypeString(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onConfigurationChanged(
            configuration.copyWith(chordType: Field.set(value)),
          );
        }
      },
    );
  }

  Widget _buildKeyDropdown() {
    return DropdownButtonFormField<music.Key>(
      key: ValueKey("key_${configuration.key}"),
      initialValue: configuration.key,
      decoration: const InputDecoration(
        labelText: "Key",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: music.Key.values.map((key) {
        return DropdownMenuItem(value: key, child: Text(_getKeyString(key)));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onConfigurationChanged(configuration.copyWith(key: Field.set(value)));
        }
      },
    );
  }

  Widget _buildSecondarySelector(BuildContext context) {
    switch (configuration.practiceMode) {
      case PracticeMode.arpeggios:
      case PracticeMode.blockChords:
        return _buildRootNoteDropdown();
      case PracticeMode.chordsByType:
        return _buildChordTypeDropdown();
      default:
        return _buildKeyDropdown();
    }
  }

  String _getPracticeModeString(PracticeMode mode) {
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
      case PracticeMode.dominantCadence:
        return "Dominant Cadence";
    }
  }

  String _getKeyString(music.Key key) {
    return key.displayName;
  }

  String _getScaleTypeString(music.ScaleType type) {
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

  String _getRootNoteString(MusicalNote note) {
    return NoteUtils.noteDisplayName(note, 0).replaceAll("0", "");
  }

  String _getArpeggioTypeString(ArpeggioType type) {
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

  String _getArpeggioOctavesString(ArpeggioOctaves octaves) {
    switch (octaves) {
      case ArpeggioOctaves.one:
        return "1 Octave";
      case ArpeggioOctaves.two:
        return "2 Octaves";
      case ArpeggioOctaves.three:
        return "3 Octaves";
      case ArpeggioOctaves.four:
        return "4 Octaves";
    }
  }

  String _getChordTonePatternString(ChordTonePattern pattern) {
    switch (pattern) {
      case ChordTonePattern.straight:
        return "Straight";
      case ChordTonePattern.rolling:
        return "Rolling";
    }
  }

  String _getChordProgressionString(ChordProgression? progression) {
    return progression?.displayName ?? "Select Progression";
  }

  String _getChordTypeString(ChordType type) {
    return type.shortName;
  }

  bool _supportsKeyProgression() {
    final mode = configuration.practiceMode;
    return mode == PracticeMode.scales ||
        mode == PracticeMode.chordsByKey ||
        mode == PracticeMode.chordProgressions ||
        mode == PracticeMode.dominantCadence;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: panelKey,
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: ComponentDimensions.iconSizeLarge,
                color: colorScheme.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                "Practice Settings",
                style:
                    theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ) ??
                    TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PracticeMode>(
                  key: ValueKey("practiceMode_${configuration.practiceMode}"),
                  initialValue: configuration.practiceMode,
                  decoration: const InputDecoration(
                    labelText: "Practice Mode",
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: PracticeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getPracticeModeString(mode)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onConfigurationChanged(
                        configuration.copyWith(practiceMode: value),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: _buildSecondarySelector(context)),
            ],
          ),
          if (_supportsKeyProgression())
            AutoProgressKeyToggleView(
              autoProgressKeys: autoProgressKeys,
              onAutoProgressKeysChanged: onAutoProgressKeysChanged,
            ),
          const SizedBox(height: Spacing.sm),
          PracticeSettingsHandSelector(
            selectedHand: configuration.handSelection,
            onHandSelected: (HandSelection selection) {
              onConfigurationChanged(
                configuration.copyWith(handSelection: selection),
              );
            },
          ),
          const SizedBox(height: Spacing.sm),

          // Mode-specific settings
          if (configuration.practiceMode == PracticeMode.scales)
            ScalesSettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
              getScaleTypeString: _getScaleTypeString,
            )
          else if (configuration.practiceMode == PracticeMode.chordsByKey)
            ChordsByKeySettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
              getScaleTypeString: _getScaleTypeString,
            )
          else if (configuration.practiceMode == PracticeMode.arpeggios ||
              configuration.practiceMode == PracticeMode.blockChords)
            ArpeggiosSettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
              getArpeggioTypeString: _getArpeggioTypeString,
              getArpeggioOctavesString: _getArpeggioOctavesString,
              getChordTonePatternString: _getChordTonePatternString,
            )
          else if (configuration.practiceMode == PracticeMode.chordProgressions)
            ChordProgressionsSettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
              getChordProgressionString: _getChordProgressionString,
            )
          else if (configuration.practiceMode == PracticeMode.chordsByType)
            ChordsByTypeSettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
            )
          else if (configuration.practiceMode == PracticeMode.dominantCadence)
            DominantCadenceSettingsView(
              configuration: configuration,
              onConfigurationChanged: onConfigurationChanged,
            ),
          const SizedBox(height: Spacing.sm),
          PracticeSettingsStatusControl(
            practiceActive: practiceActive,
            onResetPractice: onResetPractice,
          ),
        ],
      ),
    );
  }
}
