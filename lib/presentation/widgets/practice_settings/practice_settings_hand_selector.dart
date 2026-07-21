import "dart:math" as math;
import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/presentation/constants/practice_constants.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Segmented button control for selecting practicing hand (Left, Right, Both).
class PracticeSettingsHandSelector extends StatelessWidget {
  /// Creates the hand selection segmented button.
  const PracticeSettingsHandSelector({
    required this.selectedHand,
    required this.onHandSelected,
    super.key,
  });

  /// The currently selected hand.
  final HandSelection selectedHand;

  /// Callback when hand selection changes.
  final ValueChanged<HandSelection> onHandSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HandSelection>(
      segments: [
        ButtonSegment(
          value: HandSelection.left,
          label: const Text("Left Hand"),
          icon: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: const Icon(
              Icons.back_hand,
              size: ComponentDimensions.iconSizeSmall,
            ),
          ),
        ),
        const ButtonSegment(
          value: HandSelection.right,
          label: Text("Right Hand"),
          icon: Icon(Icons.back_hand, size: ComponentDimensions.iconSizeSmall),
        ),
        ButtonSegment(
          value: HandSelection.both,
          label: const Text("Both Hands"),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: const Icon(
                  Icons.back_hand,
                  size: ComponentDimensions.iconSizeSmall,
                ),
              ),
              const SizedBox(width: PracticeUIConstants.handIconSpacing),
              const Icon(
                Icons.back_hand,
                size: ComponentDimensions.iconSizeSmall,
              ),
            ],
          ),
        ),
      ],
      selected: {selectedHand},
      onSelectionChanged: (Set<HandSelection> selection) {
        onHandSelected(selection.first);
      },
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}
