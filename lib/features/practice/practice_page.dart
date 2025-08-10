import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:piano_fitness/shared/widgets/midi_status_indicator.dart";
import "package:piano_fitness/shared/widgets/practice_progress_display.dart";
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";
import "package:provider/provider.dart";

/// A comprehensive piano practice page with guided exercises and real-time feedback.
///
/// This page provides structured practice sessions for scales, chords, and arpeggios
/// with MIDI input support, visual feedback, and progress tracking. It uses MVVM
/// architecture with PracticePageViewModel for business logic separation.
class PracticePage extends StatefulWidget {
  /// Creates a new practice page with optional initial configuration.
  ///
  /// The [initialMode] determines which type of practice to start with.
  /// The [midiChannel] sets the MIDI channel for input/output operations.
  const PracticePage({
    super.key,
    this.initialMode = PracticeMode.scales,
    this.midiChannel = 0,
  });

  /// The initial practice mode to display when the page loads.
  final PracticeMode initialMode;

  /// The MIDI channel to use for input and output (0-15).
  final int midiChannel;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PracticePageViewModel(
      initialChannel: widget.midiChannel,
    );

    // Initialize the ViewModel with callbacks and MIDI state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final midiState = Provider.of<MidiState>(context, listen: false);
      _viewModel
        ..setMidiState(midiState)
        ..initializePracticeSession(
          onExerciseCompleted: _completeExercise,
          onHighlightedNotesChanged: (notes) {
            setState(() {
              // Notes are automatically updated in ViewModel
            });
          },
          initialMode: widget.initialMode,
        );
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _completeExercise() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exercise completed! Well done!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startPractice() {
    _viewModel.startPractice();
  }

  void _resetPractice() {
    _viewModel.resetPractice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('practice_page_scaffold'),
      appBar: AppBar(
        key: const Key('practice_page_app_bar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          key: const Key('practice_page_title'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center, 
              key: const Key('practice_page_icon'),
              color: Colors.deepPurple,
              semanticLabel: 'Piano fitness icon',
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Piano Practice page title',
              child: const Text("Piano Practice"),
            ),
          ],
        ),
        actions: const [MidiStatusIndicator(key: Key('midi_status_indicator'))],
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
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _viewModel,
                      builder: (context, child) {
                        final session = _viewModel.practiceSession;
                        if (session == null) {
                          return const CircularProgressIndicator();
                        }

                        return PracticeSettingsPanel(
                          key: const Key('practice_settings_panel'),
                          practiceMode: session.practiceMode,
                          selectedKey: session.selectedKey,
                          selectedScaleType: session.selectedScaleType,
                          selectedRootNote: session.selectedRootNote,
                          selectedArpeggioType: session.selectedArpeggioType,
                          selectedArpeggioOctaves:
                              session.selectedArpeggioOctaves,
                          practiceActive: session.practiceActive,
                          onStartPractice: _startPractice,
                          onResetPractice: _resetPractice,
                          onPracticeModeChanged: (mode) {
                            _viewModel.setPracticeMode(mode);
                          },
                          onKeyChanged: (key) {
                            _viewModel.setSelectedKey(key);
                          },
                          onScaleTypeChanged: (type) {
                            _viewModel.setSelectedScaleType(type);
                          },
                          onRootNoteChanged: (rootNote) {
                            _viewModel.setSelectedRootNote(rootNote);
                          },
                          onArpeggioTypeChanged: (type) {
                            _viewModel.setSelectedArpeggioType(type);
                          },
                          onArpeggioOctavesChanged: (octaves) {
                            _viewModel.setSelectedArpeggioOctaves(octaves);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _viewModel,
                      builder: (context, child) {
                        final session = _viewModel.practiceSession;
                        if (session == null) {
                          return const SizedBox.shrink();
                        }

                        return PracticeProgressDisplay(
                          practiceMode: session.practiceMode,
                          practiceActive: session.practiceActive,
                          currentSequence: session.currentSequence,
                          currentNoteIndex: session.currentNoteIndex,
                          currentChordIndex: session.currentChordIndex,
                          currentChordProgression:
                              session.currentChordProgression,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MidiState>(
              builder: (context, midiState, child) {
                return AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    // Calculate highlighted notes for display
                    final highlightedNotes = _viewModel
                        .getDisplayHighlightedNotes(midiState);

                    // Calculate 49-key range centered around practice exercise
                    final practiceRange = _viewModel.calculatePracticeRange();

                    // Calculate dynamic key width based on screen width
                    final screenWidth = MediaQuery.of(context).size.width;
                    final dynamicKeyWidth =
                        PianoRangeUtils.calculateScreenBasedKeyWidth(
                          screenWidth,
                        );

                    return InteractivePiano(
                      key: const Key('practice_interactive_piano'),
                      highlightedNotes: highlightedNotes,
                      keyWidth: dynamicKeyWidth,
                      noteRange: practiceRange,
                      onNotePositionTapped: (position) async {
                        final midiNote = NoteUtils.convertNotePositionToMidi(
                          position,
                        );
                        await _viewModel.playVirtualNote(
                          midiNote,
                          mounted: mounted,
                        );
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
}
