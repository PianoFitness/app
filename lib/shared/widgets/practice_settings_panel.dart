import "package:flutter/material.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/arpeggios.dart";
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as music;

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
    super.key,
  });

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
    switch (type) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "Minor";
      case ChordType.diminished:
        return "Diminished";
      case ChordType.augmented:
        return "Augmented";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 24,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text(
                "Practice Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              const SizedBox(width: 12),
              Expanded(
                child: practiceMode == PracticeMode.arpeggios
                    ? DropdownButtonFormField<MusicalNote>(
                        initialValue: selectedRootNote,
                        decoration: const InputDecoration(
                          labelText: "Root Note",
                          border: OutlineInputBorder(),
                        ),
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
                      )
                    : practiceMode == PracticeMode.chordsByType
                    ? DropdownButtonFormField<ChordType>(
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
                      )
                    : DropdownButtonFormField<music.Key>(
                        initialValue: selectedKey,
                        decoration: const InputDecoration(
                          labelText: "Key",
                          border: OutlineInputBorder(),
                        ),
                        items: music.Key.values.map((key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Text(_getKeyString(key)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onKeyChanged(value);
                          }
                        },
                      ),
              ),
            ],
          ),
          if (practiceMode == PracticeMode.scales) ...[
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
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
            const SizedBox(height: 12),
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
          if (practiceMode == PracticeMode.chordsByType) ...[
            const SizedBox(height: 12),
            CheckboxListTile(
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
          ],
          const SizedBox(height: 16),
          // Show practice status and reset button
          Column(
            children: [
              Semantics(
                liveRegion: true,
                label: practiceActive
                    ? "Practice Active - Keep Playing!"
                    : "Ready - Play Any Note to Start",
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: practiceActive
                        ? Colors.green.shade100
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: practiceActive
                          ? Colors.green.shade300
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        practiceActive ? Icons.music_note : Icons.piano,
                        color: practiceActive
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        practiceActive
                            ? "Practice Active - Keep Playing!"
                            : "Ready - Play Any Note to Start",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: practiceActive
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onResetPractice,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Exercise"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
