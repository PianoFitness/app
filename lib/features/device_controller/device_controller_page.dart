import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/features/device_controller/device_controller_constants.dart";
import "package:piano_fitness/features/device_controller/device_controller_view_model.dart";
import "package:piano_fitness/shared/constants/ui_constants.dart";
import "package:piano_fitness/shared/theme/semantic_colors.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
import "package:piano_fitness/shared/utils/piano_key_utils.dart";
import "package:provider/provider.dart";

/// A detailed controller interface for a specific MIDI device.
///
/// This page provides comprehensive controls for testing and interacting
/// with a connected MIDI device, including sending test notes, monitoring
/// MIDI messages, and device-specific operations.
class DeviceControllerPage extends StatefulWidget {
  /// Creates a device controller page for the specified MIDI device.
  const DeviceControllerPage({required this.device, super.key});

  /// The MIDI device to control and monitor.
  final MidiDevice device;

  @override
  State<DeviceControllerPage> createState() => _DeviceControllerPageState();
}

class _DeviceControllerPageState extends State<DeviceControllerPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceControllerViewModel(device: widget.device),
      child: Consumer<DeviceControllerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("${viewModel.device.name} Controller"),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                _buildDeviceInfoCard(context, viewModel),
                _buildLastMessageCard(context, viewModel),
                _buildChannelCard(context, viewModel),
                _buildControlChangeCard(context, viewModel),
                _buildProgramChangeCard(context, viewModel),
                _buildPitchBendCard(context, viewModel),
                _buildVirtualPianoCard(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceInfoCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                "Device Information",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text("Device name: ${viewModel.device.name}"),
            Text("Device type: ${viewModel.device.type}"),
            Text("Device ID: ${viewModel.device.id}"),
            Semantics(
              label:
                  "Device is ${viewModel.device.connected ? "connected" : "disconnected"}",
              liveRegion: true,
              excludeSemantics: true,
              child: Text(
                'Connection status: ${viewModel.device.connected ? "Connected" : "Disconnected"}',
              ),
            ),
            Text("Input ports: ${viewModel.device.inputPorts.length}"),
            Text("Output ports: ${viewModel.device.outputPorts.length}"),
          ],
        ),
      ),
    );
  }

  Widget _buildLastMessageCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
    return Card(
      color:
          Theme.of(
            context,
          ).extension<SemanticColors>()?.success.withValues(alpha: 0.1) ??
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last Received MIDI Message",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(viewModel.lastReceivedMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                "MIDI Channel",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
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

  Widget _buildControlChangeCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
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
            Row(
              children: [
                const Text("Controller: "),
                Expanded(
                  child: Slider(
                    value: viewModel.ccController.toDouble(),
                    max: MidiConstants.controllerMax.toDouble(),
                    divisions: MidiConstants.controllerMax,
                    label: viewModel.ccController.toString(),
                    onChanged: (value) =>
                        viewModel.setCCController(value.toInt()),
                  ),
                ),
                Text(viewModel.ccController.toString()),
              ],
            ),
            Row(
              children: [
                const Text("Value: "),
                Expanded(
                  child: Slider(
                    value: viewModel.ccValue.toDouble(),
                    max: MidiConstants.controllerMax.toDouble(),
                    divisions: MidiConstants.controllerMax,
                    label: viewModel.ccValue.toString(),
                    onChanged: (value) => viewModel.setCCValue(value.toInt()),
                  ),
                ),
                Text(viewModel.ccValue.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramChangeCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MIDI Channel", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                const Text("Program: "),
                Expanded(
                  child: Slider(
                    value: viewModel.programNumber.toDouble(),
                    max: MidiConstants.programMax.toDouble(),
                    divisions: MidiConstants.programMax,
                    label: viewModel.programNumber.toString(),
                    onChanged: (value) =>
                        viewModel.setProgramNumber(value.toInt()),
                  ),
                ),
                Text(viewModel.programNumber.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPitchBendCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
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
              min: MidiConstants.pitchBendMin,
              divisions: MidiConstants.pitchBendDivisions,
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

  Widget _buildVirtualPianoCard(
    BuildContext context,
    DeviceControllerViewModel viewModel,
  ) {
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
                _buildDevicePianoKey(61, viewModel), // C# black key
                _buildDevicePianoKey(63, viewModel), // D# black key
                const SizedBox(
                  width: DeviceControllerUIConstants.blackKeyGroupGap,
                ),
                _buildDevicePianoKey(66, viewModel), // F# black key
                _buildDevicePianoKey(68, viewModel), // G# black key
                _buildDevicePianoKey(70, viewModel), // A# black key
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: DeviceControllerUIConstants.pianoKeySpacing,
              alignment: WrapAlignment.center,
              children: [
                for (int note = 60; note <= 71; note++)
                  if (isWhiteKey(note))
                    _buildDevicePianoKey(note, viewModel), // White keys
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicePianoKey(
    int midiNote,
    DeviceControllerViewModel viewModel,
  ) {
    // Use centralized compact note naming to ensure consistency across the app
    final noteName = NoteUtils.getCompactNoteName(midiNote);
    final theme = Theme.of(context);
    final isBlack = isBlackKey(midiNote);

    // For piano keys, we need clear visual distinction regardless of theme
    final keyColor = isBlack
        ? theme
              .colorScheme
              .inverseSurface // Dark key (traditionally black)
        : theme.colorScheme.surface; // Light key (traditionally white)
    final textColor = isBlack
        ? theme
              .colorScheme
              .onInverseSurface // Light text on dark key
        : theme.colorScheme.onSurface; // Dark text on light key

    return GestureDetector(
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
