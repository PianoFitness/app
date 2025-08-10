/// Shared MIDI mocking utilities for tests.
///
/// This module provides centralized mocking for the flutter_midi_command plugin
/// to prevent code duplication across test files and ensure consistent behavior.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

/// Centralizes all MIDI plugin mocking setup for tests.
///
/// Call this from `setUpAll()` in test files that need MIDI functionality.
/// This prevents MissingPluginException and provides consistent mock behavior.
class MidiMocks {
  static late StreamController<String> _midiSetupController;
  static late StreamController<BluetoothState> _bluetoothStateController;
  static late StreamController<MidiPacket> _midiDataController;

  /// Sets up all MIDI plugin mocks including method channels and event streams.
  ///
  /// This should be called once per test suite in `setUpAll()`.
  static void setUp() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize stream controllers for event channels
    _midiSetupController = StreamController<String>.broadcast();
    _bluetoothStateController = StreamController<BluetoothState>.broadcast();
    _midiDataController = StreamController<MidiPacket>.broadcast();

    // Mock the main flutter_midi_command method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            "plugins.invisiblewrench.com/flutter_midi_command",
          ),
          _handleMethodCall,
        );

    // Mock the event channels for MIDI data streams
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            "plugins.invisiblewrench.com/flutter_midi_command/rx_channel",
          ),
          _handleEventChannelCall,
        );
  }

  /// Cleans up resources used by the mocks.
  ///
  /// Call this from `tearDownAll()` to prevent resource leaks.
  static void tearDown() {
    _midiSetupController.close();
    _bluetoothStateController.close();
    _midiDataController.close();
  }

  /// Handles method calls to the main MIDI command channel.
  static Future<dynamic> _handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      // Device management
      case 'getDevices':
      case 'devices':
        return <Map<String, dynamic>>[];

      // Device connection
      case 'connectToDevice':
      case 'disconnectDevice':
        return true;

      // MIDI data transmission
      case 'sendData':
        return true;

      // Device scanning
      case 'scanForDevices':
        return <String, dynamic>{};
      case 'startScanning':
      case 'stopScanning':
      case 'stopScanForDevices':
        return true;

      // Bluetooth operations
      case 'startBluetoothCentral':
      case 'waitUntilBluetoothIsInitialized':
      case 'startScanningForBluetoothDevices':
      case 'stopScanningForBluetoothDevices':
        return true;

      // Lifecycle management
      case 'teardown':
        return true;

      // Stream access (returns stream controllers for tests to use)
      case 'onMidiSetupChanged':
        return _midiSetupController.stream;
      case 'onBluetoothStateChanged':
        return _bluetoothStateController.stream;
      case 'onMidiDataReceived':
        return _midiDataController.stream;

      default:
        return null;
    }
  }

  /// Handles event channel calls for MIDI streams.
  static Future<dynamic> _handleEventChannelCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'listen':
        return null;
      case 'cancel':
        return null;
      default:
        return null;
    }
  }

  // Test utilities for triggering mock events

  /// Simulates a MIDI setup change event.
  static void simulateMidiSetupChange(String setupData) {
    if (!_midiSetupController.isClosed) {
      _midiSetupController.add(setupData);
    }
  }

  /// Simulates a Bluetooth state change event.
  static void simulateBluetoothStateChange(BluetoothState state) {
    if (!_bluetoothStateController.isClosed) {
      _bluetoothStateController.add(state);
    }
  }

  /// Simulates receiving MIDI data.
  static void simulateMidiDataReceived(MidiPacket packet) {
    if (!_midiDataController.isClosed) {
      _midiDataController.add(packet);
    }
  }
}
