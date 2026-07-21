import "package:flutter/material.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";

/// A reusable card list tile for displaying a single MIDI device in MIDI settings.
class MidiDeviceListTile extends StatelessWidget {
  /// Creates a device list tile widget.
  const MidiDeviceListTile({
    required this.device,
    required this.deviceIcon,
    required this.onTap,
    required this.onOpenController,
    super.key,
  });

  /// The MIDI device model.
  final MidiDevice device;

  /// Icon representing the device connection type.
  final IconData deviceIcon;

  /// Callback when the tile is tapped to connect/disconnect.
  final VoidCallback onTap;

  /// Callback to open the device controller interface.
  final VoidCallback onOpenController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = context.semanticColors;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: ListTile(
        leading: Icon(
          device.connected ? Icons.radio_button_on : Icons.radio_button_off,
          color: device.connected
              ? semanticColors.success
              : semanticColors.disabled,
        ),
        title: Text(device.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          "Type: ${device.type}\n"
          "Inputs: ${device.inputPorts.length} | Outputs: ${device.outputPorts.length}\n"
          "ID: ${device.id}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(deviceIcon),
            if (device.connected)
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: onOpenController,
                tooltip: "Open device controller",
              ),
          ],
        ),
        onTap: onTap,
        onLongPress: device.connected ? onOpenController : null,
        isThreeLine: true,
      ),
    );
  }
}
