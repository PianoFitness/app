import "dart:math" as math;

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/music_theory/chord_inversion_utils.dart";
import "package:piano_fitness/presentation/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/piano/reference_picker_sheet.dart";
import "package:piano_fitness/presentation/features/piano/widgets/twelve_tone_circle.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/utils/piano_accessibility_utils.dart";
import "package:piano_fitness/presentation/utils/piano_key_utils.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";

/// An always-playable piano with optional scale and chord highlighting.
class PianoPage extends StatelessWidget {
  /// Creates the unified piano page.
  const PianoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReferencePageViewModel(
        midiCoordinator: context.read<MidiCoordinator>(),
        midiRepository: context.read<IMidiRepository>(),
        midiState: context.read<MidiState>(),
      ),
      child: const _PianoPageView(),
    );
  }
}

class _PianoPageView extends StatefulWidget {
  const _PianoPageView();

  @override
  State<_PianoPageView> createState() => _PianoPageViewState();
}

class _PianoPageViewState extends State<_PianoPageView> {
  bool _showReferenceNotes = false;

  Future<void> _openReferencePicker(ReferencePageViewModel viewModel) async {
    final selection = await showModalBottomSheet<PianoReferenceSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) => PianoReferencePickerSheet(
        isEditing: _showReferenceNotes,
        initialSelection: PianoReferenceSelection(
          mode: viewModel.selectedMode,
          key: viewModel.selectedKey,
          scaleType: viewModel.selectedScaleType,
          chordType: viewModel.selectedChordType,
          chordInversion: viewModel.selectedChordInversion,
        ),
      ),
    );

    if (!mounted || selection == null) return;

    viewModel.setSelection(
      mode: selection.mode,
      key: selection.key,
      scaleType: selection.scaleType,
      chordType: selection.chordType,
      chordInversion: selection.chordInversion,
    );
    setState(() => _showReferenceNotes = true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReferencePageViewModel>();
    final midiState = context.watch<MidiState>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _PianoHeader(
                  viewModel: viewModel,
                  midiActive: midiState.hasRecentActivity,
                  showReferenceNotes: _showReferenceNotes,
                  onChooseReference: () => _openReferencePicker(viewModel),
                  onClearReference: () {
                    setState(() => _showReferenceNotes = false);
                  },
                ),
                Expanded(
                  child: _ReferenceCanvas(
                    viewModel: viewModel,
                    midiState: midiState,
                    showReferenceNotes: _showReferenceNotes,
                  ),
                ),
              ],
            ),
          ),
          _PianoDock(
            viewModel: viewModel,
            midiState: midiState,
            showReferenceNotes: _showReferenceNotes,
          ),
        ],
      ),
    );
  }
}

class _PianoHeader extends StatelessWidget {
  const _PianoHeader({
    required this.viewModel,
    required this.midiActive,
    required this.showReferenceNotes,
    required this.onChooseReference,
    required this.onClearReference,
  });

  final ReferencePageViewModel viewModel;
  final bool midiActive;
  final bool showReferenceNotes;
  final VoidCallback onChooseReference;
  final VoidCallback onClearReference;

  String get _title {
    if (!showReferenceNotes) return "Play freely";

    if (viewModel.selectedMode == ReferenceMode.scales) {
      final scaleName =
          MusicalConstants.scaleTypeNames[viewModel.selectedScaleType.name] ??
          viewModel.selectedScaleType.name;
      return "${viewModel.selectedKey.displayName} $scaleName scale";
    }

    return "${viewModel.selectedKey.displayName} ${viewModel.selectedChordType.shortName}";
  }

