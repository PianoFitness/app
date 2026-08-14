import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";
import "package:piano_fitness/presentation/features/reference/widgets/reference_config_row.dart";

/// A complete reference choice returned by [PianoReferencePickerSheet].
class PianoReferenceSelection {
  /// Creates a reference choice.
  const PianoReferenceSelection({
    required this.mode,
    required this.key,
    required this.scaleType,
    required this.chordType,
    required this.chordInversion,
  });

  /// Whether the selection describes a scale or chord.
  final ReferenceMode mode;

  /// The scale key or chord root.
  final scales.Key key;

  /// The selected scale type.
  final scales.ScaleType scaleType;

  /// The selected chord type.
  final ChordType chordType;

  /// The selected chord inversion.
  final ChordInversion chordInversion;
}

/// A focused configuration sheet for choosing notes to show on the piano.
class PianoReferencePickerSheet extends StatefulWidget {
  /// Creates a picker initialized with the current reference values.
  const PianoReferencePickerSheet({
    required this.initialSelection,
    required this.isEditing,
    super.key,
  });

  /// Values shown when the sheet opens.
  final PianoReferenceSelection initialSelection;

  /// Whether an existing reference is being changed.
  final bool isEditing;

  @override
  State<PianoReferencePickerSheet> createState() =>
      _PianoReferencePickerSheetState();
}

class _PianoReferencePickerSheetState extends State<PianoReferencePickerSheet> {
  late ReferenceMode _mode;
  late scales.Key _key;
  late scales.ScaleType _scaleType;
  late ChordType _chordType;
  late ChordInversion _chordInversion;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelection;
    _mode = initial.mode;
    _key = initial.key;
    _scaleType = initial.scaleType;
    _chordType = initial.chordType;
    _chordInversion = initial.chordInversion;
  }

  void _submit() {
    Navigator.of(context).pop(
      PianoReferenceSelection(
        mode: _mode,
        key: _key,
        scaleType: _scaleType,
        chordType: _chordType,
        chordInversion: _chordInversion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.lg,
          Spacing.lg,
          Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Show notes", style: textTheme.headlineSmall),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          "Choose a scale or chord to highlight on the keyboard.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key("reference_picker_close"),
                    tooltip: "Close",
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              ReferenceConfigRow(
                selectedMode: _mode,
                onModeChanged: (value) => setState(() => _mode = value),
                selectedKey: _key,
                onKeyChanged: (value) => setState(() => _key = value),
                selectedScaleType: _scaleType,
                onScaleTypeChanged: (value) =>
                    setState(() => _scaleType = value),
                selectedChordType: _chordType,
                onChordTypeChanged: (value) =>
                    setState(() => _chordType = value),
                selectedChordInversion: _chordInversion,
                onChordInversionChanged: (value) =>
                    setState(() => _chordInversion = value),
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: Spacing.sm),
                  FilledButton(
                    key: const Key("reference_picker_apply"),
                    onPressed: _submit,
                    child: Text(
                      widget.isEditing ? "Update piano" : "Show notes",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
