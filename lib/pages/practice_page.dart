import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:piano/piano.dart';
import 'package:provider/provider.dart';
import '../models/midi_state.dart';
import '../services/midi_service.dart';
import '../utils/note_utils.dart';
import '../utils/scales.dart' as music;
import '../utils/chords.dart';

enum PracticeMode { scales, chords, arpeggios }

class PracticePage extends StatefulWidget {
  final PracticeMode initialMode;
  final int midiChannel;

  const PracticePage({
    super.key,
    this.initialMode = PracticeMode.scales,
    this.midiChannel = 0,
  });

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();
  Timer? _noteOffTimer;

  PracticeMode _practiceMode = PracticeMode.scales;
  music.Key _selectedKey = music.Key.c;
  music.ScaleType _selectedScaleType = music.ScaleType.major;

  List<int> _currentSequence = [];
  int _currentNoteIndex = 0;
  bool _practiceActive = false;
  List<NotePosition> _highlightedNotes = [];

  List<ChordInfo> _currentChordProgression = [];
  int _currentChordIndex = 0;
  final Set<int> _currentlyHeldChordNotes = {};

  @override
  void initState() {
    super.initState();
    _practiceMode = widget.initialMode;
    _setupMidiListener();
    _initializeSequence();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final midiState = Provider.of<MidiState>(context, listen: false);
      midiState.setSelectedChannel(widget.midiChannel);
    });
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    _noteOffTimer?.cancel();
    super.dispose();
  }

  void _initializeSequence() {
    if (_practiceMode == PracticeMode.scales) {
      final scale = music.ScaleDefinitions.getScale(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = scale.getFullScaleSequence(4);
      _currentNoteIndex = 0;
      _updateHighlightedNotes();
    } else if (_practiceMode == PracticeMode.chords) {
      _currentChordProgression = ChordDefinitions.getKeyTriadProgression(
        _selectedKey,
        _selectedScaleType,
      );
      _currentSequence = ChordDefinitions.getChordProgressionMidiSequence(
        _selectedKey,
        _selectedScaleType,
        4,
      );
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
      _updateHighlightedNotes();
    }
  }

  void _updateHighlightedNotes() {
    if (_currentSequence.isEmpty ||
        _currentNoteIndex >= _currentSequence.length) {
      _highlightedNotes = [];
      return;
    }

    if (_practiceMode == PracticeMode.scales) {
      final currentMidiNote = _currentSequence[_currentNoteIndex];
      final noteInfo = NoteUtils.midiNumberToNote(currentMidiNote);
      final notePosition = NoteUtils.noteToNotePosition(
        noteInfo.note,
        noteInfo.octave,
      );

      setState(() {
        _highlightedNotes = [notePosition];
      });
    } else if (_practiceMode == PracticeMode.chords) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final chordMidiNotes = currentChord.getMidiNotes(4);
        final highlightedPositions = <NotePosition>[];

        if (kDebugMode) {
          print(
            'Highlighting chord ${_currentChordIndex + 1}: ${currentChord.name} with MIDI notes: $chordMidiNotes',
          );
        }

        for (final midiNote in chordMidiNotes) {
          final noteInfo = NoteUtils.midiNumberToNote(midiNote);
          final notePosition = NoteUtils.noteToNotePosition(
            noteInfo.note,
            noteInfo.octave,
          );
          highlightedPositions.add(notePosition);
        }

        setState(() {
          _highlightedNotes = highlightedPositions;
        });
      }
    }
  }

  void _setupMidiListener() {
    final midiDataStream = _midiCommand.onMidiDataReceived;
    if (midiDataStream != null) {
      _midiDataSubscription = midiDataStream.listen(
        (packet) {
          if (kDebugMode) {
            print('Received MIDI data: ${packet.data}');
          }
          try {
            _handleMidiData(packet.data);
          } catch (e) {
            if (kDebugMode) print('MIDI data handler error: $e');
          }
        },
        onError: (error) {
          if (kDebugMode) print('MIDI data stream error: $error');
        },
      );
    } else {
      if (kDebugMode) {
        print('Warning: MIDI data stream is not available');
      }
    }
  }

  void _handleMidiData(Uint8List data) {
    final midiState = Provider.of<MidiState>(context, listen: false);

    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          midiState.noteOn(event.data1, event.data2, event.channel);
          _handleNotePressed(event.data1);
          break;
        case MidiEventType.noteOff:
          midiState.noteOff(event.data1, event.channel);
          _handleNoteReleased(event.data1);
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

  void _handleNotePressed(int midiNote) {
    if (!_practiceActive || _currentSequence.isEmpty) return;

    if (_practiceMode == PracticeMode.scales) {
      final expectedNote = _currentSequence[_currentNoteIndex];

      if (midiNote == expectedNote) {
        _currentNoteIndex++;

        if (_currentNoteIndex >= _currentSequence.length) {
          _completeExercise();
        } else {
          _updateHighlightedNotes();
        }
      }
    } else if (_practiceMode == PracticeMode.chords) {
      if (_currentChordIndex < _currentChordProgression.length) {
        final currentChord = _currentChordProgression[_currentChordIndex];
        final expectedChordNotes = currentChord.getMidiNotes(4);

        if (expectedChordNotes.contains(midiNote)) {
          _currentlyHeldChordNotes.add(midiNote);
          _checkChordCompletion();
        }
      }
    }
  }

  void _handleNoteReleased(int midiNote) {
    if (_practiceMode == PracticeMode.chords && _practiceActive) {
      _currentlyHeldChordNotes.remove(midiNote);
    }
  }

  void _checkChordCompletion() {
    if (_currentChordIndex < _currentChordProgression.length) {
      final currentChord = _currentChordProgression[_currentChordIndex];
      final expectedChordNotes = currentChord.getMidiNotes(4).toSet();

      // Check if all required chord notes are currently being held
      if (expectedChordNotes.every(
        (note) => _currentlyHeldChordNotes.contains(note),
      )) {
        _currentChordIndex++;
        _currentlyHeldChordNotes.clear();

        if (_currentChordIndex >= _currentChordProgression.length) {
          _completeExercise();
        } else {
          _updateHighlightedNotes();
        }
      }
    }
  }

  void _completeExercise() {
    setState(() {
      _practiceActive = false;
      _highlightedNotes = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise completed! Well done!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startPractice() {
    setState(() {
      _practiceActive = true;
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
    });
    _updateHighlightedNotes();
  }

  void _resetPractice() {
    setState(() {
      _practiceActive = false;
      _currentNoteIndex = 0;
      _currentChordIndex = 0;
      _currentlyHeldChordNotes.clear();
    });
    _updateHighlightedNotes();
  }

  void _playVirtualNote(int note) async {
    final midiState = Provider.of<MidiState>(context, listen: false);
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

      _noteOffTimer?.cancel();
      _noteOffTimer = Timer(const Duration(milliseconds: 500), () async {
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

        _noteOffTimer?.cancel();
        _noteOffTimer = Timer(const Duration(milliseconds: 500), () async {
          if (mounted) {
            await Future.microtask(() {
              var noteOffData = Uint8List.fromList([
                0x80 | selectedChannel,
                note,
                0,
              ]);
              _midiCommand.sendData(noteOffData);
            });
          }
        });
      } catch (fallbackError) {
        if (kDebugMode) {
          print('Fallback MIDI send also failed: $fallbackError');
        }
      }
    }

    _handleNotePressed(note);
  }

  String _getPracticeModeString(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.scales:
        return 'Scales';
      case PracticeMode.chords:
        return 'Chords';
      case PracticeMode.arpeggios:
        return 'Arpeggios';
    }
  }

  String _getKeyString(music.Key key) {
    switch (key) {
      case music.Key.c:
        return 'C';
      case music.Key.cSharp:
        return 'C#';
      case music.Key.d:
        return 'D';
      case music.Key.dSharp:
        return 'D#';
      case music.Key.e:
        return 'E';
      case music.Key.f:
        return 'F';
      case music.Key.fSharp:
        return 'F#';
      case music.Key.g:
        return 'G';
      case music.Key.gSharp:
        return 'G#';
      case music.Key.a:
        return 'A';
      case music.Key.aSharp:
        return 'A#';
      case music.Key.b:
        return 'B';
    }
  }

  String _getScaleTypeString(music.ScaleType type) {
    switch (type) {
      case music.ScaleType.major:
        return 'Major (Ionian)';
      case music.ScaleType.minor:
        return 'Natural Minor';
      case music.ScaleType.dorian:
        return 'Dorian';
      case music.ScaleType.phrygian:
        return 'Phrygian';
      case music.ScaleType.lydian:
        return 'Lydian';
      case music.ScaleType.mixolydian:
        return 'Mixolydian';
      case music.ScaleType.aeolian:
        return 'Aeolian';
      case music.ScaleType.locrian:
        return 'Locrian';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Piano Practice'),
          ],
        ),
        actions: [
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
                  margin: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 24,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Practice Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<PracticeMode>(
                                  value: _practiceMode,
                                  decoration: const InputDecoration(
                                    labelText: 'Practice Mode',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: PracticeMode.values.map((mode) {
                                    return DropdownMenuItem(
                                      value: mode,
                                      child: Text(_getPracticeModeString(mode)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _practiceMode = value;
                                        _practiceActive = false;
                                      });
                                      _initializeSequence();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<music.Key>(
                                  value: _selectedKey,
                                  decoration: const InputDecoration(
                                    labelText: 'Key',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: music.Key.values.map((key) {
                                    return DropdownMenuItem(
                                      value: key,
                                      child: Text(_getKeyString(key)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedKey = value;
                                        _practiceActive = false;
                                      });
                                      _initializeSequence();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_practiceMode == PracticeMode.scales) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<music.ScaleType>(
                              value: _selectedScaleType,
                              decoration: const InputDecoration(
                                labelText: 'Scale Type',
                                border: OutlineInputBorder(),
                              ),
                              items: music.ScaleType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getScaleTypeString(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedScaleType = value;
                                    _practiceActive = false;
                                  });
                                  _initializeSequence();
                                }
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _practiceActive
                                    ? null
                                    : _startPractice,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _resetPractice,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (_practiceActive &&
                              _currentSequence.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                children: [
                                  if (_practiceMode == PracticeMode.scales) ...[
                                    Text(
                                      'Progress: ${_currentNoteIndex + 1}/${_currentSequence.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value:
                                          (_currentNoteIndex + 1) /
                                          _currentSequence.length,
                                      backgroundColor: Colors.blue.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade600,
                                      ),
                                    ),
                                  ] else if (_practiceMode ==
                                      PracticeMode.chords) ...[
                                    Text(
                                      'Chord ${_currentChordIndex + 1}/${_currentChordProgression.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_currentChordIndex <
                                        _currentChordProgression.length) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentChordProgression[_currentChordIndex]
                                            .name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value:
                                          (_currentChordIndex + 1) /
                                          _currentChordProgression.length,
                                      backgroundColor: Colors.blue.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
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
                  highlightedNotes: _highlightedNotes.isNotEmpty
                      ? _highlightedNotes
                      : midiState.highlightedNotePositions,
                  naturalColor: Colors.white,
                  accidentalColor: Colors.black,
                  keyWidth: 45,
                  noteRange: NoteRange.forClefs([Clef.Treble, Clef.Bass]),
                  onNotePositionTapped: (position) {
                    int midiNote = NoteUtils.convertNotePositionToMidi(
                      position,
                    );
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
