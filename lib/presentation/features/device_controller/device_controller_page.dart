import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/presentation/features/device_controller/device_controller_view_model.dart";
import "package:piano_fitness/presentation/features/device_controller/widgets/device_controller_sections.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";
import "package:piano_fitness/presentation/widgets/main_navigation_scope.dart";

/// A detailed controller interface for a specific MIDI device.
///
/// This page provides comprehensive controls for testing and interacting
/// with a connected MIDI device, including sending test notes, monitoring
/// MIDI messages, and device-specific operations.
class DeviceControllerPage extends StatelessWidget {
  /// Creates a device controller page for the specified MIDI device.
  const DeviceControllerPage({required this.device, super.key});

  /// The MIDI device to control and monitor.
  final MidiDevice device;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceControllerViewModel(
        midiCoordinator: context.read<MidiCoordinator>(),
        midiRepository: context.read<IMidiRepository>(),
        midiState: context.read<MidiState>(),
        device: device,
      ),
      child: const _DeviceControllerView(),
    );
  }
}

class _DeviceControllerView extends StatelessWidget {
  const _DeviceControllerView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeviceControllerViewModel>();
    return Scaffold(
      appBar: MainNavigationScope.isActive(context)
          ? null
          : AppBar(
              title: Text("${viewModel.device.name} Controller"),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.md,
          Spacing.md,
          120,
        ),
        children: [
          DeviceStatusCard(viewModel: viewModel),
          const SizedBox(height: Spacing.sm),
          DeviceVirtualPianoCard(viewModel: viewModel),
          _buildLastMessageCard(context, viewModel),
          ExpansionTile(
            key: const Key("device_details_section"),
            leading: const Icon(Icons.info_outline),
            title: const Text("Device details"),
            subtitle: const Text("Identifiers and ports"),
            children: [_buildDeviceInfoCard(context, viewModel)],
          ),
          DeviceAdvancedControlsSection(viewModel: viewModel),
        ],
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
      color: context.semanticColors.success.withValues(
        alpha: OpacityValues.backgroundLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last Received MIDI Message",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.sm),
            Text(viewModel.lastReceivedMessage),
          ],
        ),
      ),
    );
  }
}
