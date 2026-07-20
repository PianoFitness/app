import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/music_theory/chord_inversion_utils.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/utils/piano_key_utils.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/domain/models/music/chord_type.dart";
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
                builder: (context, child) => _buildConfigRow(viewModel),
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

  /// Builds the single, thin configuration row (mode + key/type selectors)
  /// that replaces the previous stack of full-width chip panels, so the
  /// options fit above the piano without scrolling.
  Widget _buildConfigRow(ReferencePageViewModel viewModel) {
    final isScales = viewModel.selectedMode == ReferenceMode.scales;
    final fields = <Widget>[
      _buildModeDropdown(viewModel),
      _buildKeyDropdown(viewModel, isScales: isScales),
      if (isScales)
        _buildScaleTypeDropdown(viewModel)
      else ...[
        _buildChordTypeDropdown(viewModel),
        _buildInversionDropdown(viewModel),
      ],
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < fields.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : Spacing.xs),
              child: fields[i],
            ),
          ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.small)),
      ),
    );
  }

  Widget _buildModeDropdown(ReferencePageViewModel viewModel) {
    return DropdownButtonFormField<ReferenceMode>(
      key: ValueKey("reference_mode_${viewModel.selectedMode.name}"),
      initialValue: viewModel.selectedMode,
      decoration: _dropdownDecoration("Mode"),
      isExpanded: true,
      items: const [
        DropdownMenuItem(
          value: ReferenceMode.scales,
          child: Text("Scales", overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        DropdownMenuItem(
          value: ReferenceMode.chordTypes,
          child: Text("Chords", overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          viewModel.setSelectedMode(value);
        }
      },
    );
  }

  Widget _buildKeyDropdown(
    ReferencePageViewModel viewModel, {
    required bool isScales,
  }) {
    return DropdownButtonFormField<scales.Key>(
      key: ValueKey("reference_key_${viewModel.selectedKey.name}"),
      initialValue: viewModel.selectedKey,
      decoration: _dropdownDecoration(isScales ? "Key" : "Root"),
      isExpanded: true,
      items: scales.Key.values.map((key) {
        return DropdownMenuItem(
          value: key,
          child: Text(
            key.displayName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          viewModel.setSelectedKey(value);
        }
      },
    );
  }

  Widget _buildScaleTypeDropdown(ReferencePageViewModel viewModel) {
    return DropdownButtonFormField<scales.ScaleType>(
      key: ValueKey(
        "reference_scale_type_${viewModel.selectedScaleType.name}",
      ),
      initialValue: viewModel.selectedScaleType,
      decoration: _dropdownDecoration("Scale"),
      isExpanded: true,
      items: scales.ScaleType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            MusicalConstants.scaleTypeNames[type.name] ?? type.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          viewModel.setSelectedScaleType(value);
        }
      },
    );
  }

  Widget _buildChordTypeDropdown(ReferencePageViewModel viewModel) {
    return DropdownButtonFormField<ChordType>(
      key: ValueKey(
        "reference_chord_type_${viewModel.selectedChordType.name}",
      ),
      initialValue: viewModel.selectedChordType,
      decoration: _dropdownDecoration("Chord"),
      isExpanded: true,
      items: ChordType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type.shortName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          viewModel.setSelectedChordType(value);
        }
      },
    );
  }

  Widget _buildInversionDropdown(ReferencePageViewModel viewModel) {
    return DropdownButtonFormField<ChordInversion>(
      key: ValueKey(
        "reference_chord_inversion_${viewModel.selectedChordInversion.name}",
      ),
      initialValue: viewModel.selectedChordInversion,
      decoration: _dropdownDecoration("Inv."),
      isExpanded: true,
      items: ChordInversion.values.map((inversion) {
        return DropdownMenuItem(
          value: inversion,
          child: Text(
            ChordInversionUtils.getInversionDisplayName(inversion),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          viewModel.setSelectedChordInversion(value);
        }
      },
    );
  }
}
