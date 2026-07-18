import "package:flutter/foundation.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// Utility class for playing virtual piano notes through MIDI output.
///
/// This class manages virtual note playback when users interact with the
/// on-screen piano keyboard, sending real MIDI note-on/note-off pairs
/// tied to the widget's actual press/release events.
///
/// All MIDI operations are routed through the repository interface for
/// consistency, testability, and proper dependency injection.
class VirtualPianoUtils {
  static final _log = Logger("VirtualPianoUtils");

  /// Sends a MIDI note-on message for a virtual piano key press.
  ///
  /// Parameters:
  /// - [note]: The MIDI note number to play (0-127)
  /// - [midiRepository]: The MIDI repository for sending messages
  /// - [midiState]: The current MIDI state for channel and status updates
  /// - [velocity]: The note velocity (0-127), defaults to 64
  static Future<void> noteOn(
    int note,
    IMidiRepository midiRepository,
    MidiState midiState, {
    int velocity = 64,
  }) async {
    final selectedChannel = midiState.selectedChannel;
    try {
      await midiRepository.sendNoteOn(note, velocity, selectedChannel);
      midiState.setLastNote(
        "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: $velocity)",
      );
      if (kDebugMode) {
        _log.fine(
          "Sent virtual note on: $note on channel ${selectedChannel + 1}",
        );
      }
    } on Exception catch (e) {
      _log.warning("Error playing virtual note: $e");
      midiState.setLastNote("Error sending virtual note");
    }
  }

  /// Sends a MIDI note-off message for a virtual piano key release.
  ///
  /// Parameters:
  /// - [note]: The MIDI note number to release (0-127)
  /// - [midiRepository]: The MIDI repository for sending messages
  /// - [midiState]: The current MIDI state for channel and status updates
  static Future<void> noteOff(
    int note,
    IMidiRepository midiRepository,
    MidiState midiState,
  ) async {
    final selectedChannel = midiState.selectedChannel;
    try {
      await midiRepository.sendNoteOff(note, selectedChannel);
      if (kDebugMode) {
        _log.fine(
          "Sent virtual note off: $note on channel ${selectedChannel + 1}",
        );
      }
    } on Exception catch (e) {
      _log.warning("Error sending note off: $e");
    }
  }

  /// Sends "All Notes Off" on every MIDI channel to prevent stuck notes.
  ///
  /// This should be called when the virtual piano is no longer needed
  /// (e.g. page teardown) as a safety net independent of individual
  /// [noteOn]/[noteOff] calls.
  ///
  /// Requires [midiRepository] for sending MIDI control messages.
  static Future<void> dispose(IMidiRepository midiRepository) async {
    for (var channel = 0; channel < 16; channel++) {
      try {
        // Send "All Notes Off" control change message (CC 123, value 0)
        // Using raw MIDI data: [0xB0 | channel, 123, 0]
        final allNotesOffData = Uint8List.fromList([
          0xB0 | channel, // Control Change message on channel
          123, // "All Notes Off" control change number
          0, // Value (0 for All Notes Off)
        ]);
        await midiRepository.sendData(allNotesOffData);

        if (kDebugMode) {
          _log.fine("Sent All Notes Off on channel ${channel + 1}");
        }
      } on Exception catch (e) {
        _log.warning(
          "Error sending All Notes Off on channel ${channel + 1}: $e",
        );
      }
    }
  }
}
