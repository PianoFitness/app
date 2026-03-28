import "dart:typed_data";

import "package:logging/logging.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";

/// Application-layer utility for dispatching raw MIDI bytes to event handlers.
///
/// Wraps [MidiService.handleMidiData] with consistent error recovery so
/// ViewModels receive clean [MidiEvent] callbacks without owning parsing
/// logic or error-handling boilerplate. This follows the same pattern as
/// [VirtualPianoUtils], keeping domain service calls in the application layer.
class MidiDataHandler {
  MidiDataHandler._(); // Private constructor to prevent instantiation

  static final _log = Logger("MidiDataHandler");

  /// Parses [data] and dispatches each resulting event to [onEvent].
  ///
  /// - Parse-level errors are logged as severe and update [midiState] with a
  ///   user-facing message.
  /// - Errors thrown inside [onEvent] are caught, logged as warnings, and
  ///   update [midiState] so the UI reflects the failure without crashing.
  static void dispatch(
    Uint8List data,
    MidiState midiState,
    void Function(MidiEvent) onEvent,
  ) {
    try {
      MidiService.handleMidiData(data, (MidiEvent event) {
        try {
          onEvent(event);
        } catch (e, stackTrace) {
          _log.warning("Error handling MIDI event: $e", e, stackTrace);
          midiState.setLastNote("Error processing MIDI event");
        }
      });
    } catch (e, stackTrace) {
      _log.severe("Error parsing MIDI data: $e", e, stackTrace);
      midiState.setLastNote("Error parsing MIDI data");
    }
  }
}
