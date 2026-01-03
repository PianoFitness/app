import "package:flutter/material.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/features/reference/reference_constants.dart";
import "package:piano_fitness/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/constants/musical_constants.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
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
    final theme = Theme.of(context);

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
                    // Mode Selection
                    Container(
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary
                              .withValues(alpha: OpacityValues.borderMedium),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Reference Mode",
                            style: TextStyle(
                              fontSize:
                                  theme.textTheme.headlineMedium?.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(
                            height: ReferenceUIConstants.headerSpacing,
                          ),
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
                    const SizedBox(height: Spacing.md),

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
                      mode: PianoMode.reference,
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
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withValues(
                alpha: OpacityValues.borderMedium,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Key",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
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
                    selectedColor: Theme.of(context).colorScheme.secondary
                        .withValues(alpha: OpacityValues.backgroundMedium),
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // Scale Type Selection
        Container(
          key: const Key("scales_type_selection"),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Scale Type",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: scales.ScaleType.values.map((scales.ScaleType type) {
                  final isSelected = _viewModel.selectedScaleType == type;
                  return FilterChip(
                    key: Key("scales_type_${type.name}"),
                    label: Text(
                      MusicalConstants.scaleTypeNames[type.name] ?? type.name,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedScaleType(type);
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
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
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Root Note",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
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
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.tertiary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // Chord Type Selection
        Container(
          key: const Key("chords_type_selection"),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chord Type",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: ChordType.values.map((type) {
                  final isSelected = _viewModel.selectedChordType == type;
                  return FilterChip(
                    key: Key("chords_type_${type.name}"),
                    label: Text(
                      MusicalConstants.chordTypeNames[type.name] ?? type.name,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedChordType(type);
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.tertiary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),

        // Chord Inversion Selection
        Container(
          key: const Key("chords_inversion_selection"),
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Inversion",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: ChordInversion.values.map((inversion) {
                  final isSelected =
                      _viewModel.selectedChordInversion == inversion;
                  return FilterChip(
                    key: Key("chords_inversion_${inversion.name}"),
                    label: Text(
                      MusicalConstants.chordInversionNames[inversion.name] ??
                          inversion.name,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _viewModel.setSelectedChordInversion(inversion);
                      }
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.tertiaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.tertiary,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
