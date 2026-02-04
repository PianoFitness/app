import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:logging/logging.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";
import "package:piano_fitness/domain/models/midi_channel.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// Implementation of IMidiRepository wrapping MidiConnectionService
///
/// Wraps the singleton MidiConnectionService to provide repository interface.
/// MidiConnectionService maintains its singleton pattern internally.
///
/// This implementation provides raw MIDI data via [midiDataStream].
/// MIDI parsing should be done using domain services (e.g., MidiService),
/// and state management should be handled in the application layer.
class MidiRepositoryImpl implements IMidiRepository {
  MidiRepositoryImpl({
    this.maxConnectionAttempts = 5,
    this.initialRetryDelayMs = 200,
    this.retryDelayMultiplier = 2,
    MidiConnectionService? service,
    midi_cmd.MidiCommand? midiCommand,
  }) : _service = service ?? MidiConnectionService(),
       _midiCommand = midiCommand ?? midi_cmd.MidiCommand();

  final MidiConnectionService _service;
  final midi_cmd.MidiCommand _midiCommand;
  final StreamController<Uint8List> _midiDataController =
      StreamController<Uint8List>.broadcast();

  /// Tracks all handlers registered via registerDataHandler() for cleanup in dispose()
  final Set<void Function(Uint8List)> _registeredHandlers = {};

  /// Maximum number of connection attempts before giving up
  final int maxConnectionAttempts;

  /// Initial delay in milliseconds before retrying connection
  final int initialRetryDelayMs;

  /// Multiplier for exponential backoff (delay *= multiplier each attempt)
  final int retryDelayMultiplier;

  static final Logger _log = Logger("MidiRepositoryImpl");

  /// Initializes the MIDI repository and starts listening for MIDI data.
  ///
  /// This method must be called after construction to activate MIDI listening.
  /// It starts the MidiConnectionService which will distribute MIDI data to
  /// all registered handlers.
  ///
  /// Implements retry with exponential backoff for robust connection handling.
  Future<void> initialize() async {
    await _connectWithRetry();
  }

  /// Attempts to connect with exponential backoff retry logic.
  ///
  /// Retries up to [maxConnectionAttempts] times with increasing delays.
  /// The delay follows an exponential backoff pattern:
  /// delay = initialRetryDelayMs * (retryDelayMultiplier ^ attempt)
  Future<void> _connectWithRetry() async {
    var delayMs = initialRetryDelayMs;
    Object? lastError;

    for (var attempt = 0; attempt < maxConnectionAttempts; attempt++) {
      try {
        await _service.connect();
        if (attempt > 0) {
          _log.info(
            "MIDI connection successful after $attempt retry attempt(s)",
          );
        }
        return;
      } catch (e) {
        lastError = e;
        _log.warning(
          "MIDI connection attempt ${attempt + 1}/$maxConnectionAttempts failed: $e",
        );

        // If this was the last attempt, rethrow the error
        if (attempt == maxConnectionAttempts - 1) {
          _log.severe(
            "MIDI connection failed after $maxConnectionAttempts attempts",
          );
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs *= retryDelayMultiplier;
      }
    }

    // Should not reach here, but throw last error as fallback
    if (lastError != null) {
      throw lastError;
    }
  }

  @override
  Stream<Uint8List> get midiDataStream => _midiDataController.stream;

  @override
  Future<List<MidiDevice>> listDevices() async {
    try {
      final devices = await _midiCommand.devices;
      return devices
              ?.map(
                (device) => MidiDevice(
                  id: device.id,
                  name: device.name,
                  type: device.type,
                  connected: device.connected,
                  inputPorts: device.inputPorts
                      .map((port) => MidiPort(id: port.id))
                      .toList(),
                  outputPorts: device.outputPorts
                      .map((port) => MidiPort(id: port.id))
                      .toList(),
                ),
              )
              .toList() ??
          [];
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error listing MIDI devices: $e");
        print(stackTrace);
      }
      return [];
    }
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    try {
      final devices = await _midiCommand.devices;
      final device = devices?.firstWhere((d) => d.id == deviceId);
      if (device != null) {
        await _midiCommand.connectToDevice(device);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error connecting to MIDI device: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error disconnecting MIDI device: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> sendData(Uint8List data) async {
    try {
      _midiCommand.sendData(data);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error sending MIDI data: $e");
        print(stackTrace);
      }
      rethrow;
    }
  }

  @override
  Future<void> sendNoteOn(int note, int velocity, int channel) async {
    // Validate channel before constructing MIDI message
    MidiChannel.validate(channel);

    final data = Uint8List.fromList([0x90 + channel, note, velocity]);
    await sendData(data);
  }

  @override
  Future<void> sendNoteOff(int note, int channel) async {
    // Validate channel before constructing MIDI message
    MidiChannel.validate(channel);

    final data = Uint8List.fromList([0x80 + channel, note, 0]);
    await sendData(data);
  }

  @override
  void registerDataHandler(void Function(Uint8List) handler) {
    // Only register with service if this is a new handler
    if (_registeredHandlers.add(handler)) {
      _service.registerDataHandler(handler);
    }
  }

  @override
  void unregisterDataHandler(void Function(Uint8List) handler) {
    // Only unregister from service if handler was actually registered
    if (_registeredHandlers.remove(handler)) {
      _service.unregisterDataHandler(handler);
    }
  }

  @override
  MidiDevice? get connectedDevice {
    // TODO(Phase 4): Implement device tracking
    // MidiConnectionService currently doesn't maintain connected device state.
    // This stub is intentionally unimplemented as no callers rely on it yet.
    // When implementing: Add _connectedDevice field to MidiConnectionService,
    // track during connect/disconnect operations, and expose via getter.
    return null;
  }

  @override
  void dispose() {
    // Unregister all tracked handlers to prevent memory leaks
    for (final handler in _registeredHandlers) {
      try {
        _service.unregisterDataHandler(handler);
      } catch (e) {
        if (kDebugMode) {
          print("Error unregistering MIDI handler: $e");
        }
      }
    }
    _registeredHandlers.clear();

    // Clean up MIDI command resources
    try {
      // Disconnect any active connections through the cached _midiCommand
      _service.disconnect().catchError((Object e) {
        if (kDebugMode) {
          print("Error disconnecting during disposal: $e");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error during MIDI cleanup: $e");
      }
    }

    // Close the stream controller
    _midiDataController.close();
  }
}
