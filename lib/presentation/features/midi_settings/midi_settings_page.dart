import "package:flutter/material.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";
import "package:piano_fitness/presentation/features/device_controller/device_controller_page.dart";
import "package:piano_fitness/presentation/features/midi_settings/midi_settings_view_model.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";
import "package:piano_fitness/presentation/features/midi_settings/widgets/midi_device_list_tile.dart";
import "package:piano_fitness/presentation/widgets/main_navigation_scope.dart";
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
        discoveryService: context.read<IMidiDeviceDiscoveryService>(),
        initialChannel: widget.initialChannel,
      ),
      child: Consumer<MidiSettingsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: MainNavigationScope.isActive(context)
                ? null
                : AppBar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.inversePrimary,
                    title: const Text("MIDI Settings"),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop(viewModel.selectedChannel);
                      },
                    ),
                  ),
            body: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildConnectionOverview(context, viewModel),
                        if (viewModel.devices.isNotEmpty) ...[
                          const SizedBox(height: Spacing.md),
                          _buildDevicesList(context, viewModel),
                        ],
                        if (viewModel.shouldShowErrorButtons) ...[
                          const SizedBox(height: Spacing.sm),
                          _buildErrorButtons(context, viewModel),
                        ],
                        if (viewModel.shouldShowMidiActivity)
                          _buildMidiActivity(context, viewModel),
                        const SizedBox(height: Spacing.md),
                        ExpansionTile(
                          key: const Key("midi_advanced_settings"),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                          ),
                          title: const Text("Advanced settings"),
                          subtitle: const Text("Output channel and setup help"),
                          children: [
                            _buildChannelSelector(context, viewModel),
                            if (viewModel.shouldShowResetInfo)
                              _buildResetInfo(),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildConnectionOverview(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final connected = viewModel.devices.any((device) => device.connected);
    final title = viewModel.isScanning
        ? "Looking for keyboards…"
        : connected
        ? "Keyboard connected"
        : viewModel.devices.isNotEmpty
        ? "Choose a keyboard"
        : viewModel.shouldShowErrorButtons
        ? "MIDI needs attention"
        : "No keyboard connected";
    final supportingText = connected
        ? "Your MIDI keyboard is ready to play."
        : viewModel.devices.isNotEmpty
        ? "Tap a device below to connect."
        : viewModel.shouldShowErrorButtons
        ? viewModel.midiStatus
        : "Scan for a USB or Bluetooth MIDI keyboard.";

    return Semantics(
      container: true,
      liveRegion: true,
      label: "$title. $supportingText",
      child: Container(
        key: const Key("midi_connection_overview"),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: connected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              connected ? Icons.check_circle : Icons.bluetooth_audio,
              color: connected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: ComponentDimensions.iconSizeXLarge,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    supportingText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSelector(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Column(
        children: [
          Text("MIDI Output Channel", style: theme.textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
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
                  style: theme.textTheme.titleLarge,
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Center(
      child: FilledButton.tonalIcon(
        onPressed: () => viewModel.retrySetup(),
        icon: const Icon(Icons.refresh),
        label: const Text("Retry"),
      ),
    );
  }

  Widget _buildResetInfo() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              "Try a physical device, a USB connection, or a virtual MIDI device if Bluetooth is unavailable.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Available keyboards",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Spacing.sm),
        ...(viewModel.devices.map(
          (device) => MidiDeviceListTile(
            device: device,
            deviceIcon: viewModel.getDeviceIconForType(device.type),
            onTap: () => viewModel.connectToDevice(device, _showSnackBar),
            onOpenController: () => _openDeviceController(device, viewModel),
          ),
        )),
      ],
    );
  }

  Widget _buildMidiActivity(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return Column(
      children: [
        const SizedBox(height: Spacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          child: ListTile(
            leading: Icon(
              Icons.graphic_eq,
              color: context.semanticColors.success,
            ),
            title: const Text("MIDI active"),
            subtitle: Text(
              viewModel.lastNote,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext context,
    MidiSettingsViewModel viewModel,
  ) {
    return FloatingActionButton(
      key: const Key("midi_settings_scan_fab"),
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
          settings: RouteSettings(name: "${preparedDevice.name} Controller"),
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
