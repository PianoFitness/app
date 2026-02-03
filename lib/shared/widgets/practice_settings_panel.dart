import "dart:math" as math;

import "package:flutter/material.dart";
import "package:piano_fitness/domain/constants/practice_constants.dart";
import "package:piano_fitness/domain/models/music/chord_progression_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as music;

/// A comprehensive settings panel for configuring piano practice exercises.
///
/// This widget provides controls for selecting practice modes (scales, chords, arpeggios),
/// musical keys, scale types, and other exercise-specific parameters. It adapts its
/// interface based on the selected practice mode to show relevant options.
class PracticeSettingsPanel extends StatelessWidget {
  /// Creates a practice settings panel with configuration options for practice sessions.
  ///
  /// All parameters are required to ensure the panel can properly display
  /// current settings and handle user interactions.
  const PracticeSettingsPanel({
    required this.practiceMode,
    required this.selectedKey,
    required this.selectedScaleType,
    required this.selectedRootNote,
    required this.selectedArpeggioType,
    required this.selectedArpeggioOctaves,
    required this.selectedChordProgression,
    required this.selectedChordType,
    required this.includeInversions,
    required this.includeSeventhChords,
    required this.selectedHandSelection,
    required this.autoProgressKeys,
    required this.practiceActive,
    required this.onResetPractice,
    required this.onPracticeModeChanged,
    required this.onKeyChanged,
    required this.onScaleTypeChanged,
    required this.onRootNoteChanged,
    required this.onArpeggioTypeChanged,
    required this.onArpeggioOctavesChanged,
    required this.onChordProgressionChanged,
    required this.onChordTypeChanged,
    required this.onIncludeInversionsChanged,
    required this.onIncludeSeventhChordsChanged,
    required this.onHandSelectionChanged,
    required this.onAutoProgressKeysChanged,
    super.key,
  });

  /// Key for the main panel container
  static const Key panelKey = Key("practiceSettingsPanel");

  /// Key for the practice status container
  static const Key statusKey = Key("practiceStatusContainer");

