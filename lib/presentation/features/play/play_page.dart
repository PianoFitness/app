import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/play/play_page_view_model.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/presentation/utils/piano_accessibility_utils.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";

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
        midiCoordinator: context.read<MidiCoordinator>(),
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: Row(
              key: const Key("playPageTitle"),
              children: [
                Icon(
                  viewModel.midiState.hasRecentActivity
                      ? Icons.graphic_eq
                      : Icons.touch_app_outlined,
                  size: ComponentDimensions.iconSizeMedium,
                  color: viewModel.midiState.hasRecentActivity
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    viewModel.midiState.hasRecentActivity
                        ? "MIDI active"
                        : "Play with your keyboard or tap the keys",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
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

                final highlightedMidiNotes = viewModel.midiState.activeNotes
                    .toList();
                final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({
                  for (final note in highlightedMidiNotes)
                    note: PianoKeyVisual(fill: colorScheme.primary),
                });

                return PianoAccessibilityUtils.createAccessiblePianoWrapper(
                  highlightedMidiNotes: highlightedMidiNotes,
                  mode: PianoMode.play,
                  semanticLabel: AccessibilityLabels.piano.keyboardLabel(
                    PianoMode.play,
                  ),
                  child: PianoKeyboard(
                    range: fixed49KeyRange,
                    keyVisuals: keyVisuals,
                    noteLabelMode: NoteLabelMode.name,
                    keyWidth: dynamicKeyWidth.clamp(
                      PianoRangeUtils.minKeyWidth,
                      PianoRangeUtils.maxKeyWidth,
                    ),
                    onKeyDown: (midiNote) {
                      viewModel.onKeyDown(midiNote).catchError((Object e) {
                        debugPrint("Error playing note: $e");
                      });
                    },
                    onKeyUp: (midiNote) {
                      viewModel.onKeyUp(midiNote).catchError((Object e) {
                        debugPrint("Error releasing note: $e");
                      });
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