  String get _supportingText {
    if (!showReferenceNotes) {
      return midiActive ? "MIDI active" : "Use a MIDI keyboard or tap the keys";
    }

    final noteCount = viewModel.localHighlightedNotes.length;
    if (viewModel.selectedMode == ReferenceMode.scales) {
      return "$noteCount notes highlighted";
    }

    final inversion = ChordInversionUtils.getInversionDisplayName(
      viewModel.selectedChordInversion,
    );
    return "$inversion • $noteCount notes highlighted";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.sm,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Row(
            children: [
              Icon(
                showReferenceNotes
                    ? Icons.music_note
                    : midiActive
                    ? Icons.graphic_eq
                    : Icons.piano,
                color: showReferenceNotes || midiActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _supportingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              FilledButton.tonalIcon(
                key: const Key("piano_show_notes_button"),
                onPressed: onChooseReference,
                icon: Icon(
                  showReferenceNotes ? Icons.tune : Icons.lightbulb_outline,
                ),
                label: Text(showReferenceNotes ? "Change" : "Show notes"),
              ),
              if (showReferenceNotes) ...[
                const SizedBox(width: Spacing.xs),
                IconButton(
                  key: const Key("piano_clear_reference"),
                  tooltip: "Clear highlighted notes",
                  onPressed: onClearReference,
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceCanvas extends StatelessWidget {
  const _ReferenceCanvas({
    required this.viewModel,
    required this.midiState,
    required this.showReferenceNotes,
  });

  final ReferencePageViewModel viewModel;
  final MidiState midiState;
  final bool showReferenceNotes;

  @override
  Widget build(BuildContext context) {
    final referenceNotes = showReferenceNotes
        ? viewModel.localHighlightedNotes.map((note) => note.value).toSet()
        : <int>{};
    final activeNotes = midiState.activeNotes;
    final selectedPitchClasses = referenceNotes
        .map((note) => note % MusicalConstants.semitonesPerOctave)
        .toSet();
    final activePitchClasses = activeNotes
        .map((note) => note % MusicalConstants.semitonesPerOctave)
        .toSet();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 220;
          return Column(
            children: [
              if (!compact) ...[
                Text("12-tone map", style: textTheme.titleMedium),
                const SizedBox(height: Spacing.xs),
                Text(
                  showReferenceNotes
                      ? "The connected shape shows how these tones relate."
                      : "Choose a scale or chord, or play a note to see it here.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
              ],
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: TwelveToneCircle(
                        selectedPitchClasses: selectedPitchClasses,
                        activePitchClasses: activePitchClasses,
                      ),
                    ),
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: Spacing.sm),
                Text(
                  showReferenceNotes
                      ? "Play the highlighted tones in any octave."
                      : "The piano is always ready below.",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PianoDock extends StatelessWidget {
  const _PianoDock({
    required this.viewModel,
    required this.midiState,
    required this.showReferenceNotes,
  });

  final ReferencePageViewModel viewModel;
  final MidiState midiState;
  final bool showReferenceNotes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewport = MediaQuery.sizeOf(context);
    final dockHeight = math.min(
      240.0,
      math.min(viewport.width * 0.52, math.max(140.0, viewport.height * 0.32)),
    );
    final referenceNotes = showReferenceNotes
        ? viewModel.localHighlightedNotes.map((note) => note.value).toSet()
        : <int>{};
    final activeNotes = midiState.activeNotes;
    final visibleNotes = {...referenceNotes, ...activeNotes};

    return SizedBox(
      key: const Key("piano_stage"),
      width: double.infinity,
      height: dockHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const range = PianoRangeUtils.standard49KeyRange;
          final whiteKeyCount = getWhiteKeysInRange(
            range.fromMidi,
            range.toMidi,
          ).length;
          final keyWidth = constraints.maxWidth / whiteKeyCount;
          final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({
            for (final note in referenceNotes)
              note: PianoKeyVisual(fill: colorScheme.primaryContainer),
            for (final note in activeNotes)
              note: PianoKeyVisual(fill: colorScheme.primary),
          });

          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: PianoAccessibilityUtils.createAccessiblePianoWrapper(
              highlightedMidiNotes: visibleNotes.toList(),
              mode: showReferenceNotes ? PianoMode.reference : PianoMode.play,
              semanticLabel: showReferenceNotes
                  ? "Piano with reference notes highlighted"
                  : "Playable piano keyboard",
              child: PianoKeyboard(
                key: const Key("piano_keyboard"),
                range: range,
                keyVisuals: keyVisuals,
                noteLabelMode: showReferenceNotes
                    ? NoteLabelMode.name
                    : NoteLabelMode.none,
                keyWidth: keyWidth,
                minimumKeyWidth: PianoRangeUtils.minKeyWidth,
                onKeyDown: viewModel.onKeyDown,
                onKeyUp: viewModel.onKeyUp,
              ),
            ),
          );
        },
      ),
    );
  }
}