  Widget _buildRootNoteDropdown() {
    return DropdownButtonFormField<MusicalNote>(
      initialValue: selectedRootNote,
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
          onRootNoteChanged(value);
        }
      },
    );
  }

  Widget _buildChordTypeDropdown() {
    return DropdownButtonFormField<ChordType>(
      initialValue: selectedChordType,
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
          onChordTypeChanged(value);
        }
      },
    );
  }

  Widget _buildKeyDropdown() {
    return DropdownButtonFormField<music.Key>(
      initialValue: selectedKey,
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
          onKeyChanged(value);
        }
      },
    );
  }

  Widget _buildSecondarySelector(BuildContext context) {
    switch (practiceMode) {
      case PracticeMode.arpeggios:
        return _buildRootNoteDropdown();
      case PracticeMode.chordsByType:
        return _buildChordTypeDropdown();
      default:
        return _buildKeyDropdown();
    }
  }

  /// The currently selected practice mode (scales, chords, or arpeggios).
  final PracticeMode practiceMode;

  /// The selected musical key for scale and chord exercises.
  final music.Key selectedKey;

  /// The selected scale type (major, minor, modal, etc.) for scale exercises.
  final music.ScaleType selectedScaleType;

  /// The selected root note for arpeggio exercises.
  final MusicalNote selectedRootNote;

  /// The selected arpeggio type (major, minor, diminished, etc.).
  final ArpeggioType selectedArpeggioType;

  /// The selected octave range for arpeggio exercises.
  final ArpeggioOctaves selectedArpeggioOctaves;

  /// The selected chord progression type for chord progression exercises.
  final ChordProgression? selectedChordProgression;

  /// The selected chord type for chord type exercises.
  final ChordType selectedChordType;

  /// Whether to include inversions in chord type exercises.
  final bool includeInversions;

  /// Whether to include seventh chords in chord-by-key exercises.
  final bool includeSeventhChords;

  /// The selected hand for practice exercises.
  final HandSelection selectedHandSelection;

  /// Whether to automatically progress through keys following the circle of fifths.
  final bool autoProgressKeys;

  /// Whether a practice session is currently active.
  final bool practiceActive;

  /// Callback fired when the user taps the Reset button.
  final VoidCallback onResetPractice;

  /// Callback fired when the user changes the practice mode.
  final ValueChanged<PracticeMode> onPracticeModeChanged;

  /// Callback fired when the user changes the musical key.
  final ValueChanged<music.Key> onKeyChanged;

  /// Callback fired when the user changes the scale type.
  final ValueChanged<music.ScaleType> onScaleTypeChanged;

  /// Callback fired when the user changes the root note for arpeggios.
  final ValueChanged<MusicalNote> onRootNoteChanged;

  /// Callback fired when the user changes the arpeggio type.
  final ValueChanged<ArpeggioType> onArpeggioTypeChanged;

  /// Callback fired when the user changes the arpeggio octave range.
  final ValueChanged<ArpeggioOctaves> onArpeggioOctavesChanged;

  /// Callback fired when the user changes the chord progression type.
  final ValueChanged<ChordProgression> onChordProgressionChanged;

  /// Callback fired when the user changes the chord type.
  final ValueChanged<ChordType> onChordTypeChanged;

  /// Callback fired when the user changes the inversion setting.
  final ValueChanged<bool> onIncludeInversionsChanged;

  /// Callback fired when the user changes the seventh chord setting.
  final ValueChanged<bool> onIncludeSeventhChordsChanged;

  /// Callback fired when the user changes the hand selection.
  final ValueChanged<HandSelection> onHandSelectionChanged;

  /// Callback fired when the user toggles auto key progression.
  final ValueChanged<bool> onAutoProgressKeysChanged;

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
      case PracticeMode.chordProgressions:
        return "Chord Progressions";
    }
  }

  /// Returns true if the current practice mode supports key-based progression.
  ///
  /// Auto key progression is available for modes that use the [selectedKey] field:
  /// - Scales (practice scales in different keys)
  /// - Chords by Key (practice diatonic chords in different keys)
  /// - Chord Progressions (practice progressions in different keys)
  /// - Arpeggios (practice arpeggios starting from different root notes)
  ///
  /// Modes that use chord types (chords by type) are excluded.
  bool _supportsKeyProgression() {
    return practiceMode == PracticeMode.scales ||
        practiceMode == PracticeMode.chordsByKey ||
        practiceMode == PracticeMode.chordProgressions ||
        practiceMode == PracticeMode.arpeggios;
  }

  String _getKeyString(music.Key key) {
    return key.fullDisplayName;
  }

  String _getScaleTypeString(music.ScaleType type) {
    switch (type) {
      case music.ScaleType.major:
        return "Major (Ionian)";
      case music.ScaleType.minor:
        return "Natural Minor";
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
    }
  }

  String _getChordProgressionString(ChordProgression? progression) {
    return progression?.displayName ?? "Select Progression";
  }

  String _getChordTypeString(ChordType type) {
    return type.shortName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: panelKey,
      padding: const EdgeInsets.all(Spacing.lg),
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
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PracticeMode>(
                  initialValue: practiceMode,
                  decoration: const InputDecoration(
                    labelText: "Practice Mode",
                    border: OutlineInputBorder(),
                  ),
                  items: PracticeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getPracticeModeString(mode)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPracticeModeChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: _buildSecondarySelector(context)),
            ],
          ),
          // Auto key progression toggle (shown only for key-based modes)
          if (_supportsKeyProgression()) ...[
            const SizedBox(height: Spacing.sm),
            SwitchListTile(
              title: const Text("Auto-progress through keys"),
              subtitle: const Text(
                "Follow circle of fifths after each exercise",
              ),
              value: autoProgressKeys,
              onChanged: onAutoProgressKeysChanged,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
              ),
            ),
          ],
          const SizedBox(height: Spacing.sm),
          SegmentedButton<HandSelection>(
            segments: [
              ButtonSegment(
                value: HandSelection.left,
                label: const Text("Left Hand"),
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: const Icon(
                    Icons.back_hand,
                    size: ComponentDimensions.iconSizeSmall,
                  ),
                ),
              ),
              const ButtonSegment(
                value: HandSelection.right,
                label: Text("Right Hand"),
                icon: Icon(
                  Icons.back_hand,
                  size: ComponentDimensions.iconSizeSmall,
                ),
              ),
              ButtonSegment(
                value: HandSelection.both,
                label: const Text("Both Hands"),
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: const Icon(
                        Icons.back_hand,
                        size: ComponentDimensions.iconSizeSmall,
                      ),
                    ),
                    const SizedBox(width: PracticeUIConstants.handIconSpacing),
                    const Icon(
                      Icons.back_hand,
                      size: ComponentDimensions.iconSizeSmall,
                    ),
                  ],
                ),
              ),
            ],
            selected: {selectedHandSelection},
            onSelectionChanged: (Set<HandSelection> selection) {
              onHandSelectionChanged(selection.first);
            },
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          if (practiceMode == PracticeMode.scales) ...[
            const SizedBox(height: Spacing.sm),
            DropdownButtonFormField<music.ScaleType>(
              initialValue: selectedScaleType,
              decoration: const InputDecoration(
                labelText: "Scale Type",
                border: OutlineInputBorder(),
              ),
              items: music.ScaleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getScaleTypeString(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onScaleTypeChanged(value);
                }
              },
            ),
          ],
          if (practiceMode == PracticeMode.arpeggios) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ArpeggioType>(
                    initialValue: selectedArpeggioType,
                    decoration: const InputDecoration(
                      labelText: "Arpeggio Type",
                      border: OutlineInputBorder(),
                    ),
                    items: ArpeggioType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getArpeggioTypeString(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onArpeggioTypeChanged(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: DropdownButtonFormField<ArpeggioOctaves>(
                    initialValue: selectedArpeggioOctaves,
                    decoration: const InputDecoration(
                      labelText: "Octaves",
                      border: OutlineInputBorder(),
                    ),
                    items: ArpeggioOctaves.values.map((octaves) {
                      return DropdownMenuItem(
                        value: octaves,
                        child: Text(_getArpeggioOctavesString(octaves)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onArpeggioOctavesChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
          if (practiceMode == PracticeMode.chordProgressions) ...[
            const SizedBox(height: Spacing.sm),
            DropdownButtonFormField<ChordProgression>(
              initialValue: selectedChordProgression,
              decoration: const InputDecoration(
                labelText: "Chord Progression",
                border: OutlineInputBorder(),
              ),
              items: ChordProgressionLibrary.getAllProgressions().map((
                progression,
              ) {
                return DropdownMenuItem(
                  value: progression,
                  child: Text(_getChordProgressionString(progression)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChordProgressionChanged(value);
                }
              },
            ),
          ],
          if (practiceMode == PracticeMode.chordsByKey) ...[
            const SizedBox(height: Spacing.sm),
            Semantics(
              label: "Include seventh chords in chord-by-key exercises",
              child: CheckboxListTile(
                title: const Text("Include Seventh Chords"),
                subtitle: const Text("Add 7th note to triads"),
                value: includeSeventhChords,
                onChanged: (value) {
                  if (value != null) {
                    onIncludeSeventhChordsChanged(value);
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
          if (practiceMode == PracticeMode.chordsByType) ...[
            const SizedBox(height: Spacing.sm),
            Semantics(
              label: "Include 1st and 2nd inversions in chord exercises",
              child: CheckboxListTile(
                title: const Text("Include Inversions"),
                subtitle: const Text("Add 1st and 2nd inversions"),
                value: includeInversions,
                onChanged: (value) {
                  if (value != null) {
                    onIncludeInversionsChanged(value);
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
          const SizedBox(height: Spacing.md),
          // Show practice status and reset button
          Column(
            children: [
              Semantics(
                liveRegion: true,
                label: practiceActive
                    ? "Practice Active - Keep Playing!"
                    : "Ready - Play Any Note to Start",
                child: Container(
                  key: statusKey,
                  padding: PracticeUIConstants.statusContainerPadding,
                  decoration: BoxDecoration(
                    color: practiceActive
                        ? colorScheme.primaryContainer
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    border: Border.all(
                      color: practiceActive
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        practiceActive ? Icons.music_note : Icons.piano,
                        color: practiceActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                        size: PracticeUIConstants.statusIconSize,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        practiceActive
                            ? "Practice Active - Keep Playing!"
                            : "Ready - Play Any Note to Start",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: practiceActive
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              ElevatedButton.icon(
                onPressed: onResetPractice,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Exercise"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
