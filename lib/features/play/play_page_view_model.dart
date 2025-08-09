import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_midi_command/flutter_midi_command_messages.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_service.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// including MIDI data processing, virtual piano playback, and note conversion.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with optional initial channel.
  PlayPageViewModel({int initialChannel = 0}) : _midiChannel = initialChannel {
    _setupMidiListener();
  }

  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();
  Timer? _noteOffTimer;

  final int _midiChannel;
  MidiState? _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  /// MIDI command instance for low-level operations.
  MidiCommand get midiCommand => _midiCommand;

  /// Sets the MIDI state reference for updating UI state.
  void setMidiState(MidiState midiState) {
    _midiState = midiState;
    _midiState?.setSelectedChannel(_midiChannel);
  }

  /// Sets up MIDI listener for incoming data.
  void _setupMidiListener() {
    final midiDataStream = _midiCommand.onMidiDataReceived;
    if (midiDataStream != null) {
      _midiDataSubscription = midiDataStream.listen(
        (packet) {
          if (kDebugMode) {
            print("Received MIDI data: ${packet.data}");
          }
          try {
            handleMidiData(packet.data);
          } on Exception catch (e) {
            if (kDebugMode) print("MIDI data handler error: $e");
          }
        },
        onError: (Object error) {
          if (kDebugMode) print("MIDI data stream error: $error");
        },
      );
    } else {
      if (kDebugMode) {
        print("Warning: MIDI data stream is not available");
      }
    }
  }

  /// Handles incoming MIDI data and updates state.
  void handleMidiData(Uint8List data) {
    if (_midiState == null) return;

    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          _midiState?.noteOn(event.data1, event.data2, event.channel);
          break;
        case MidiEventType.noteOff:
          _midiState?.noteOff(event.data1, event.channel);
          break;
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          _midiState?.setLastNote(event.displayMessage);
          break;
      }
    });
  }

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    if (_midiState == null) return;

    final selectedChannel = _midiState!.selectedChannel;

    try {
      await Future.microtask(() {
        NoteOnMessage(
          channel: selectedChannel,
          note: note,
          velocity: 64,
        ).send();
      });

      _midiState!.setLastNote(
        "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64)",
      );

      if (kDebugMode) {
        print("Sent virtual note on: $note on channel ${selectedChannel + 1}");
      }

      _noteOffTimer?.cancel();
      _noteOffTimer = Timer(const Duration(milliseconds: 500), () async {
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
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error playing virtual note: $e");
      }
      try {
        await _sendRawMidiNote(note, selectedChannel);
      } on Exception catch (fallbackError) {
        if (kDebugMode) {
          print("Fallback MIDI send also failed: $fallbackError");
        }
      }
    }
  }

  /// Sends raw MIDI note data as fallback method.
  Future<void> _sendRawMidiNote(int note, int selectedChannel) async {
    await Future.microtask(() {
      final noteOnData = Uint8List.fromList([
        0x90 | selectedChannel,
        note,
        64,
      ]);
      _midiCommand.sendData(noteOnData);
    });

    _midiState!.setLastNote(
      "Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64) [fallback]",
    );

    _noteOffTimer?.cancel();
    _noteOffTimer = Timer(const Duration(milliseconds: 500), () async {
      await Future.microtask(() {
        final noteOffData = Uint8List.fromList([
          0x80 | selectedChannel,
          note,
          0,
        ]);
        _midiCommand.sendData(noteOffData);
      });
    });
  }

  /// Converts NotePosition to MIDI note number.
  int convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = 0;
      case Note.D:
        noteOffset = 2;
      case Note.E:
        noteOffset = 4;
      case Note.F:
        noteOffset = 5;
      case Note.G:
        noteOffset = 7;
      case Note.A:
        noteOffset = 9;
      case Note.B:
        noteOffset = 11;
    }

    if (position.accidental == Accidental.Sharp) {
      noteOffset += 1;
    } else if (position.accidental == Accidental.Flat) {
      noteOffset -= 1;
    }

    return (position.octave + 1) * 12 + noteOffset;
  }

  /// Gets the fixed 49-key range for consistent layout.
  NoteRange getFixed49KeyRange() {
    return NoteRange(
      from: NotePosition(note: Note.C, octave: 2),
      to: NotePosition(note: Note.C, octave: 6),
    );
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    _noteOffTimer?.cancel();
    super.dispose();
  }
}
