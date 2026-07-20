import "package:flutter/material.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as scales;
import "package:piano_fitness/domain/services/music_theory/chord_inversion_utils.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/reference/reference_page_view_model.dart";

/// The single, thin configuration row (mode + key/type selectors) shown
/// above the reference page's piano, replacing the previous stack of
/// full-width chip panels so the options fit without scrolling.
///
/// Exposes plain values and change callbacks rather than depending on
/// [ReferencePageViewModel] directly, keeping it reusable and testable in
/// isolation from the page's provider wiring.
class ReferenceConfigRow extends StatelessWidget {
  /// Creates the reference configuration row.
  const ReferenceConfigRow({
    required this.selectedMode,
    required this.onModeChanged,
    required this.selectedKey,
    required this.onKeyChanged,
    required this.selectedScaleType,
    required this.onScaleTypeChanged,
    required this.selectedChordType,
    required this.onChordTypeChanged,
    required this.selectedChordInversion,
    required this.onChordInversionChanged,
    super.key,
  });

  /// The currently selected reference mode (scales or chord types).
  final ReferenceMode selectedMode;

  /// Called when the user picks a different reference mode.
  final ValueChanged<ReferenceMode> onModeChanged;

  /// The currently selected musical key (or chord root note).
  final scales.Key selectedKey;

  /// Called when the user picks a different key/root note.
  final ValueChanged<scales.Key> onKeyChanged;

  /// The currently selected scale type.
  final scales.ScaleType selectedScaleType;

  /// Called when the user picks a different scale type.
  final ValueChanged<scales.ScaleType> onScaleTypeChanged;

  /// The currently selected chord type.
  final ChordType selectedChordType;

  /// Called when the user picks a different chord type.
  final ValueChanged<ChordType> onChordTypeChanged;

  /// The currently selected chord inversion.
  final ChordInversion selectedChordInversion;

  /// Called when the user picks a different chord inversion.
  final ValueChanged<ChordInversion> onChordInversionChanged;

  @override
  Widget build(BuildContext context) {
    final isScales = selectedMode == ReferenceMode.scales;
    final fields = <Widget>[
      _buildModeDropdown(),
      _buildKeyDropdown(isScales: isScales),
      if (isScales)
        _buildScaleTypeDropdown()
      else ...[
        _buildChordTypeDropdown(),
        _buildInversionDropdown(),
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

  Widget _buildModeDropdown() {
    return DropdownButtonFormField<ReferenceMode>(
      key: ValueKey("reference_mode_${selectedMode.name}"),
      initialValue: selectedMode,
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
          onModeChanged(value);
        }
      },
    );
  }

  Widget _buildKeyDropdown({required bool isScales}) {
    return DropdownButtonFormField<scales.Key>(
      key: ValueKey("reference_key_${selectedKey.name}"),
      initialValue: selectedKey,
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
          onKeyChanged(value);
        }
      },
    );
  }

  Widget _buildScaleTypeDropdown() {
    return DropdownButtonFormField<scales.ScaleType>(
      key: ValueKey("reference_scale_type_${selectedScaleType.name}"),
      initialValue: selectedScaleType,
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
          onScaleTypeChanged(value);
        }
      },
    );
  }

  Widget _buildChordTypeDropdown() {
    return DropdownButtonFormField<ChordType>(
      key: ValueKey("reference_chord_type_${selectedChordType.name}"),
      initialValue: selectedChordType,
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
          onChordTypeChanged(value);
        }
      },
    );
  }

  Widget _buildInversionDropdown() {
    return DropdownButtonFormField<ChordInversion>(
      key: ValueKey(
        "reference_chord_inversion_${selectedChordInversion.name}",
      ),
      initialValue: selectedChordInversion,
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
          onChordInversionChanged(value);
        }
      },
    );
  }
}
