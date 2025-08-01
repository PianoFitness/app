import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Fitness',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Piano Fitness'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<String>? _setupSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  List<MidiDevice> _devices = [];
  String _midiStatus = 'Initializing MIDI...';
  String _lastNote = '';
  bool _didAskForBluetoothPermissions = false;
  bool _isScanning = false;
  int _selectedChannel = 0; // MIDI channel 0-15 (displayed as 1-16)

  @override
  void initState() {
    super.initState();
    _setupMidi();
  }

  @override
  void dispose() {
    _setupSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    _midiDataSubscription?.cancel();
    super.dispose();
  }

  void _playVirtualNote(int note) {
    try {
      // Use proper MIDI message classes for more reliable sending
      NoteOnMessage(channel: _selectedChannel, note: note, velocity: 64).send();

      setState(() {
        _lastNote =
            'Virtual Note ON: $note (Ch: ${_selectedChannel + 1}, Vel: 64)';
      });

      if (kDebugMode) {
        print('Sent virtual note on: $note on channel ${_selectedChannel + 1}');
      }

      // Send note off after 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          NoteOffMessage(channel: _selectedChannel, note: note).send();
          if (kDebugMode) {
            print(
              'Sent virtual note off: $note on channel ${_selectedChannel + 1}',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error sending note off: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing virtual note: $e');
      }
      // Fallback to raw MIDI data if message classes don't work
      try {
        var noteOnData = Uint8List.fromList([
          0x90 | _selectedChannel,
          note,
          64,
        ]);
        _midiCommand.sendData(noteOnData);

        setState(() {
          _lastNote =
              'Virtual Note ON: $note (Ch: ${_selectedChannel + 1}, Vel: 64) [fallback]';
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          var noteOffData = Uint8List.fromList([
            0x80 | _selectedChannel,
            note,
            0,
          ]);
          _midiCommand.sendData(noteOffData);
        });
      } catch (fallbackError) {
        if (kDebugMode) {
          print('Fallback MIDI send also failed: $fallbackError');
        }
      }
    }
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
          title: const Text('Bluetooth Permissions Required'),
          content: const Text(
            'Piano Fitness needs Bluetooth permissions to discover and connect to MIDI devices like keyboards and controllers.\n\n'
            'Please grant permissions in the next dialog to enable MIDI functionality.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
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

  void _setupMidi() async {
    try {
      // Setup subscriptions for MIDI events
      _setupSubscription = _midiCommand.onMidiSetupChanged?.listen((
        data,
      ) async {
        if (kDebugMode) {
          print("MIDI setup changed: $data");
        }
        _updateDeviceList();
      });

      _bluetoothStateSubscription = _midiCommand.onBluetoothStateChanged.listen(
        (state) {
          if (kDebugMode) {
            print("Bluetooth state changed: $state");
          }
          setState(() {
            _midiStatus = 'Bluetooth state: $state';
          });
        },
      );

      _midiDataSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
        if (kDebugMode) {
          print('Received MIDI data: ${packet.data}');
        }
        _handleMidiData(packet.data);
      });

      // Initial device list update
      await _updateDeviceList();

      setState(() {
        _midiStatus = _devices.isEmpty
            ? 'Ready - No MIDI devices found\nTap the scan button to search for devices'
            : 'Found ${_devices.length} MIDI device(s)';
      });
    } catch (e) {
      setState(() {
        _midiStatus =
            'Error initializing MIDI: $e\n\nNote: MIDI/Bluetooth may not work on simulators. Try a physical device.';
      });
      if (kDebugMode) {
        print('MIDI setup error: $e');
      }
    }
  }

  Future<void> _updateDeviceList() async {
    try {
      var devices = await _midiCommand.devices;
      setState(() {
        _devices = devices ?? [];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating device list: $e');
      }
    }
  }

  void _handleMidiData(Uint8List data) {
    if (data.isEmpty) return;

    var status = data[0];

    // Filter out system real-time messages that we don't need to display
    if (status == 0xF8) {
      // Beat clock - ignore
      return;
    }
    if (status == 0xFE) {
      // Active sense - ignore
      return;
    }

    if (data.length >= 3) {
      var rawStatus = status & 0xF0; // Status without channel
      var channel = (status & 0x0F) + 1; // Channel 1-16
      int note = data[1];
      int velocity = data[2];

      switch (rawStatus) {
        case 0x90: // Note On
          if (velocity > 0) {
            setState(() {
              _lastNote = 'Note ON: $note (Ch: $channel, Vel: $velocity)';
            });
          } else {
            // Note on with velocity 0 is actually note off
            setState(() {
              _lastNote = 'Note OFF: $note (Ch: $channel)';
            });
          }
          break;
        case 0x80: // Note Off
          setState(() {
            _lastNote = 'Note OFF: $note (Ch: $channel)';
          });
          break;
        case 0xB0: // Control Change
          setState(() {
            _lastNote = 'CC: Controller $note = $velocity (Ch: $channel)';
          });
          break;
        case 0xC0: // Program Change
          setState(() {
            _lastNote = 'Program Change: $note (Ch: $channel)';
          });
          break;
        case 0xE0: // Pitch Bend
          var rawPitch = note + (velocity << 7);
          var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
          setState(() {
            _lastNote =
                'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)';
          });
          break;
        default:
          setState(() {
            _lastNote =
                'MIDI: Status 0x${status.toRadixString(16).toUpperCase()} Data: ${data.map((b) => '0x${b.toRadixString(16).toUpperCase()}').join(' ')}';
          });
      }
    } else if (data.length >= 2) {
      // Handle 2-byte messages
      var rawStatus = status & 0xF0;
      var channel = (status & 0x0F) + 1;

      if (rawStatus == 0xC0) {
        // Program Change
        setState(() {
          _lastNote = 'Program Change: ${data[1]} (Ch: $channel)';
        });
      }
    }
  }

  Future<void> _scanForDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _midiStatus = 'Preparing to scan...';
    });

    try {
      // Ask for bluetooth permissions first
      if (mounted) {
        await _informUserAboutBluetoothPermissions(context);
      }

      // Start bluetooth central
      if (kDebugMode) {
        print("Starting Bluetooth central");
      }

      await _midiCommand.startBluetoothCentral().catchError((err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bluetooth error: $err'),
              backgroundColor: Colors.red,
            ),
          );
        }
        throw err;
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

      // Check bluetooth state and start scanning if powered on
      if (_midiCommand.bluetoothState == BluetoothState.poweredOn) {
        setState(() {
          _midiStatus = 'Scanning for MIDI devices...';
        });

        await _midiCommand.startScanningForBluetoothDevices().catchError((err) {
          if (kDebugMode) {
            print("Scanning error: $err");
          }
          throw err;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scanning for Bluetooth MIDI devices...'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        // Wait for devices to be discovered
        await Future.delayed(const Duration(seconds: 3));
        await _updateDeviceList();

        setState(() {
          _midiStatus = _devices.isEmpty
              ? 'No MIDI devices found\n\nTips:\n• Make sure your MIDI device is in pairing mode\n• Try using a physical device instead of simulator\n• Check if Bluetooth is enabled'
              : 'Found ${_devices.length} MIDI device(s)\nTap a device to connect';
        });

        // Stop scanning
        _midiCommand.stopScanningForBluetoothDevices();
      } else {
        // Handle different bluetooth states
        final messages = {
          BluetoothState.unsupported:
              'Bluetooth is not supported on this device.',
          BluetoothState.poweredOff:
              'Please switch on Bluetooth and try again.',
          BluetoothState.resetting:
              'Bluetooth is currently resetting. Try again later.',
          BluetoothState.unauthorized:
              'This app needs Bluetooth permissions. Please open Settings, find Piano Fitness and assign Bluetooth access rights.',
          BluetoothState.unknown:
              'Bluetooth is not ready yet. Try again later.',
          BluetoothState.other: 'Unknown Bluetooth error occurred.',
        };

        String errorMessage =
            messages[_midiCommand.bluetoothState] ??
            'Unknown Bluetooth state: ${_midiCommand.bluetoothState}';

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
    } catch (e) {
      String errorMessage = 'Error scanning for devices: $e';

      if (e.toString().contains('bluetoothNotAvailable')) {
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
        print('Scan error: $e');
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _retrySetup() async {
    setState(() {
      _midiStatus = 'Retrying MIDI setup...';
      _devices.clear();
      _lastNote = '';
      _isScanning = false;
      _didAskForBluetoothPermissions = false; // Reset permission flag
    });
    _setupMidi();
  }

  void _resetToMainScreen() {
    setState(() {
      // Reset to the default display state that shows virtual keyboard and info
      _midiStatus =
          'bluetoothNotAvailable - Reset to default mode\n\nUse the virtual piano below or tap the scan button to search for MIDI devices';
      _devices.clear();
      _lastNote = '';
      _isScanning = false;
      _didAskForBluetoothPermissions = false; // Reset permission flag
    });

    // Stop any ongoing scanning
    try {
      _midiCommand.stopScanningForBluetoothDevices();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping scan: $e');
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
            SnackBar(content: Text('Disconnected from ${device.name}')),
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
              content: Text('Connected to ${device.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      await _updateDeviceList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection error: ${(e as PlatformException?)?.message ?? e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDeviceController(MidiDevice device) async {
    if (!device.connected) {
      // Connect first
      await _connectToDevice(device);
      // Refresh device state
      await _updateDeviceList();
      // Find the updated device
      final updatedDevice = _devices.firstWhere(
        (d) => d.id == device.id,
        orElse: () => device,
      );
      if (!updatedDevice.connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect to device'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      device = updatedDevice;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeviceControllerPage(device: device),
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
    // This method is rerun every time setState is called, for instance as done
    // by the _scanForDevices method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.piano, size: 80, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Piano Fitness',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _midiStatus,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Show retry and reset buttons when there are errors or connection issues
              if (_midiStatus.contains('Error') ||
                  _midiStatus.contains('Cannot scan') ||
                  _midiStatus.contains('bluetoothNotAvailable') ||
                  _midiStatus.contains('Bluetooth not available') ||
                  _midiStatus.contains('No MIDI devices found'))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retrySetup,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetToMainScreen,
                      icon: const Icon(Icons.home),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (_midiStatus.contains('bluetoothNotAvailable') ||
                  _midiStatus.contains('Bluetooth not available'))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info, color: Colors.orange, size: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'Alternative Options:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Use a physical iPhone/iPad\n'
                        '• Connect USB MIDI keyboard\n'
                        '• Use virtual MIDI devices\n'
                        '• Enable on-screen piano for testing',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              if (_devices.isNotEmpty) ...[
                const Text(
                  'MIDI Devices:',
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
                        'Type: ${device.type}\n'
                        'Inputs: ${device.inputPorts.length} | Outputs: ${device.outputPorts.length}\n'
                        'ID: ${device.id}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_deviceIconForType(device.type)),
                          if (device.connected)
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => _openDeviceController(device),
                              tooltip: 'Open device controller',
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
                  'Tap a device to connect/disconnect\nLong press or tap ⚙️ on connected devices for controller',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                // Show MIDI activity when devices are connected
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
                          'MIDI Activity:',
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
              if (_devices.isEmpty &&
                  (_midiStatus.contains('bluetoothNotAvailable') ||
                      _midiStatus.contains('Bluetooth not available')))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Virtual Piano (for testing)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Channel selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('MIDI Channel: '),
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
                          Text('${_selectedChannel + 1}'),
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
                      const SizedBox(height: 8),
                      if (_lastNote.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _lastNote,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Black keys (sharps) - positioned above white keys
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                          ), // Reduced offset for better alignment
                          _buildPianoKey('C#', 61, Colors.black),
                          _buildPianoKey('D#', 63, Colors.black),
                          const SizedBox(
                            width: 40,
                          ), // Reduced gap for E (no sharp)
                          _buildPianoKey('F#', 66, Colors.black),
                          _buildPianoKey('G#', 68, Colors.black),
                          _buildPianoKey('A#', 70, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // White keys (naturals) - positioned below black keys
                      Wrap(
                        spacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          // White keys (C, D, E, F, G, A, B)
                          _buildPianoKey('C', 60, Colors.white),
                          _buildPianoKey('D', 62, Colors.white),
                          _buildPianoKey('E', 64, Colors.white),
                          _buildPianoKey('F', 65, Colors.white),
                          _buildPianoKey('G', 67, Colors.white),
                          _buildPianoKey('A', 69, Colors.white),
                          _buildPianoKey('B', 71, Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              // Add some bottom padding to ensure content doesn't get hidden behind FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show a reset FAB when in error states
          if (_midiStatus.contains('Error') ||
              _midiStatus.contains('Cannot scan') ||
              _midiStatus.contains('bluetoothNotAvailable') ||
              _midiStatus.contains('Bluetooth not available'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                heroTag: "reset", // Unique hero tag to avoid conflicts
                mini: true,
                onPressed: _resetToMainScreen,
                tooltip: 'Reset to main screen',
                backgroundColor: Colors.grey,
                child: const Icon(Icons.home),
              ),
            ),
          // Main scan/retry FAB
          FloatingActionButton(
            heroTag: "main", // Unique hero tag to avoid conflicts
            onPressed: _isScanning
                ? null
                : (_midiStatus.contains('Error') ||
                          _midiStatus.contains('Cannot scan') ||
                          _midiStatus.contains('bluetoothNotAvailable') ||
                          _midiStatus.contains('Bluetooth not available')
                      ? _retrySetup
                      : _scanForDevices),
            tooltip: _isScanning
                ? 'Scanning...'
                : (_midiStatus.contains('Error') ||
                          _midiStatus.contains('Cannot scan') ||
                          _midiStatus.contains('bluetoothNotAvailable') ||
                          _midiStatus.contains('Bluetooth not available')
                      ? 'Retry MIDI setup'
                      : 'Scan for MIDI devices'),
            backgroundColor: _isScanning ? Colors.grey : null,
            child: _isScanning
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : Icon(
                    _midiStatus.contains('Error') ||
                            _midiStatus.contains('Cannot scan') ||
                            _midiStatus.contains('bluetoothNotAvailable') ||
                            _midiStatus.contains('Bluetooth not available')
                        ? Icons.refresh
                        : Icons.bluetooth_searching,
                  ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildPianoKey(String note, int midiNote, Color color) {
    return GestureDetector(
      onTap: () => _playVirtualNote(midiNote),
      child: Container(
        width: 40,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            note,
            style: TextStyle(
              color: color == Colors.white ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Device Controller Page - inspired by the example's controller.dart
class DeviceControllerPage extends StatefulWidget {
  final MidiDevice device;

  const DeviceControllerPage({super.key, required this.device});

  @override
  State<DeviceControllerPage> createState() => _DeviceControllerPageState();
}

class _DeviceControllerPageState extends State<DeviceControllerPage> {
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  int _selectedChannel = 0; // 0-15
  int _ccController = 1; // Modulation wheel
  int _ccValue = 0;
  int _programNumber = 0;
  double _pitchBend = 0.0;
  String _lastReceivedMessage = 'No MIDI data received yet';

  @override
  void initState() {
    super.initState();
    _setupMidiListener();
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    super.dispose();
  }

  void _setupMidiListener() {
    _midiDataSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
      if (packet.device.id == widget.device.id) {
        _processMidiData(packet.data);
      }
    });
  }

  void _processMidiData(Uint8List data) {
    if (data.isEmpty) return;

    var status = data[0];

    // Filter out system real-time messages
    if (status == 0xF8 || status == 0xFE) return;

    setState(() {
      if (data.length >= 3) {
        var rawStatus = status & 0xF0;
        var channel = (status & 0x0F) + 1;
        var data1 = data[1];
        var data2 = data[2];

        switch (rawStatus) {
          case 0x90: // Note On
            _lastReceivedMessage =
                'Note ON: $data1 (Ch: $channel, Vel: $data2)';
            break;
          case 0x80: // Note Off
            _lastReceivedMessage = 'Note OFF: $data1 (Ch: $channel)';
            break;
          case 0xB0: // Control Change
            _lastReceivedMessage =
                'CC: Controller $data1 = $data2 (Ch: $channel)';
            if (channel - 1 == _selectedChannel && data1 == _ccController) {
              _ccValue = data2;
            }
            break;
          case 0xC0: // Program Change
            _lastReceivedMessage = 'Program Change: $data1 (Ch: $channel)';
            if (channel - 1 == _selectedChannel) {
              _programNumber = data1;
            }
            break;
          case 0xE0: // Pitch Bend
            var rawPitch = data1 + (data2 << 7);
            var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
            _lastReceivedMessage =
                'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)';
            if (channel - 1 == _selectedChannel) {
              _pitchBend = pitchValue;
            }
            break;
        }
      }
    });
  }

  void _sendControlChange() {
    try {
      CCMessage(
        channel: _selectedChannel,
        controller: _ccController,
        value: _ccValue,
      ).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending CC: $e');
      }
    }
  }

  void _sendProgramChange() {
    try {
      PCMessage(channel: _selectedChannel, program: _programNumber).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending PC: $e');
      }
    }
  }

  void _sendPitchBend() {
    try {
      PitchBendMessage(channel: _selectedChannel, bend: _pitchBend).send();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending pitch bend: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.device.name} Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${widget.device.name}'),
                  Text('Type: ${widget.device.type}'),
                  Text('ID: ${widget.device.id}'),
                  Text('Connected: ${widget.device.connected ? "Yes" : "No"}'),
                  Text('Inputs: ${widget.device.inputPorts.length}'),
                  Text('Outputs: ${widget.device.outputPorts.length}'),
                ],
              ),
            ),
          ),

          // Last received message
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Received MIDI Message',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_lastReceivedMessage),
                ],
              ),
            ),
          ),

          // Channel Selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MIDI Channel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: _selectedChannel > 0
                            ? () => setState(() => _selectedChannel--)
                            : null,
                      ),
                      Text(
                        '${_selectedChannel + 1}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: _selectedChannel < 15
                            ? () => setState(() => _selectedChannel++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Control Change
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control Change (CC)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Controller: '),
                      Expanded(
                        child: Slider(
                          value: _ccController.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _ccController.toString(),
                          onChanged: (value) =>
                              setState(() => _ccController = value.toInt()),
                        ),
                      ),
                      Text(_ccController.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Value: '),
                      Expanded(
                        child: Slider(
                          value: _ccValue.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _ccValue.toString(),
                          onChanged: (value) {
                            setState(() => _ccValue = value.toInt());
                            _sendControlChange();
                          },
                        ),
                      ),
                      Text(_ccValue.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Program Change
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Change',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Program: '),
                      Expanded(
                        child: Slider(
                          value: _programNumber.toDouble(),
                          min: 0,
                          max: 127,
                          divisions: 127,
                          label: _programNumber.toString(),
                          onChanged: (value) {
                            setState(() => _programNumber = value.toInt());
                            _sendProgramChange();
                          },
                        ),
                      ),
                      Text(_programNumber.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Pitch Bend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pitch Bend',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _pitchBend,
                    min: -1.0,
                    max: 1.0,
                    divisions: 100,
                    label: _pitchBend.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() => _pitchBend = value);
                      _sendPitchBend();
                    },
                    onChangeEnd: (_) {
                      // Reset to center when released
                      setState(() => _pitchBend = 0.0);
                      _sendPitchBend();
                    },
                  ),
                  Center(child: Text(_pitchBend.toStringAsFixed(2))),
                ],
              ),
            ),
          ),

          // Virtual Piano
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Virtual Piano',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Black keys (sharps) - positioned above white keys
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                      ), // Reduced offset for better alignment
                      _buildDevicePianoKey(61, Colors.black), // C#
                      _buildDevicePianoKey(63, Colors.black), // D#
                      const SizedBox(width: 40), // Reduced gap for E (no sharp)
                      _buildDevicePianoKey(66, Colors.black), // F#
                      _buildDevicePianoKey(68, Colors.black), // G#
                      _buildDevicePianoKey(70, Colors.black), // A#
                    ],
                  ),
                  const SizedBox(height: 8),
                  // White keys (naturals) - positioned below black keys
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      // One octave of white keys
                      for (int note = 60; note <= 71; note += 2)
                        _buildDevicePianoKey(note, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicePianoKey(int midiNote, Color color) {
    final noteNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final noteName = noteNames[midiNote % 12];

    return GestureDetector(
      onTap: () {
        try {
          NoteOnMessage(
            channel: _selectedChannel,
            note: midiNote,
            velocity: 64,
          ).send();
          Future.delayed(const Duration(milliseconds: 500), () {
            NoteOffMessage(channel: _selectedChannel, note: midiNote).send();
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error sending note: $e');
          }
        }
      },
      child: Container(
        width: 40,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
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
