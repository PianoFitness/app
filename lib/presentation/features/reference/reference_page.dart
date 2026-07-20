import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/features/reference/widgets/reference_config_row.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/utils/piano_key_utils.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/presentation/utils/piano_accessibility_utils.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";

/// Reference page for viewing scales and chords on the piano.
///
/// This page allows students to select scales or chords and see the notes
/// highlighted on an interactive piano keyboard. It follows the MVVM pattern
/// with the logic handled by ReferencePageViewModel.
class ReferencePage extends StatelessWidget {
  /// Creates the reference page.
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = ReferencePageViewModel(
          midiCoordinator: context.read<MidiCoordinator>(),
          midiRepository: context.read<IMidiRepository>(),
          midiState: context.read<MidiState>(),
        );
        // Activate the reference display once during initialization
        viewModel.activateReferenceDisplay();
        return viewModel;
      },
      child: Consumer<ReferencePageViewModel>(
        builder: (context, viewModel, child) {
          return _buildContent(context, viewModel);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReferencePageViewModel viewModel) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, child) => ReferenceConfigRow(
                  selectedMode: viewModel.selectedMode,
                  onModeChanged: viewModel.setSelectedMode,
                  selectedKey: viewModel.selectedKey,
                  onKeyChanged: viewModel.setSelectedKey,
                  selectedScaleType: viewModel.selectedScaleType,
                  onScaleTypeChanged: viewModel.setSelectedScaleType,
                  selectedChordType: viewModel.selectedChordType,
                  onChordTypeChanged: viewModel.setSelectedChordType,
                  selectedChordInversion: viewModel.selectedChordInversion,
                  onChordInversionChanged: viewModel.setSelectedChordInversion,
                ),
              ),
            ),
          ),

          // Piano Display
          Expanded(
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;

                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, child) {
                    final highlightedMidiNotes = viewModel.localHighlightedNotes
                        .map((note) => note.value)
                        .toList();
                    final range = PianoRangeUtils.calculateReferenceRange(
                      highlightedMidiNotes,
                      fallbackRange: PianoRangeUtils.standard49KeyRange,
                    );
                    final whiteKeyCount = getWhiteKeysInRange(
                      range.fromMidi,
                      range.toMidi,
                    ).length;
                    final dynamicKeyWidth =
                        PianoRangeUtils.calculateScreenBasedKeyWidth(
                          screenWidth,
                          keyCount: whiteKeyCount,
                        );
                    final colorScheme = Theme.of(context).colorScheme;
                    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({
                      for (final note in highlightedMidiNotes)
                        note: PianoKeyVisual(fill: colorScheme.primary),
                    });

                    return PianoAccessibilityUtils.createAccessiblePianoWrapper(
                      highlightedMidiNotes: highlightedMidiNotes,
                      mode: PianoMode.reference,
                      semanticLabel: "Reference mode piano keyboard",
                      child: PianoKeyboard(
                        key: const Key("reference_piano"),
                        range: range,
                        keyVisuals: keyVisuals,
                        noteLabelMode: NoteLabelMode.name,
                        keyWidth: dynamicKeyWidth.clamp(
                          PianoRangeUtils.minKeyWidth,
                          PianoRangeUtils.maxKeyWidth,
                        ),
                        onKeyDown: viewModel.onKeyDown,
                        onKeyUp: viewModel.onKeyUp,
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
}
