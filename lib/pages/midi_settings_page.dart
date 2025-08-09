import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/features/device_controller/device_controller_page.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:piano_fitness/services/midi_service.dart";
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
  StreamSubscription<String>? _setupSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  List<MidiDevice> _devices = [];
  String _midiStatus = "Initializing MIDI...";
  String _lastNote = "";
  bool _didAskForBluetoothPermissions = false;
  bool _isScanning = false;
  int _selectedChannel = 0;

  @override
  void initState() {
    super.initState();
    _selectedChannel = widget.initialChannel;
    _setupMidi();
  }

  @override
  void dispose() {
    _setupSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _midiDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _informUserAboutBluetoothPermissions(
    BuildContext context,
  ) async {
    if (_didAskForBluetoothPermissions) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bluetooth Permissions Required"),
          content: const Text(
            "Piano Fitness needs Bluetooth permissions to discover and connect to MIDI devices like keyboards and controllers.\n\n"
            "Please grant permissions in the next dialog to enable MIDI functionality.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Got it!"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions = true;
  }

  Future<void> _setupMidi() async {
    try {
      _setupSubscription = _midiCommand.onMidiSetupChanged?.listen(
        (data) async {
          if (kDebugMode) {
            print("MIDI setup changed: $data");
          }
          try {
            await _updateDeviceList();
          } on Exception catch (e) {
            if (kDebugMode) print("Setup subscription error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("Setup stream error: $error");
        },
      );

      _bluetoothStateSubscription = _midiCommand.onBluetoothStateChanged.listen(
        (state) {
          if (kDebugMode) {
            print("Bluetooth state changed: $state");
          }
          try {
            setState(() {
              _midiStatus = "Bluetooth state: $state";
            });
          } on Exception catch (e) {
            if (kDebugMode) print("Bluetooth state subscription error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("Bluetooth stream error: $error");
        },
      );

      _midiDataSubscription = _midiCommand.onMidiDataReceived?.listen(
        (packet) {
          if (kDebugMode) {
            print("Received MIDI data: ${packet.data}");
          }
          try {
            _handleMidiData(packet.data);
          } on Exception catch (e) {
            if (kDebugMode) print("MIDI data subscription error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("MIDI data stream error: $error");
        },
      );

      await _updateDeviceList();

      setState(() {
        _midiStatus = _devices.isEmpty
            ? "Ready - No MIDI devices found\nTap the scan button to search for devices"
            : "Found ${_devices.length} MIDI device(s)";
      });
    } on Exception catch (e) {
      setState(() {
        _midiStatus =
            "Error initializing MIDI: $e\n\nNote: MIDI/Bluetooth may not work on simulators. Try a physical device.";
      });
      if (kDebugMode) {
        print("MIDI setup error: $e");
      }
    }
  }

  Future<void> _updateDeviceList() async {
    try {
      final devices = await _midiCommand.devices;
      setState(() {
        _devices = devices ?? [];
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error updating device list: $e");
      }
    }
  }

  void _handleMidiData(Uint8List data) {
    final midiState = Provider.of<MidiState>(context, listen: false);

    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          midiState.noteOn(event.data1, event.data2, event.channel);
          setState(() {
            _lastNote = event.displayMessage;
          });
        case MidiEventType.noteOff:
          midiState.noteOff(event.data1, event.channel);
          setState(() {
            _lastNote = event.displayMessage;
          });
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          setState(() {
            _lastNote = event.displayMessage;
          });
      }
    });
  }

  Future<void> _scanForDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _midiStatus = "Preparing to scan...";
    });

    try {
      if (mounted) {
        await _informUserAboutBluetoothPermissions(context);
      }

      if (kDebugMode) {
        print("Starting Bluetooth central");
      }

      await _midiCommand.startBluetoothCentral().catchError((Object err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bluetooth error: $err"),
              backgroundColor: Colors.red,
            ),
          );
        }
        throw Exception(err);
      });

      if (kDebugMode) {
        print("Waiting for Bluetooth initialization");
      }

      await _midiCommand.waitUntilBluetoothIsInitialized().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print("Failed to initialize Bluetooth in time");
          }
        },
      );

      if (_midiCommand.bluetoothState == BluetoothState.poweredOn) {
        setState(() {
          _midiStatus = "Scanning for MIDI devices...";
        });

        await _midiCommand.startScanningForBluetoothDevices().catchError((
          Object err,
        ) {
          if (kDebugMode) {
            print("Scanning error: $err");
          }
          throw Exception(err);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Scanning for Bluetooth MIDI devices..."),
              backgroundColor: Colors.blue,
            ),
          );
        }

        await Future<void>.delayed(const Duration(seconds: 3));
        await _updateDeviceList();

        setState(() {
          _midiStatus = _devices.isEmpty
              ? "No MIDI devices found\n\nTips:\n• Make sure your MIDI device is in pairing mode\n• Try using a physical device instead of simulator\n• Check if Bluetooth is enabled"
              : "Found ${_devices.length} MIDI device(s)\nTap a device to connect";
        });

        _midiCommand.stopScanningForBluetoothDevices();
      } else {
        final messages = {
          BluetoothState.unsupported:
              "Bluetooth is not supported on this device.",
          BluetoothState.poweredOff:
              "Please switch on Bluetooth and try again.",
          BluetoothState.resetting:
              "Bluetooth is currently resetting. Try again later.",
          BluetoothState.unauthorized:
              "This app needs Bluetooth permissions. Please open Settings, find Piano Fitness and assign Bluetooth access rights.",
          BluetoothState.unknown:
              "Bluetooth is not ready yet. Try again later.",
          BluetoothState.other: "Unknown Bluetooth error occurred.",
        };

        final errorMessage =
            messages[_midiCommand.bluetoothState] ??
            "Unknown Bluetooth state: ${_midiCommand.bluetoothState}";

        setState(() {
          _midiStatus =
              'Cannot scan: $errorMessage\n\nTap "Reset" to return to main screen or "Retry" to try again';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } on Exception catch (e) {
      var errorMessage = "Error scanning for devices: $e";

      if (e.toString().contains("bluetoothNotAvailable")) {
        errorMessage +=
            '\n\n🔧 Troubleshooting:\n• Simulators don\'t support Bluetooth\n• Try running on a physical device\n• Enable Bluetooth on your device\n• Check app permissions\n\nTap "Reset" to return to main screen or "Retry" to try again';
      } else {
        errorMessage +=
            '\n\nTap "Reset" to return to main screen or "Retry" to try again';
      }

      setState(() {
        _midiStatus = errorMessage;
      });

      if (kDebugMode) {
        print("Scan error: $e");
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _retrySetup() async {
    setState(() {
      _midiStatus = "Retrying MIDI setup...";
      _devices.clear();
      _lastNote = "";
      _isScanning = false;
      _didAskForBluetoothPermissions = false;
    });
    await _setupMidi();
  }

  void _resetToMainScreen() {
    setState(() {
      _midiStatus =
          "bluetoothNotAvailable - Reset to default mode\n\nUse the virtual piano below or tap the scan button to search for MIDI devices";
      _devices.clear();
      _lastNote = "";
      _isScanning = false;
      _didAskForBluetoothPermissions = false;
    });

    try {
      _midiCommand.stopScanningForBluetoothDevices();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error stopping scan: $e");
      }
    }
  }

  Future<void> _connectToDevice(MidiDevice device) async {
    try {
      if (device.connected) {
        if (kDebugMode) {
          print("Disconnecting from ${device.name}");
        }
        _midiCommand.disconnectDevice(device);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Disconnected from ${device.name}")),
          );
        }
      } else {
        if (kDebugMode) {
          print("Connecting to ${device.name}");
        }
        await _midiCommand.connectToDevice(device);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Connected to ${device.name}"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      await _updateDeviceList();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Connection error: ${(e as PlatformException?)?.message ?? e.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDeviceController(MidiDevice device) async {
    var currentDevice = device;

    if (!currentDevice.connected) {
      await _connectToDevice(currentDevice);
      await _updateDeviceList();
      final updatedDevice = _devices.firstWhere(
        (d) => d.id == currentDevice.id,
        orElse: () => currentDevice,
      );
      if (!updatedDevice.connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to connect to device"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      currentDevice = updatedDevice;
    }

    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DeviceControllerPage(device: currentDevice),
        ),
      );
    }
  }

  IconData _deviceIconForType(String type) {
    switch (type) {
      case "native":
        return Icons.devices;
      case "network":
        return Icons.language;
      case "BLE":
        return Icons.bluetooth;
      default:
        return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("MIDI Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_selectedChannel);
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                          onPressed: _selectedChannel > 0
                              ? () {
                                  setState(() {
                                    _selectedChannel--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          "${_selectedChannel + 1}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _selectedChannel < 15
                              ? () {
                                  setState(() {
                                    _selectedChannel++;
                                  });
                                }
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
              ),
              const SizedBox(height: 16),
              Text(
                _midiStatus,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_midiStatus.contains("Error") ||
                  _midiStatus.contains("Cannot scan") ||
                  _midiStatus.contains("bluetoothNotAvailable") ||
                  _midiStatus.contains("Bluetooth not available") ||
                  _midiStatus.contains("No MIDI devices found"))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retrySetup,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetToMainScreen,
                      icon: const Icon(Icons.home),
                      label: const Text("Reset"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (_midiStatus.contains("bluetoothNotAvailable") ||
                  _midiStatus.contains("Bluetooth not available"))
                Container(
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
                ),
              if (_devices.isNotEmpty) ...[
                const Text(
                  "MIDI Devices:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...(_devices.map(
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
                          Icon(_deviceIconForType(device.type)),
                          if (device.connected)
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => _openDeviceController(device),
                              tooltip: "Open device controller",
                            ),
                        ],
                      ),
                      onTap: () => _connectToDevice(device),
                      onLongPress: device.connected
                          ? () => _openDeviceController(device)
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
                if (_devices.any((device) => device.connected) &&
                    _lastNote.isNotEmpty) ...[
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
                          _lastNote,
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
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_midiStatus.contains("Error") ||
              _midiStatus.contains("Cannot scan") ||
              _midiStatus.contains("bluetoothNotAvailable") ||
              _midiStatus.contains("Bluetooth not available"))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                heroTag: "reset",
                mini: true,
                onPressed: _resetToMainScreen,
                tooltip: "Reset to main screen",
                backgroundColor: Colors.grey,
                child: const Icon(Icons.home),
              ),
            ),
          FloatingActionButton(
            heroTag: "main",
            onPressed: _isScanning
                ? null
                : (_midiStatus.contains("Error") ||
                          _midiStatus.contains("Cannot scan") ||
                          _midiStatus.contains("bluetoothNotAvailable") ||
                          _midiStatus.contains("Bluetooth not available")
                      ? _retrySetup
                      : _scanForDevices),
            tooltip: _isScanning
                ? "Scanning..."
                : (_midiStatus.contains("Error") ||
                          _midiStatus.contains("Cannot scan") ||
                          _midiStatus.contains("bluetoothNotAvailable") ||
                          _midiStatus.contains("Bluetooth not available")
                      ? "Retry MIDI setup"
                      : "Scan for MIDI devices"),
            backgroundColor: _isScanning ? Colors.grey : null,
            child: _isScanning
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Icon(
                    _midiStatus.contains("Error") ||
                            _midiStatus.contains("Cannot scan") ||
                            _midiStatus.contains("bluetoothNotAvailable") ||
                            _midiStatus.contains("Bluetooth not available")
                        ? Icons.refresh
                        : Icons.bluetooth_searching,
                  ),
          ),
        ],
      ),
    );
  }
}
