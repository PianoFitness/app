import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/features/device_controller/device_controller_page.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_view_model.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:provider/provider.dart";

/// The MIDI settings and device management page.
///
/// This page provides controls for discovering, connecting to, and configuring
/// MIDI devices. Users can scan for available devices, manage connections,
/// select MIDI channels, and access individual device controllers.
class MidiSettingsPage extends StatefulWidget {
  /// Creates a new MIDI settings page with optional initial channel.
  const MidiSettingsPage({super.key, this.initialChannel = 0});

  /// The initial MIDI channel to select (0-15).
  final int initialChannel;

  @override
  State<MidiSettingsPage> createState() => _MidiSettingsPageState();
}

class _MidiSettingsPageState extends State<MidiSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MidiSettingsViewModel(
        initialChannel: widget.initialChannel,
      ),
      child: Consumer<MidiSettingsViewModel>(
        builder: (context, viewModel, child) {
          // Set up MIDI data handling with MidiState
          return Consumer<MidiState>(
            builder: (context, midiState, child) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: const Text("MIDI Settings"),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop(viewModel.selectedChannel);
                    },
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Center(
                          child: Icon(
                            Icons.bluetooth_audio,
                            size: 80,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "MIDI Device Configuration",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildChannelSelector(context, viewModel),
                        const SizedBox(height: 16),
                        _buildStatusSection(context, viewModel),
                        const SizedBox(height: 16),
                        if (viewModel.shouldShowErrorButtons)
                          _buildErrorButtons(context, viewModel),
                        const SizedBox(height: 16),
                        if (viewModel.shouldShowResetInfo) _buildResetInfo(),
                        if (viewModel.devices.isNotEmpty) ...[
                          _buildDevicesList(context, viewModel),
                          if (viewModel.shouldShowMidiActivity)
                            _buildMidiActivity(context, viewModel),
                        ],
                      ],
                    ),
                  ),
                ),
                floatingActionButton: _buildFloatingActionButtons(
                  context,
                  viewModel,
                  midiState,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChannelSelector(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Text(
            "MIDI Output Channel",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Channel: "),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: viewModel.selectedChannel > 0
                    ? viewModel.decrementChannel
                    : null,
              ),
              Text(
                "${viewModel.selectedChannel + 1}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: viewModel.selectedChannel < 15
                    ? viewModel.incrementChannel
                    : null,
              ),
            ],
          ),
          const Text(
            "Channel for virtual piano output (1-16)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Text(
      viewModel.midiStatus,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => viewModel.retrySetup(),
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => viewModel.resetToMainScreen(),
          icon: const Icon(Icons.home),
          label: const Text("Reset"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildResetInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: const Column(
        children: [
          Icon(Icons.info, color: Colors.orange, size: 32),
          SizedBox(height: 8),
          Text(
            "Alternative Options:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "• Use a physical iPhone/iPad\n"
            "• Connect USB MIDI keyboard\n"
            "• Use virtual MIDI devices\n"
            "• Enable on-screen piano for testing",
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Column(
      children: [
        const Text(
          "MIDI Devices:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ...(viewModel.devices.map(
          (device) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                device.connected
                    ? Icons.radio_button_on
                    : Icons.radio_button_off,
                color: device.connected ? Colors.green : Colors.grey,
              ),
              title: Text(
                device.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                "Type: ${device.type}\n"
                "Inputs: ${device.inputPorts.length} | Outputs: ${device.outputPorts.length}\n"
                "ID: ${device.id}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(viewModel.getDeviceIconForType(device.type)),
                  if (device.connected)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => _openDeviceController(device, viewModel),
                      tooltip: "Open device controller",
                    ),
                ],
              ),
              onTap: () => viewModel.connectToDevice(device, _showSnackBar),
              onLongPress: device.connected
                  ? () => _openDeviceController(device, viewModel)
                  : null,
              isThreeLine: true,
            ),
          ),
        )),
        const SizedBox(height: 8),
        const Text(
          "Tap a device to connect/disconnect\nLong press or tap ⚙️ on connected devices for controller",
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMidiActivity(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.music_note,
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                "MIDI Activity:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.lastNote,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
    MidiState midiState,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.shouldShowErrorButtons)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton(
              heroTag: "reset",
              mini: true,
              onPressed: () => viewModel.resetToMainScreen(),
              tooltip: "Reset to main screen",
              backgroundColor: Colors.grey,
              child: const Icon(Icons.home),
            ),
          ),
        FloatingActionButton(
          heroTag: "main",
          onPressed: viewModel.isScanning
              ? null
              : (viewModel.shouldShowErrorButtons
                    ? () => viewModel.retrySetup()
                    : () => viewModel.scanForDevices(
                        context,
                        () => viewModel.informUserAboutBluetoothPermissions(
                          context,
                        ),
                        _showSnackBar,
                      )),
          tooltip: viewModel.isScanning
              ? "Scanning..."
              : (viewModel.shouldShowErrorButtons
                    ? "Retry MIDI setup"
                    : "Scan for MIDI devices"),
          backgroundColor: viewModel.isScanning ? Colors.grey : null,
          child: viewModel.isScanning
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Icon(
                  viewModel.shouldShowErrorButtons
                      ? Icons.refresh
                      : Icons.bluetooth_searching,
                ),
        ),
      ],
    );
  }

  Future<void> _openDeviceController(
    MidiDevice device,
    MidiSettingsViewModel viewModel,
  ) async {
    final preparedDevice = await viewModel.prepareDeviceForController(
      device,
      _showSnackBar,
    );

    if (preparedDevice != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DeviceControllerPage(device: preparedDevice),
        ),
      );
    }
  }

  void _showSnackBar(String message, [Color? backgroundColor]) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
