import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import '../models/midi_state.dart';

class VirtualPianoUtils {
  static final Map<int, Timer> _noteOffTimers = {};
  static final MidiCommand _midiCommand = MidiCommand();

  static void playVirtualNote(
    int note,
    MidiState midiState,
    Function(int) onNotePressed, {
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
        'Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64)',
      );

      if (kDebugMode) {
        print('Sent virtual note on: $note on channel ${selectedChannel + 1}');
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
                'Sent virtual note off: $note on channel ${selectedChannel + 1}',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error sending note off: $e');
            }
          }
          // Remove the timer from the map once it's completed
          _noteOffTimers.remove(note);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing virtual note: $e');
      }
      try {
        await Future.microtask(() {
          var noteOnData = Uint8List.fromList([
            0x90 | selectedChannel,
            note,
            64,
          ]);
          _midiCommand.sendData(noteOnData);
        });

        midiState.setLastNote(
          'Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64) [fallback]',
        );

        // Cancel any existing timer for this specific note (fallback)
        _noteOffTimers[note]?.cancel();
        _noteOffTimers[note] = Timer(
          const Duration(milliseconds: 500),
          () async {
            if (mounted) {
              await Future.microtask(() {
                var noteOffData = Uint8List.fromList([
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
      } catch (fallbackError) {
        if (kDebugMode) {
          print('Fallback MIDI send also failed: $fallbackError');
        }
      }
    }

    onNotePressed(note);
  }

  static void dispose() {
    // Cancel all active note timers
    for (final timer in _noteOffTimers.values) {
      timer.cancel();
    }
    _noteOffTimers.clear();
  }
}
