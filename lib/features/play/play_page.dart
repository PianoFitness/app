import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/features/play/play_constants.dart";
import "package:piano_fitness/features/play/play_page_view_model.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/presentation/utils/piano_accessibility_utils.dart";

/// The main page of the Piano Fitness application.
///
/// This page serves as the home screen and primary interface for piano interaction.
/// It provides access to practice modes, MIDI settings, and displays an interactive
/// piano keyboard for both MIDI input and virtual note playing.
class PlayPage extends StatelessWidget {
  /// Creates the main play page with optional MIDI channel configuration.
  ///
  /// The [midiChannel] parameter sets the default MIDI channel for input/output.
  const PlayPage({super.key, this.midiChannel = 0});

  /// The MIDI channel to use for input and output operations (0-15).
  final int midiChannel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayPageViewModel(
        midiRepository: context.read<IMidiRepository>(),
        midiState: context.read<MidiState>(),
        initialChannel: midiChannel,
      ),
      child: const _PlayPageView(),
    );
  }
}

/// Internal view widget for PlayPage content.
class _PlayPageView extends StatelessWidget {
  const _PlayPageView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlayPageViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
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
                    // Educational Content Area
                    Container(
                      padding: const EdgeInsets.all(Spacing.lg),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.piano,
                            size: ComponentDimensions.iconSizeXLarge,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            "Free Play Mode",
                            key: const Key("playPageTitle"),
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ) ??
                                TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            "Explore and play freely with the interactive piano. "
                            "Connect a MIDI keyboard for enhanced experience or use the virtual keys below.",
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ) ??
                                TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.md),
                          Container(
                            padding: PlayUIConstants.infoBannerPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.small,
                              ),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: ComponentDimensions.iconSizeSmall,
                                  color: colorScheme.onSurface,
                                ),
                                const SizedBox(width: Spacing.sm),
                                Flexible(
                                  child: Text(
                                    "Looking for structured practice? Visit the Practice tab!",
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface,
                                        ) ??
                                        TextStyle(color: colorScheme.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: viewModel,
              builder: (context, child) {
                // Define a fixed 49-key range for consistent layout
                final fixed49KeyRange = PianoRangeUtils.standard49KeyRange;

                // Calculate dynamic key width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(screenWidth);

                return PianoAccessibilityUtils.createAccessiblePianoWrapper(
                  highlightedNotes:
                      viewModel.midiState.highlightedNotePositions,
                  mode: PianoMode.play,
                  semanticLabel: AccessibilityLabels.piano.keyboardLabel(
                    PianoMode.play,
                  ),
                  child: InteractivePiano(
                    highlightedNotes:
                        viewModel.midiState.highlightedNotePositions,
                    keyWidth: dynamicKeyWidth.clamp(
                      PianoRangeUtils.minKeyWidth,
                      PianoRangeUtils.maxKeyWidth,
                    ),
                    noteRange: fixed49KeyRange,
                    onNotePositionTapped: (position) {
                      final midiNote = NoteUtils.convertNotePositionToMidi(
                        position,
                      );
                      viewModel.playVirtualNote(midiNote);
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
