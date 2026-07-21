import "package:flutter/material.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Choice chips for [MetronomeState.availableTimeSignatures].
///
/// Shared between the full [MetronomePage] and the quick-access bottom
/// sheet opened from the app bar.
class MetronomeTimeSignatureSelector extends StatelessWidget {
  /// Creates a time signature selector bound to [state].
  const MetronomeTimeSignatureSelector({required this.state, super.key});

  /// The metronome state to read and mutate.
  final MetronomeState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key("metronome_time_signature_selector"),
      spacing: Spacing.sm,
      children: [
        for (final signature in state.availableTimeSignatures)
          ChoiceChip(
            key: Key(
              "metronome_time_signature_${signature.numerator}_${signature.denominator}",
            ),
            label: Text(signature.label),
            selected: state.timeSignature == signature,
            onSelected: (_) => state.setTimeSignature(signature),
          ),
      ],
    );
  }
}
