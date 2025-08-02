import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:piano/piano.dart';
import 'package:provider/provider.dart';
import '../models/midi_state.dart';
import 'midi_settings_page.dart';

class PlayPage extends StatefulWidget {
  final int midiChannel;

  const PlayPage({super.key, this.midiChannel = 0});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  @override
  void initState() {
    super.initState();
    _setupMidiListener();

    // Initialize the MIDI channel in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final midiState = Provider.of<MidiState>(context, listen: false);
      midiState.setSelectedChannel(widget.midiChannel);
    });
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    super.dispose();
  }

  void _setupMidiListener() {
    _midiDataSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
      if (kDebugMode) {
        print('Received MIDI data: ${packet.data}');
      }
      _handleMidiData(packet.data);
    });
  }

  void _handleMidiData(Uint8List data) {
    if (data.isEmpty) return;

    var status = data[0];

    if (status == 0xF8 || status == 0xFE) return;

    final midiState = Provider.of<MidiState>(context, listen: false);

    if (data.length >= 3) {
      var rawStatus = status & 0xF0;
      var channel = (status & 0x0F) + 1;
      int note = data[1];
      int velocity = data[2];

      switch (rawStatus) {
        case 0x90:
          if (velocity > 0) {
            midiState.noteOn(note, velocity, channel);
          } else {
            midiState.noteOff(note, channel);
          }
          break;
        case 0x80:
          midiState.noteOff(note, channel);
          break;
        case 0xB0:
          midiState.setLastNote(
            'CC: Controller $note = $velocity (Ch: $channel)',
          );
          break;
        case 0xC0:
          midiState.setLastNote('Program Change: $note (Ch: $channel)');
          break;
        case 0xE0:
          var rawPitch = note + (velocity << 7);
          var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
          midiState.setLastNote(
            'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)',
          );
          break;
        default:
          midiState.setLastNote(
            'MIDI: Status 0x${status.toRadixString(16).toUpperCase()} Data: ${data.map((b) => '0x${b.toRadixString(16).toUpperCase()}').join(' ')}',
          );
      }
    }
  }

  void _playVirtualNote(int note) {
    final midiState = Provider.of<MidiState>(context, listen: false);
    final selectedChannel = midiState.selectedChannel;

    try {
      NoteOnMessage(channel: selectedChannel, note: note, velocity: 64).send();

      midiState.setLastNote(
        'Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64)',
      );

      if (kDebugMode) {
        print('Sent virtual note on: $note on channel ${selectedChannel + 1}');
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          NoteOffMessage(channel: selectedChannel, note: note).send();
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
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error playing virtual note: $e');
      }
      try {
        var noteOnData = Uint8List.fromList([0x90 | selectedChannel, note, 64]);
        _midiCommand.sendData(noteOnData);

        midiState.setLastNote(
          'Virtual Note ON: $note (Ch: ${selectedChannel + 1}, Vel: 64) [fallback]',
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          var noteOffData = Uint8List.fromList([
            0x80 | selectedChannel,
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

  int _convertNotePositionToMidi(NotePosition position) {
    int noteOffset;
    switch (position.note) {
      case Note.C:
        noteOffset = 0;
        break;
      case Note.D:
        noteOffset = 2;
        break;
      case Note.E:
        noteOffset = 4;
        break;
      case Note.F:
        noteOffset = 5;
        break;
      case Note.G:
        noteOffset = 7;
        break;
      case Note.A:
        noteOffset = 9;
        break;
      case Note.B:
        noteOffset = 11;
        break;
    }

    if (position.accidental == Accidental.Sharp) {
      noteOffset += 1;
    } else if (position.accidental == Accidental.Flat) {
      noteOffset -= 1;
    }

    return (position.octave + 1) * 12 + noteOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.piano, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Piano Fitness'),
          ],
        ),
        actions: [
          // MIDI Activity Indicator
          Consumer<MidiState>(
            builder: (context, midiState, child) {
              return GestureDetector(
                onTap: () {
                  if (midiState.lastNote.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('MIDI: ${midiState.lastNote}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: midiState.hasRecentActivity
                        ? Colors.green
                        : Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final midiState = Provider.of<MidiState>(context, listen: false);
              final result = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (context) => MidiSettingsPage(
                    initialChannel: midiState.selectedChannel,
                  ),
                ),
              );
              if (result != null && result != midiState.selectedChannel) {
                // Channel changed, update the provider
                midiState.setSelectedChannel(result);
              }
            },
            tooltip: 'MIDI Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Educational Content Area
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 32,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Piano Practice',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Practice scales, chords, and melodies using the interactive piano below. '
                            'Connect a MIDI keyboard for enhanced learning or use the virtual keys.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              Chip(
                                label: const Text('Scales'),
                                backgroundColor: Colors.deepPurple.shade100,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                              Chip(
                                label: const Text('Chords'),
                                backgroundColor: Colors.deepPurple.shade100,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                              Chip(
                                label: const Text('Arpeggios'),
                                backgroundColor: Colors.deepPurple.shade100,
                                labelStyle: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Consumer<MidiState>(
              builder: (context, midiState, child) {
                return InteractivePiano(
                  highlightedNotes: midiState.highlightedNotePositions,
                  naturalColor: Colors.white,
                  accidentalColor: Colors.black,
                  keyWidth: 45,
                  noteRange: NoteRange.forClefs([Clef.Treble, Clef.Bass]),
                  onNotePositionTapped: (position) {
                    int midiNote = _convertNotePositionToMidi(position);
                    _playVirtualNote(midiNote);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
