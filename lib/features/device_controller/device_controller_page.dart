import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/features/device_controller/device_controller_view_model.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";
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
              padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Semantics(
              label: "Device name is ${viewModel.device.name}",
              child: Text("Name: ${viewModel.device.name}"),
            ),
            Semantics(
              label: "Device type is ${viewModel.device.type}",
              child: Text("Type: ${viewModel.device.type}"),
            ),
            Semantics(
              label: "Device ID is ${viewModel.device.id}",
              child: Text("ID: ${viewModel.device.id}"),
            ),
            Semantics(
              label:
                  "Device is ${viewModel.device.connected ? "connected" : "disconnected"}",
              liveRegion: true,
              child: Text(
                'Connected: ${viewModel.device.connected ? "Yes" : "No"}',
              ),
            ),
            Semantics(
              label:
                  "Device has ${viewModel.device.inputPorts.length} input ports",
              child: Text("Inputs: ${viewModel.device.inputPorts.length}"),
            ),
            Semantics(
              label:
                  "Device has ${viewModel.device.outputPorts.length} output ports",
              child: Text("Outputs: ${viewModel.device.outputPorts.length}"),
            ),
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
      color: Colors.green.shade50,
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
                  label: "MIDI Channel ${viewModel.selectedChannel + 1}",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Control Change (CC)",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Controller: "),
                Expanded(
                  child: Slider(
                    value: viewModel.ccController.toDouble(),
                    max: 127,
                    divisions: 127,
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
                    max: 127,
                    divisions: 127,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Program Change",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Program: "),
                Expanded(
                  child: Slider(
                    value: viewModel.programNumber.toDouble(),
                    max: 127,
                    divisions: 127,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pitch Bend", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Slider(
              value: viewModel.pitchBend,
              min: -1,
              divisions: 100,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Virtual Piano",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              children: [
                const SizedBox(width: 18),
                _buildDevicePianoKey(61, Colors.black, viewModel),
                _buildDevicePianoKey(63, Colors.black, viewModel),
                const SizedBox(width: 40),
                _buildDevicePianoKey(66, Colors.black, viewModel),
                _buildDevicePianoKey(68, Colors.black, viewModel),
                _buildDevicePianoKey(70, Colors.black, viewModel),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (int note = 60; note <= 71; note += 2)
                  _buildDevicePianoKey(note, Colors.white, viewModel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicePianoKey(
    int midiNote,
    Color color,
    DeviceControllerViewModel viewModel,
  ) {
    // Use centralized compact note naming to ensure consistency across the app
    final noteName = NoteUtils.getCompactNoteName(midiNote);

    return GestureDetector(
      onTap: () => viewModel.sendNoteOn(midiNote),
      child: Container(
        width: 40,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            noteName,
            style: TextStyle(
              color: color == Colors.white ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
