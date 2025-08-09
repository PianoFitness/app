import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_service.dart";

/// ViewModel for managing MIDI settings state and operations.
///
/// This class handles all business logic for MIDI device discovery, connection,
/// Bluetooth management, and device configuration.
class MidiSettingsViewModel extends ChangeNotifier {
  /// Creates a new MidiSettingsViewModel with optional initial channel.
  MidiSettingsViewModel({int initialChannel = 0})
    : _selectedChannel = initialChannel {
    _setupMidi();
  }

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

  /// List of available MIDI devices.
  List<MidiDevice> get devices => List.unmodifiable(_devices);

  /// Current MIDI status message.
  String get midiStatus => _midiStatus;

  /// Last received MIDI note or message.
  String get lastNote => _lastNote;

  /// Whether the app has asked for Bluetooth permissions.
  bool get didAskForBluetoothPermissions => _didAskForBluetoothPermissions;

  /// Whether currently scanning for devices.
  bool get isScanning => _isScanning;

  /// Currently selected MIDI channel (0-15).
  int get selectedChannel => _selectedChannel;

  /// MIDI command instance for low-level operations.
  MidiCommand get midiCommand => _midiCommand;

  /// Sets the selected MIDI channel.
  void setSelectedChannel(int channel) {
    if (channel >= 0 && channel <= 15 && channel != _selectedChannel) {
      _selectedChannel = channel;
      notifyListeners();
    }
  }

  /// Increments the selected MIDI channel.
  void incrementChannel() {
    if (_selectedChannel < 15) {
      _selectedChannel++;
      notifyListeners();
    }
  }

  /// Decrements the selected MIDI channel.
  void decrementChannel() {
    if (_selectedChannel > 0) {
      _selectedChannel--;
      notifyListeners();
    }
  }

