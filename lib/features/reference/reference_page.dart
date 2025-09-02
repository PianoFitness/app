import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/piano_accessibility_utils.dart";

/// Reference page for viewing scales and chords on the piano.
///
/// This page allows students to select scales or chords and see the notes
/// highlighted on an interactive piano keyboard. It follows the MVVM pattern
/// with the logic handled by ReferencePageViewModel.
class ReferencePage extends StatefulWidget {
  /// Creates the reference page.
  const ReferencePage({super.key});

  @override
  State<ReferencePage> createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage> {
  late final ReferencePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReferencePageViewModel();
    // Activate the reference display once during initialization
    _viewModel.activateReferenceDisplay();
  }

  @override
  void dispose() {
    // Clear reference display when page is disposed
    _viewModel.deactivateReferenceDisplay();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ...existing code...

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Reference Mode",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, child) {
                              return SegmentedButton<ReferenceMode>(
                                key: const Key("reference_mode_selector"),
                                segments: const [
                                  ButtonSegment<ReferenceMode>(
                                    value: ReferenceMode.scales,
                                    label: Text(
                                      "Scales",
                                      key: Key("scales_mode_button"),
                                    ),
                                    icon: Icon(Icons.keyboard_arrow_up),
                                  ),
                                  ButtonSegment<ReferenceMode>(
                                    value: ReferenceMode.chordTypes,
                                    label: Text(
                                      "Chord Types",
                                      key: Key("chord_types_mode_button"),
                                    ),
                                    icon: Icon(Icons.piano),
                                  ),
                                ],
                                selected: {_viewModel.selectedMode},
                                onSelectionChanged:
                                    (Set<ReferenceMode> selection) {
                                      _viewModel.setSelectedMode(
                                        selection.first,
                                      );
                                    },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selection Controls
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        return _buildSelectionControls();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Piano Display
          Expanded(
            child: Builder(
              builder: (context) {
                final fixed49KeyRange = PianoRangeUtils.standard49KeyRange;
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

                return ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    // Convert local highlighted MIDI notes to NotePositions using shared utility
                    final localHighlightedPositions = _viewModel
                        .localHighlightedNotes
                        .map<NotePosition?>(NoteUtils.midiNumberToNotePosition)
                        .where((position) => position != null)
                        .cast<NotePosition>()
                        .toList();

                    return PianoAccessibilityUtils.createAccessiblePianoWrapper(
                      highlightedNotes: localHighlightedPositions,
                      semanticLabel: "Reference mode piano keyboard",
                      child: InteractivePiano(
                        key: const Key("reference_piano"),
                        highlightedNotes: localHighlightedPositions,
                        keyWidth: dynamicKeyWidth.clamp(
                          PianoRangeUtils.minKeyWidth,
                          PianoRangeUtils.maxKeyWidth,
                        ),
                        noteRange: fixed49KeyRange,
                        onNotePositionTapped: (position) {
                          final midiNote = NoteUtils.convertNotePositionToMidi(
                            position,
                          );
                          _viewModel.playNote(midiNote);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    if (_viewModel.selectedMode == ReferenceMode.scales) {
      return _buildScaleControls();
    } else {
      return _buildChordControls();
    }
  }

  Widget _buildScaleControls() {
    return Column(
      children: [
        // Key Selection
        Container(
          key: const Key("scales_key_selection"),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Key",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scales.Key.values.map((scales.Key key) {
                  final isSelected = _viewModel.selectedKey == key;
                  return FilterChip(
                    key: Key("scales_key_${key.name}"),
                    label: Text(key.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedKey(key);
                      }
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Scale Type Selection
        Container(
          key: const Key("scales_type_selection"),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Scale Type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scales.ScaleType.values.map((scales.ScaleType type) {
                  final isSelected = _viewModel.selectedScaleType == type;
                  return FilterChip(
                    key: Key("scales_type_${type.name}"),
                    label: Text(_getScaleTypeName(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedScaleType(type);
                      }
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChordControls() {
    return Column(
      children: [
        // Key Selection
        Container(
          key: const Key("chords_root_selection"),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Root Note",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scales.Key.values.map((scales.Key key) {
                  final isSelected = _viewModel.selectedKey == key;
                  return FilterChip(
                    key: Key("chords_root_${key.name}"),
                    label: Text(key.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedKey(key);
                      }
                    },
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chord Type Selection
        Container(
          key: const Key("chords_type_selection"),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chord Type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ChordType.values.map((type) {
                  final isSelected = _viewModel.selectedChordType == type;
                  return FilterChip(
                    key: Key("chords_type_${type.name}"),
                    label: Text(_getChordTypeName(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedChordType(type);
                      }
                    },
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chord Inversion Selection
        Container(
          key: const Key("chords_inversion_selection"),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Inversion",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ChordInversion.values.map((inversion) {
                  final isSelected =
                      _viewModel.selectedChordInversion == inversion;
                  return FilterChip(
                    key: Key("chords_inversion_${inversion.name}"),
                    label: Text(_getChordInversionName(inversion)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedChordInversion(inversion);
                      }
                    },
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getScaleTypeName(scales.ScaleType type) {
    switch (type) {
      case scales.ScaleType.major:
        return "Major";
      case scales.ScaleType.minor:
        return "Minor";
      case scales.ScaleType.dorian:
        return "Dorian";
      case scales.ScaleType.phrygian:
        return "Phrygian";
      case scales.ScaleType.lydian:
        return "Lydian";
      case scales.ScaleType.mixolydian:
        return "Mixolydian";
      case scales.ScaleType.aeolian:
        return "Aeolian";
      case scales.ScaleType.locrian:
        return "Locrian";
    }
  }

  String _getChordTypeName(ChordType type) {
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

  String _getChordInversionName(ChordInversion inversion) {
    switch (inversion) {
      case ChordInversion.root:
        return "Root Position";
      case ChordInversion.first:
        return "1st Inversion";
      case ChordInversion.second:
        return "2nd Inversion";
    }
  }
}
