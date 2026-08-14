import "package:flutter/material.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/features/device_controller/device_controller_constants.dart";
import "package:piano_fitness/presentation/features/device_controller/device_controller_view_model.dart";
import "package:piano_fitness/presentation/utils/piano_key_utils.dart";

/// At-a-glance connection state for the selected MIDI device.
class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({required this.viewModel, super.key});

  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key("device_connection_status"),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: viewModel.device.connected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Row(
        children: [
          Icon(
            viewModel.device.connected
                ? Icons.check_circle
                : Icons.link_off_outlined,
            color: viewModel.device.connected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.device.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  viewModel.device.connected ? "Connected" : "Disconnected",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One-octave virtual keyboard for checking device output.
class DeviceVirtualPianoCard extends StatelessWidget {
  const DeviceVirtualPianoCard({required this.viewModel, super.key});

  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Virtual Piano",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: DeviceControllerUIConstants.pianoKeySpacing,
              alignment: WrapAlignment.center,
              children: [
                const SizedBox(
                  width: DeviceControllerUIConstants.blackKeyLeftOffset,
                ),
                _DevicePianoKey(midiNote: 61, viewModel: viewModel),
                _DevicePianoKey(midiNote: 63, viewModel: viewModel),
                const SizedBox(
                  width: DeviceControllerUIConstants.blackKeyGroupGap,
                ),
                _DevicePianoKey(midiNote: 66, viewModel: viewModel),
                _DevicePianoKey(midiNote: 68, viewModel: viewModel),
                _DevicePianoKey(midiNote: 70, viewModel: viewModel),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: DeviceControllerUIConstants.pianoKeySpacing,
              alignment: WrapAlignment.center,
              children: [
                for (int note = 60; note <= 71; note++)
                  if (isWhiteKey(note))
                    _DevicePianoKey(midiNote: note, viewModel: viewModel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DevicePianoKey extends StatelessWidget {
  const _DevicePianoKey({required this.midiNote, required this.viewModel});

  final int midiNote;
  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final noteName = viewModel.getNoteLabel(midiNote);
    final theme = Theme.of(context);
    final isBlack = isBlackKey(midiNote);
    final keyColor = isBlack
        ? theme.colorScheme.inverseSurface
        : theme.colorScheme.surface;
    final textColor = isBlack
        ? theme.colorScheme.onInverseSurface
        : theme.colorScheme.onSurface;

    return GestureDetector(
      key: Key("device_piano_key_$midiNote"),
      onTapDown: (_) => viewModel.sendNoteOn(midiNote),
      onTapUp: (_) => viewModel.sendNoteOff(midiNote),
      onTapCancel: () => viewModel.sendNoteOff(midiNote),
      child: Container(
        width: DeviceControllerUIConstants.pianoKeyWidth,
        height: DeviceControllerUIConstants.pianoKeyHeight,
        decoration: BoxDecoration(
          color: keyColor,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(AppBorderRadius.xs),
        ),
        child: Center(
          child: Text(
            noteName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: DeviceControllerUIConstants.pianoKeyFontSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Less common MIDI message controls kept behind one disclosure section.
class DeviceAdvancedControlsSection extends StatelessWidget {
  const DeviceAdvancedControlsSection({required this.viewModel, super.key});

  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const Key("advanced_midi_controls_section"),
      leading: const Icon(Icons.tune),
      title: const Text("Advanced MIDI controls"),
      subtitle: const Text("Channel, CC, program, and pitch bend"),
      children: [
        _ChannelCard(viewModel: viewModel),
        _ControlChangeCard(viewModel: viewModel),
        _ProgramChangeCard(viewModel: viewModel),
        _PitchBendCard(viewModel: viewModel),
      ],
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.viewModel});
  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Semantics(
              header: true,
              child: Text(
                "MIDI Channel",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  button: true,
                  enabled: viewModel.selectedChannel > 0,
                  label: "Decrease MIDI channel",
                  hint: "Current channel is ${viewModel.selectedChannel + 1}",
                  child: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: viewModel.selectedChannel > 0
                        ? viewModel.decrementChannel
                        : null,
                  ),
                ),
                Semantics(
                  value: "${viewModel.selectedChannel + 1}",
                  excludeSemantics: true,
                  liveRegion: true,
                  child: Text(
                    "${viewModel.selectedChannel + 1}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Semantics(
                  button: true,
                  enabled: viewModel.selectedChannel < 15,
                  label: "Increase MIDI channel",
                  hint: "Current channel is ${viewModel.selectedChannel + 1}",
                  child: IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: viewModel.selectedChannel < 15
                        ? viewModel.incrementChannel
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlChangeCard extends StatelessWidget {
  const _ControlChangeCard({required this.viewModel});
  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Control Change (CC)",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.md),
            _ValueSlider(
              label: "Controller",
              value: viewModel.ccController,
              maximum: DeviceControllerViewModel.controllerMax,
              onChanged: viewModel.setCCController,
            ),
            _ValueSlider(
              label: "Value",
              value: viewModel.ccValue,
              maximum: DeviceControllerViewModel.controllerMax,
              onChanged: viewModel.setCCValue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramChangeCard extends StatelessWidget {
  const _ProgramChangeCard({required this.viewModel});
  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Program Change",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.sm),
            _ValueSlider(
              label: "Program",
              value: viewModel.programNumber,
              maximum: DeviceControllerViewModel.programMax,
              onChanged: viewModel.setProgramNumber,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueSlider extends StatelessWidget {
  const _ValueSlider({
    required this.label,
    required this.value,
    required this.maximum,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$label: "),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            max: maximum.toDouble(),
            divisions: maximum,
            label: value.toString(),
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ),
        Text(value.toString()),
      ],
    );
  }
}

class _PitchBendCard extends StatelessWidget {
  const _PitchBendCard({required this.viewModel});
  final DeviceControllerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pitch Bend", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            Slider(
              value: viewModel.pitchBend,
              min: DeviceControllerViewModel.pitchBendMin,
              divisions: MidiUiConstants.pitchBendDivisions,
              label: viewModel.pitchBend.toStringAsFixed(2),
              onChanged: viewModel.setPitchBend,
              onChangeEnd: (_) => viewModel.resetPitchBend(),
            ),
            Center(child: Text(viewModel.pitchBend.toStringAsFixed(2))),
          ],
        ),
      ),
    );
  }
}
