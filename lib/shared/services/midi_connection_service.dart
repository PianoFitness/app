import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_service.dart";

/// Centralized service for managing MIDI connections and data processing.
///
/// This service provides a single source of truth for MIDI connection management,
/// eliminating duplication across different ViewModels while providing consistent
/// MIDI data handling and connection lifecycle management.
class MidiConnectionService {
  /// Factory constructor that returns the singleton instance.
  factory MidiConnectionService() => _instance;

  /// Private constructor for singleton implementation.
  MidiConnectionService._internal();

  static final _log = Logger("MidiConnectionService");

  static final MidiConnectionService _instance =
      MidiConnectionService._internal();

  final MidiCommand _midiCommand = MidiCommand();
  StreamSubscription<MidiPacket>? _midiDataSubscription;

  final List<void Function(Uint8List data)> _dataHandlers = [];
  final List<void Function(String error)> _errorHandlers = [];

  /// Global MIDI command instance for the entire app.
  MidiCommand get midiCommand => _midiCommand;

  /// Whether the MIDI connection service is currently active.
  bool get isConnected => _midiDataSubscription != null;

  /// Starts the MIDI connection service and begins listening for MIDI data.
  ///
  /// This method sets up the global MIDI listener that will distribute
  /// MIDI data to all registered handlers throughout the application.
  Future<void> connect() async {
    if (_midiDataSubscription != null) return; // Already connected

    final midiDataStream = _midiCommand.onMidiDataReceived;
    if (midiDataStream != null) {
      _midiDataSubscription = midiDataStream.listen(
        (packet) {
          _log.fine("MIDI Connection Service received data: ${packet.data}");

          // Distribute MIDI data to all registered handlers
          for (final handler in _dataHandlers) {
            try {
              handler(packet.data);
            } on Exception catch (e) {
              _log.warning("Error in MIDI data handler: $e");
            }
          }
        },
        onError: (Object error) {
          final errorMessage = "MIDI data stream error: $error";
          _log.severe(errorMessage);

          // Notify all error handlers
          for (final errorHandler in _errorHandlers) {
            try {
              errorHandler(errorMessage);
            } on Exception catch (e) {
              _log.warning("Error in MIDI error handler: $e");
            }
          }
        },
      );
    } else {
      const warningMessage = "Warning: MIDI data stream is not available";
      _log.warning(warningMessage);

      for (final errorHandler in _errorHandlers) {
        try {
          errorHandler(warningMessage);
        } on Exception catch (e) {
          _log.warning("Error in MIDI error handler: $e");
        }
      }
    }
  }

  /// Disconnects the MIDI connection service.
  Future<void> disconnect() async {
    await _midiDataSubscription?.cancel();
    _midiDataSubscription = null;
  }

  /// Registers a handler for MIDI data events.
  ///
  /// The [handler] function will be called whenever MIDI data is received
  /// from any connected device. Multiple handlers can be registered to
  /// support different parts of the application that need MIDI data.
  void registerDataHandler(void Function(Uint8List data) handler) {
    _dataHandlers.add(handler);
  }

  /// Unregisters a previously registered MIDI data handler.
  void unregisterDataHandler(void Function(Uint8List data) handler) {
    _dataHandlers.remove(handler);
  }

  /// Registers a handler for MIDI connection errors.
  ///
  /// The [errorHandler] function will be called when MIDI connection
  /// errors occur, allowing different parts of the app to respond appropriately.
  void registerErrorHandler(void Function(String error) errorHandler) {
    _errorHandlers.add(errorHandler);
  }

  /// Unregisters a previously registered MIDI error handler.
  void unregisterErrorHandler(void Function(String error) errorHandler) {
    _errorHandlers.remove(errorHandler);
  }

  /// Convenience method for standard MIDI data processing with MidiState.
  ///
  /// This method handles the common pattern of parsing MIDI data and
  /// updating a MidiState object. It can be used as a registered handler
  /// or called directly by ViewModels.
  static void handleStandardMidiData(Uint8List data, MidiState midiState) {
    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          midiState.noteOn(event.data1, event.data2, event.channel);
          break;
        case MidiEventType.noteOff:
          midiState.noteOff(event.data1, event.channel);
          break;
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          midiState.setLastNote(event.displayMessage);
          break;
      }
    });
  }

  /// Cleans up all resources and handlers.
  ///
  /// This should be called when the application is shutting down
  /// to ensure proper cleanup of MIDI resources.
  Future<void> dispose() async {
    await disconnect();
    _dataHandlers.clear();
    _errorHandlers.clear();
  }
}