  /// Shows Bluetooth permissions dialog.
  Future<void> informUserAboutBluetoothPermissions(
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

  /// Initializes MIDI system and sets up listeners.
  Future<void> _setupMidi() async {
    try {
      _setupSubscription = _midiCommand.onMidiSetupChanged?.listen(
        (data) async {
          if (kDebugMode) {
            print("MIDI setup changed: $data");
          }
          try {
            await updateDeviceList();
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
            _midiStatus = "Bluetooth state: $state";
            notifyListeners();
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
            handleMidiData(packet.data);
          } on Exception catch (e) {
            if (kDebugMode) print("MIDI data subscription error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("MIDI data stream error: $error");
        },
      );

      await updateDeviceList();

      _midiStatus = _devices.isEmpty
          ? "Ready - No MIDI devices found\nTap the scan button to search for devices"
          : "Found ${_devices.length} MIDI device(s)";
      notifyListeners();
    } on Exception catch (e) {
      _midiStatus =
          "Error initializing MIDI: $e\n\nNote: MIDI/Bluetooth may not work on simulators. Try a physical device.";
      notifyListeners();
      if (kDebugMode) {
        print("MIDI setup error: $e");
      }
    }
  }

  /// Updates the list of available MIDI devices.
  Future<void> updateDeviceList() async {
    try {
      final devices = await _midiCommand.devices;
      _devices = devices ?? [];
      notifyListeners();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error updating device list: $e");
      }
    }
  }

  /// Handles incoming MIDI data and updates state.
  void handleMidiData(List<int> data, {MidiState? midiState}) {
    MidiService.handleMidiData(Uint8List.fromList(data), (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          midiState?.noteOn(event.data1, event.data2, event.channel);
          _lastNote = event.displayMessage;
          notifyListeners();
        case MidiEventType.noteOff:
          midiState?.noteOff(event.data1, event.channel);
          _lastNote = event.displayMessage;
          notifyListeners();
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          _lastNote = event.displayMessage;
          notifyListeners();
      }
    });
  }

  /// Scans for available MIDI devices.
  Future<void> scanForDevices(
    BuildContext context,
    Future<void> Function() showPermissionDialog,
    void Function(String message, [Color? color]) showSnackBar,
  ) async {
    if (_isScanning) return;

    _isScanning = true;
    _midiStatus = "Preparing to scan...";
    notifyListeners();

    try {
      await showPermissionDialog();

      if (kDebugMode) {
        print("Starting Bluetooth central");
      }

      await _midiCommand.startBluetoothCentral().catchError((Object err) {
        showSnackBar("Bluetooth error: $err", Colors.red);
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
        _midiStatus = "Scanning for MIDI devices...";
        notifyListeners();

        await _midiCommand.startScanningForBluetoothDevices().catchError((
          Object err,
        ) {
          if (kDebugMode) {
            print("Scanning error: $err");
          }
          throw Exception(err);
        });

        showSnackBar(
          "Scanning for Bluetooth MIDI devices...",
          Colors.blue,
        );

        await Future<void>.delayed(const Duration(seconds: 3));
        await updateDeviceList();

        _midiStatus = _devices.isEmpty
            ? "No MIDI devices found\n\nTips:\n• Make sure your MIDI device is in pairing mode\n• Try using a physical device instead of simulator\n• Check if Bluetooth is enabled"
            : "Found ${_devices.length} MIDI device(s)\nTap a device to connect";
        notifyListeners();

        _midiCommand.stopScanningForBluetoothDevices();
      } else {
        final errorMessage = _getBluetoothErrorMessage();
        _midiStatus =
            'Cannot scan: $errorMessage\n\nTap "Reset" to return to main screen or "Retry" to try again';
        notifyListeners();
        showSnackBar(errorMessage, Colors.red);
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

      _midiStatus = errorMessage;
      notifyListeners();

      if (kDebugMode) {
        print("Scan error: $e");
      }
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Retries MIDI setup after an error.
  Future<void> retrySetup() async {
    _midiStatus = "Retrying MIDI setup...";
    _devices.clear();
    _lastNote = "";
    _isScanning = false;
    _didAskForBluetoothPermissions = false;
    notifyListeners();
    await _setupMidi();
  }

  /// Resets to main screen state.
  void resetToMainScreen() {
    _midiStatus =
        "bluetoothNotAvailable - Reset to default mode\n\nUse the virtual piano below or tap the scan button to search for MIDI devices";
    _devices.clear();
    _lastNote = "";
    _isScanning = false;
    _didAskForBluetoothPermissions = false;
    notifyListeners();

    try {
      _midiCommand.stopScanningForBluetoothDevices();
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error stopping scan: $e");
      }
    }
  }

  /// Connects or disconnects from a MIDI device.
  Future<void> connectToDevice(
    MidiDevice device,
    void Function(String message, [Color? color]) showSnackBar,
  ) async {
    try {
      if (device.connected) {
        if (kDebugMode) {
          print("Disconnecting from ${device.name}");
        }
        _midiCommand.disconnectDevice(device);
        showSnackBar("Disconnected from ${device.name}");
      } else {
        if (kDebugMode) {
          print("Connecting to ${device.name}");
        }
        await _midiCommand.connectToDevice(device);
        showSnackBar(
          "Connected to ${device.name}",
          Colors.green,
        );
      }
      await updateDeviceList();
    } on Exception catch (e) {
      showSnackBar(
        "Connection error: ${(e as PlatformException?)?.message ?? e.toString()}",
        Colors.red,
      );
    }
  }

  /// Opens device controller for a connected device.
  Future<MidiDevice?> prepareDeviceForController(
    MidiDevice device,
    void Function(String message, [Color? color]) showSnackBar,
  ) async {
    var currentDevice = device;

    if (!currentDevice.connected) {
      await connectToDevice(currentDevice, showSnackBar);
      await updateDeviceList();
      final updatedDevice = _devices.firstWhere(
        (d) => d.id == currentDevice.id,
        orElse: () => currentDevice,
      );
      if (!updatedDevice.connected) {
        showSnackBar(
          "Failed to connect to device",
          Colors.red,
        );
        return null;
      }
      currentDevice = updatedDevice;
    }

    return currentDevice;
  }

  /// Returns appropriate icon for device type.
  IconData getDeviceIconForType(String type) {
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

  /// Determines if error/retry buttons should be shown.
  bool get shouldShowErrorButtons {
    return _midiStatus.contains("Error") ||
        _midiStatus.contains("Cannot scan") ||
        _midiStatus.contains("bluetoothNotAvailable") ||
        _midiStatus.contains("Bluetooth not available") ||
        _midiStatus.contains("No MIDI devices found");
  }

  /// Determines if reset info should be shown.
  bool get shouldShowResetInfo {
    return _midiStatus.contains("bluetoothNotAvailable") ||
        _midiStatus.contains("Bluetooth not available");
  }

  /// Determines if MIDI activity section should be shown.
  bool get shouldShowMidiActivity {
    return _devices.any((device) => device.connected) && _lastNote.isNotEmpty;
  }

  String _getBluetoothErrorMessage() {
    final messages = {
      BluetoothState.unsupported: "Bluetooth is not supported on this device.",
      BluetoothState.poweredOff: "Please switch on Bluetooth and try again.",
      BluetoothState.resetting:
          "Bluetooth is currently resetting. Try again later.",
      BluetoothState.unauthorized:
          "This app needs Bluetooth permissions. Please open Settings, find Piano Fitness and assign Bluetooth access rights.",
      BluetoothState.unknown: "Bluetooth is not ready yet. Try again later.",
      BluetoothState.other: "Unknown Bluetooth error occurred.",
    };

    return messages[_midiCommand.bluetoothState] ??
        "Unknown Bluetooth state: ${_midiCommand.bluetoothState}";
  }

  @override
  void dispose() {
    _setupSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _midiDataSubscription?.cancel();
    super.dispose();
  }
}
