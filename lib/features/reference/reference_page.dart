import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/widgets/midi_controls.dart";
import "package:provider/provider.dart";

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final midiState = Provider.of<MidiState>(context, listen: false);
        _viewModel.setMidiState(midiState);
      } catch (e) {
        // Handle case where MidiState provider is not available
        // This allows the page to render gracefully in test environments
        debugPrint("MidiState provider not found: $e");
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.library_books, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text("Reference"),
          ],
        ),
        actions: const [MidiControls()],
      ),
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
                                segments: const [
                                  ButtonSegment<ReferenceMode>(
                                    value: ReferenceMode.scales,
                                    label: Text("Scales"),
                                    icon: Icon(Icons.keyboard_arrow_up),
                                  ),
                                  ButtonSegment<ReferenceMode>(
                                    value: ReferenceMode.chords,
                                    label: Text("Chords"),
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
                // Check if MidiState provider is available
                MidiState? midiState;
                try {
                  midiState = Provider.of<MidiState>(context);
                } catch (e) {
                  // Provider not available, use default behavior
                  midiState = null;
                }

                final fixed49KeyRange = PianoRangeUtils.standard49KeyRange;
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

                return ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    return InteractivePiano(
                      highlightedNotes:
                          midiState?.highlightedNotePositions ??
                          const <NotePosition>[],
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
