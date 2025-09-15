import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/features/device_controller/device_controller_page.dart";
import "package:piano_fitness/features/midi_settings/midi_settings_view_model.dart";
import "package:piano_fitness/shared/theme/semantic_colors.dart";
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
      create: (context) =>
          MidiSettingsViewModel(initialChannel: widget.initialChannel),
      child: Consumer<MidiSettingsViewModel>(
        builder: (context, viewModel, child) {
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
                    Center(
                      child: Icon(
                        Icons.bluetooth_audio,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelSelector(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final semanticColors = context.semanticColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semanticColors.infoContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "MIDI Output Channel",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Channel: "),
              Semantics(
                button: true,
                enabled: viewModel.selectedChannel > 0,
                label: "Decrease MIDI channel",
                hint:
                    "Currently set to channel ${viewModel.selectedChannel + 1}",
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Semantics(
                button: true,
                enabled: viewModel.selectedChannel < 15,
                label: "Increase MIDI channel",
                hint:
                    "Currently set to channel ${viewModel.selectedChannel + 1}",
                child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: viewModel.selectedChannel < 15
                      ? viewModel.incrementChannel
                      : null,
                ),
              ),
            ],
          ),
          Semantics(
            label: "Channel for virtual piano output, ranges from 1 to 16",
            child: Text(
              "Channel for virtual piano output (1-16)",
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Semantics(
      container: true,
      label: "MIDI status: ${viewModel.midiStatus}",
      liveRegion: true,
      child: ExcludeSemantics(
        child: Text(
          viewModel.midiStatus,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    final semanticColors = context.semanticColors;

    return Center(
      child: ElevatedButton.icon(
        onPressed: () => viewModel.retrySetup(),
        icon: const Icon(Icons.refresh),
        label: const Text("Retry"),
        style: ElevatedButton.styleFrom(
          backgroundColor: semanticColors.info,
          foregroundColor: semanticColors.onInfo,
        ),
      ),
    );
  }

  Widget _buildResetInfo() {
    final theme = Theme.of(context);
    final semanticColors = context.semanticColors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semanticColors.infoContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: semanticColors.onInfoContainer,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            "Alternative Options:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: semanticColors.onInfoContainer,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "• Use a physical iPhone/iPad device\n"
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
              leading: Builder(
                builder: (context) {
                  final semanticColors = context.semanticColors;
                  return Icon(
                    device.connected
                        ? Icons.radio_button_on
                        : Icons.radio_button_off,
                    color: device.connected
                        ? semanticColors.success
                        : semanticColors.disabled,
                  );
                },
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
          style: TextStyle(fontSize: 12),
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
        Builder(
          builder: (context) {
            final semanticColors = context.semanticColors;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: semanticColors.successContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: semanticColors.success.withAlpha(80)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.music_note,
                    color: semanticColors.success,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "MIDI Activity:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.lastNote,
                    style: TextStyle(
                      color: semanticColors.success,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return FloatingActionButton(
      heroTag: "main",
      onPressed: viewModel.isScanning
          ? null
          : (viewModel.shouldShowErrorButtons
                ? () => viewModel.retrySetup()
                : () => viewModel.scanForDevices(
                    context,
                    () =>
                        viewModel.informUserAboutBluetoothPermissions(context),
                    _showSnackBar,
                  )),
      tooltip: viewModel.isScanning
          ? "Scanning..."
          : (viewModel.shouldShowErrorButtons
                ? "Retry MIDI setup"
                : "Scan for MIDI devices"),
      backgroundColor: viewModel.isScanning
          ? Theme.of(context).disabledColor
          : null,
      child: viewModel.isScanning
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
              strokeWidth: 2,
            )
          : Icon(
              viewModel.shouldShowErrorButtons
                  ? Icons.refresh
                  : Icons.bluetooth_searching,
            ),
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
      final semanticColors = context.semanticColors;

      // Auto-assign semantic colors based on message content if no color provided
      Color? snackBarColor = backgroundColor;
      if (snackBarColor == null) {
        if (message.toLowerCase().contains("error") ||
            message.toLowerCase().contains("failed") ||
            message.toLowerCase().contains("cannot")) {
          snackBarColor = semanticColors.warning;
        } else if (message.toLowerCase().contains("connected") ||
            message.toLowerCase().contains("success")) {
          snackBarColor = semanticColors.success;
        } else if (message.toLowerCase().contains("scanning") ||
            message.toLowerCase().contains("found")) {
          snackBarColor = semanticColors.info;
        }
      }

      final textColor = switch (snackBarColor) {
        final c? when c == semanticColors.success => semanticColors.onSuccess,
        final c? when c == semanticColors.warning => semanticColors.onWarning,
        final c? when c == semanticColors.info => semanticColors.onInfo,
        _ => null,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: snackBarColor,
          content: Text(
            message,
            style: textColor != null ? TextStyle(color: textColor) : null,
          ),
        ),
      );
    }
  }
}
