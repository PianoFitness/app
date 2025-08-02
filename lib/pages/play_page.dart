import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:piano/piano.dart';
import 'midi_settings_page.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  String _lastNote = '';
  int _selectedChannel = 0;

  @override
  void initState() {
    super.initState();
    _setupMidiListener();
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

    if (data.length >= 3) {
      var rawStatus = status & 0xF0;
      var channel = (status & 0x0F) + 1;
      int note = data[1];
      int velocity = data[2];

      switch (rawStatus) {
        case 0x90:
          if (velocity > 0) {
            setState(() {
              _lastNote = 'Note ON: $note (Ch: $channel, Vel: $velocity)';
            });
          } else {
            setState(() {
              _lastNote = 'Note OFF: $note (Ch: $channel)';
            });
          }
          break;
        case 0x80:
          setState(() {
            _lastNote = 'Note OFF: $note (Ch: $channel)';
          });
          break;
        case 0xB0:
          setState(() {
            _lastNote = 'CC: Controller $note = $velocity (Ch: $channel)';
          });
          break;
        case 0xC0:
          setState(() {
            _lastNote = 'Program Change: $note (Ch: $channel)';
          });
          break;
        case 0xE0:
          var rawPitch = note + (velocity << 7);
          var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
          setState(() {
            _lastNote = 'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)';
          });
          break;
        default:
          setState(() {
            _lastNote = 'MIDI: Status 0x${status.toRadixString(16).toUpperCase()} Data: ${data.map((b) => '0x${b.toRadixString(16).toUpperCase()}').join(' ')}';
          });
      }
    }
  }

  void _playVirtualNote(int note) {
    try {
      NoteOnMessage(channel: _selectedChannel, note: note, velocity: 64).send();

      setState(() {
        _lastNote = 'Virtual Note ON: $note (Ch: ${_selectedChannel + 1}, Vel: 64)';
      });

      if (kDebugMode) {
        print('Sent virtual note on: $note on channel ${_selectedChannel + 1}');
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          NoteOffMessage(channel: _selectedChannel, note: note).send();
          if (kDebugMode) {
            print('Sent virtual note off: $note on channel ${_selectedChannel + 1}');
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
        var noteOnData = Uint8List.fromList([
          0x90 | _selectedChannel,
          note,
          64,
        ]);
        _midiCommand.sendData(noteOnData);

        setState(() {
          _lastNote = 'Virtual Note ON: $note (Ch: ${_selectedChannel + 1}, Vel: 64) [fallback]';
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          var noteOffData = Uint8List.fromList([
            0x80 | _selectedChannel,
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
        title: const Text('Piano Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MidiSettingsPage(),
                ),
              );
            },
            tooltip: 'MIDI Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Icon(
                        Icons.piano,
                        size: 80,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Piano Fitness',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Piano Fitness! Use the interactive piano below to practice. Configure MIDI devices through the settings icon above.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_lastNote.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.music_note,
                              color: Colors.green,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Last MIDI Activity:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _lastNote,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.blue.shade200, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Interactive Piano',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('MIDI Channel: '),
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: _selectedChannel > 0
                              ? () {
                                  setState(() {
                                    _selectedChannel--;
                                  });
                                }
                              : null,
                        ),
                        Text('${_selectedChannel + 1}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _selectedChannel < 15
                              ? () {
                                  setState(() {
                                    _selectedChannel++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    Expanded(
                      child: InteractivePiano(
                        highlightedNotes: const [],
                        naturalColor: Colors.white,
                        accidentalColor: Colors.black,
                        keyWidth: 45,
                        noteRange: NoteRange.forClefs([
                          Clef.Treble,
                          Clef.Bass,
                        ]),
                        onNotePositionTapped: (position) {
                          int midiNote = _convertNotePositionToMidi(position);
                          _playVirtualNote(midiNote);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}