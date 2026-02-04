import "dart:async";
import "dart:typed_data";
import "package:logging/logging.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// Utility class for playing virtual piano notes through MIDI output.
///
/// This class manages virtual note playback when users interact with the
/// on-screen piano keyboard. It handles MIDI message sending, timing,
/// and automatic note-off events with proper resource cleanup.
///
/// All MIDI operations are routed through the repository interface for
/// consistency, testability, and proper dependency injection.
class VirtualPianoUtils {
  static final _log = Logger("VirtualPianoUtils");
  static final Map<String, Timer> _noteOffTimers = {};

  /// Plays a virtual piano note through MIDI output.
  ///
  /// This method sends MIDI note-on and note-off messages to simulate
  /// pressing a piano key via the repository interface.
  ///
  /// Parameters:
  /// - [note]: The MIDI note number to play (0-127)
  /// - [midiRepository]: The MIDI repository for sending messages
  /// - [midiState]: The current MIDI state for channel and status updates
  /// - [onNotePressed]: Callback function to notify when note is pressed
  /// - [mounted]: Whether the calling widget is still mounted (prevents leaks)
  ///
  /// The note will automatically turn off after 500ms.
  static Future<void> playVirtualNote(
    int note,
    IMidiRepository midiRepository,
    MidiState midiState,
    void Function(int) onNotePressed, {
    bool mounted = true,
  }) async {
    final selectedChannel = midiState.selectedChannel;
    const velocity = 64;

    try {
      await midiRepository.sendNoteOn(note, velocity, selectedChannel);

      midiState.setLastNote(
        "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: $velocity)",
      );

      _log.fine(
        "Sent virtual note on: $note on channel ${selectedChannel + 1}",
      );

      // Create a unique key for this note and channel combination
      final noteKey = "${note}_$selectedChannel";

      // Cancel any existing timer for this specific note
      _noteOffTimers[noteKey]?.cancel();
      _noteOffTimers[noteKey] = Timer(
        const Duration(milliseconds: 500),
        () async {
          if (mounted) {
            try {
              await midiRepository.sendNoteOff(note, selectedChannel);
              _log.fine(
                "Sent virtual note off: $note on channel ${selectedChannel + 1}",
              );
            } on Exception catch (e) {
              _log.warning("Error sending note off: $e");
            }
            // Remove the timer from the map once it's completed
            _noteOffTimers.remove(noteKey);
          }
        },
      );
    } on Exception catch (e) {
      _log.warning("Error playing virtual note: $e");
      midiState.setLastNote("Error sending virtual note");
    }

    onNotePressed(note);
  }

  /// Cleans up all active virtual note timers and resources.
  ///
  /// This method should be called when the virtual piano is no longer
  /// needed to prevent memory leaks and ensure all MIDI notes are properly
  /// turned off. It sends "All Notes Off" messages on all MIDI channels
  /// to prevent stuck notes before canceling pending note-off timers.
  ///
  /// Requires [midiRepository] for sending MIDI control messages.
  static Future<void> dispose(IMidiRepository midiRepository) async {
    // Send "All Notes Off" (CC 123) on all MIDI channels to prevent stuck notes
    // This is more comprehensive than individual NoteOff messages since we don't
    // track which channel each note was sent on
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

        _log.fine("Sent All Notes Off on channel ${channel + 1}");
      } on Exception catch (e) {
        _log.warning(
          "Error sending All Notes Off on channel ${channel + 1}: $e",
        );
      }
    }

    // Cancel all active note timers
    for (final timer in _noteOffTimers.values) {
      timer.cancel();
    }
    _noteOffTimers.clear();
  }
}
