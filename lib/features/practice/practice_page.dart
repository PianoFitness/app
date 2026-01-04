import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/practice/practice_constants.dart";
import "package:piano_fitness/features/practice/practice_page_view_model.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:piano_fitness/shared/models/chord_progression_type.dart";
import "package:piano_fitness/shared/models/practice_mode.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_range_utils.dart";
import "package:piano_fitness/shared/widgets/practice_progress_display.dart";
import "package:piano_fitness/shared/widgets/practice_settings_panel.dart";
import "package:piano_fitness/shared/utils/piano_accessibility_utils.dart";
import "package:piano_fitness/shared/theme/semantic_colors.dart";

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
  /// The [initialChordProgression] pre-selects a chord progression when mode is chordProgressions.
  const PracticePage({
    super.key,
    this.initialMode = PracticeMode.scales,
    this.midiChannel = 0,
    this.initialChordProgression,
  });

  /// The initial practice mode to display when the page loads.
  final PracticeMode initialMode;

  /// The MIDI channel to use for input and output (0-15).
  final int midiChannel;

  /// The initial chord progression to pre-select (optional).
  final ChordProgression? initialChordProgression;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PracticePageViewModel(initialChannel: widget.midiChannel);

    // Initialize the ViewModel with callbacks and local MIDI state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initializePracticeSession(
        onExerciseCompleted: _completeExercise,
        onHighlightedNotesChanged: (notes) {
          setState(() {
            // Notes are automatically updated in ViewModel
          });
        },
        initialMode: widget.initialMode,
        initialChordProgression: widget.initialChordProgression,
      );
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _completeExercise() {
    // Use a custom overlay approach to show completion message at top
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + Spacing.lg,
        left: Spacing.lg,
        right: Spacing.lg,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: PracticeUIConstants.completionOverlayPadding,
            decoration: BoxDecoration(
              color: context.semanticColors.success,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: ShadowConfig.subtleBlur,
                  offset: ShadowConfig.subtleOffset,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  "Exercise completed! Well done!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the overlay after configured duration
    Future.delayed(AnimationDurations.snackbar, () {
      overlayEntry.remove();
    });
  }

  void _resetPractice() {
    _viewModel.resetPractice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("practice_page_scaffold"),
      appBar: AppBar(
        title: const Text("Practice Session"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          key: const Key("practice_back_button"),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Back to Practice Hub",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.lg),
                    AnimatedBuilder(
                      animation: _viewModel,
                      builder: (context, child) {
                        final session = _viewModel.practiceSession;
                        if (session == null) {
                          return const CircularProgressIndicator();
                        }

                        return PracticeSettingsPanel(
                          key: const Key("practice_settings_panel"),
                          practiceMode: session.practiceMode,
                          selectedKey: session.selectedKey,
                          selectedScaleType: session.selectedScaleType,
                          selectedRootNote: session.selectedRootNote,
                          selectedArpeggioType: session.selectedArpeggioType,
                          selectedArpeggioOctaves:
                              session.selectedArpeggioOctaves,
                          selectedChordProgression:
                              session.selectedChordProgression,
                          selectedChordType: session.selectedChordType,
                          includeInversions: session.includeInversions,
                          includeSeventhChords: session.includeSeventhChords,
                          selectedHandSelection: session.selectedHandSelection,
                          autoProgressKeys: session.autoProgressKeys,
                          practiceActive: session.practiceActive,
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
                          onChordProgressionChanged: (progression) {
                            _viewModel.setSelectedChordProgression(progression);
                          },
                          onChordTypeChanged: (type) {
                            _viewModel.setSelectedChordType(type);
                          },
                          onIncludeInversionsChanged: (include) {
                            _viewModel.setIncludeInversions(include);
                          },
                          onIncludeSeventhChordsChanged: (include) {
                            _viewModel.setIncludeSeventhChords(include);
                          },
                          onHandSelectionChanged: (handSelection) {
                            _viewModel.setSelectedHandSelection(handSelection);
                          },
                          onAutoProgressKeysChanged: (enable) {
                            _viewModel.setAutoKeyProgression(enable);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.md),
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
                          currentExercise: session.currentExercise,
                          currentStepIndex: session.currentStepIndex,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                // Calculate highlighted notes for display using local state
                final highlightedNotes = _viewModel
                    .getDisplayHighlightedNotes();

                // Calculate 49-key range centered around practice exercise
                final practiceRange = _viewModel.calculatePracticeRange();

                // Calculate dynamic key width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

                return PianoAccessibilityUtils.createAccessiblePianoWrapper(
                  highlightedNotes: highlightedNotes,
                  mode: PianoMode.practice,
                  semanticLabel: AccessibilityLabels.piano.keyboardLabel(
                    PianoMode.practice,
                  ),
                  child: InteractivePiano(
                    key: const Key("practice_interactive_piano"),
                    highlightedNotes: highlightedNotes,
                    keyWidth: dynamicKeyWidth.clamp(
                      PianoRangeUtils.minKeyWidth,
                      PianoRangeUtils.maxKeyWidth,
                    ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
