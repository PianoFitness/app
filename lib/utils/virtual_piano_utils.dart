import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_midi_command/flutter_midi_command_messages.dart";
import "package:piano_fitness/models/midi_state.dart";

/// Utility class for playing virtual piano notes through MIDI output.
///
/// This class manages virtual note playback when users interact with the
/// on-screen piano keyboard. It handles MIDI message sending, timing,
/// and automatic note-off events with proper resource cleanup.
class VirtualPianoUtils {
  static final Map<int, Timer> _noteOffTimers = {};
  static final MidiCommand _midiCommand = MidiCommand();

  /// Plays a virtual piano note through MIDI output.
  ///
  /// This method sends MIDI note-on and note-off messages to simulate
  /// pressing a piano key. It includes fallback mechanisms for when
  /// structured MIDI messages fail.
  ///
  /// Parameters:
  /// - [note]: The MIDI note number to play (0-127)
  /// - [midiState]: The current MIDI state for channel and status updates
  /// - [onNotePressed]: Callback function to notify when note is pressed
  /// - [mounted]: Whether the calling widget is still mounted (prevents leaks)
  ///
  /// The note will automatically turn off after 500ms.
  static Future<void> playVirtualNote(
    int note,
    MidiState midiState,
    void Function(int) onNotePressed, {
    bool mounted = true,
  }) async {
    final selectedChannel = midiState.selectedChannel;

    try {
      await Future.microtask(() {
        NoteOnMessage(
          channel: selectedChannel,
          note: note,
          velocity: 64,
        ).send();
      });

      midiState.setLastNote(
        "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64)",
      );

      if (kDebugMode) {
        print("Sent virtual note on: $note on channel ${selectedChannel + 1}");
      }

      // Cancel any existing timer for this specific note
      _noteOffTimers[note]?.cancel();
      _noteOffTimers[note] = Timer(const Duration(milliseconds: 500), () async {
        if (mounted) {
          try {
            await Future.microtask(() {
              NoteOffMessage(channel: selectedChannel, note: note).send();
            });
            if (kDebugMode) {
              print(
                "Sent virtual note off: $note on channel ${selectedChannel + 1}",
              );
            }
          } on Exception catch (e) {
            if (kDebugMode) {
              print("Error sending note off: $e");
            }
          }
          // Remove the timer from the map once it's completed
          _noteOffTimers.remove(note);
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error playing virtual note: $e");
      }
      try {
        await Future.microtask(() {
          final noteOnData = Uint8List.fromList([
            0x90 | selectedChannel,
            note,
            64,
          ]);
          _midiCommand.sendData(noteOnData);
        });

        midiState.setLastNote(
          "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64) [fallback]",
        );

        // Cancel any existing timer for this specific note (fallback)
        _noteOffTimers[note]?.cancel();
        _noteOffTimers[note] = Timer(
          const Duration(milliseconds: 500),
          () async {
            if (mounted) {
              await Future.microtask(() {
                final noteOffData = Uint8List.fromList([
                  0x80 | selectedChannel,
                  note,
                  0,
                ]);
                _midiCommand.sendData(noteOffData);
              });
              // Remove the timer from the map once it's completed
              _noteOffTimers.remove(note);
            }
          },
        );
      } on Exception catch (fallbackError) {
        if (kDebugMode) {
          print("Fallback MIDI send also failed: $fallbackError");
        }
      }
    }

    onNotePressed(note);
  }

  /// Cleans up all active virtual note timers and resources.
  ///
  /// This method should be called when the virtual piano is no longer
  /// needed to prevent memory leaks and ensure all MIDI notes are properly
  /// turned off. It cancels all pending note-off timers.
  static void dispose() {
    // Cancel all active note timers
    for (final timer in _noteOffTimers.values) {
      timer.cancel();
    }
    _noteOffTimers.clear();
  }
}
