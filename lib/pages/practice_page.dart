import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:piano/piano.dart';
import 'package:provider/provider.dart';
import '../models/midi_state.dart';
import '../models/practice_session.dart';
import '../services/midi_service.dart';
import '../utils/note_utils.dart';
import '../utils/piano_range_utils.dart';
import '../utils/virtual_piano_utils.dart';
import '../widgets/midi_status_indicator.dart';
import '../widgets/practice_progress_display.dart';
import '../widgets/practice_settings_panel.dart';

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
  late PracticeSession _practiceSession;
  List<NotePosition> _highlightedNotes = [];

  @override
  void initState() {
    super.initState();
    _practiceSession = PracticeSession(
      onExerciseCompleted: _completeExercise,
      onHighlightedNotesChanged: (notes) {
        setState(() {
          _highlightedNotes = notes;
        });
      },
    );
    _practiceSession.setPracticeMode(widget.initialMode);
    _setupMidiListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final midiState = Provider.of<MidiState>(context, listen: false);
      midiState.setSelectedChannel(widget.midiChannel);
    });
  }

  @override
  void dispose() {
    _midiDataSubscription?.cancel();
    VirtualPianoUtils.dispose();
    super.dispose();
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
          _practiceSession.handleNotePressed(event.data1);
          break;
        case MidiEventType.noteOff:
          midiState.noteOff(event.data1, event.channel);
          _practiceSession.handleNoteReleased(event.data1);
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

  void _completeExercise() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise completed! Well done!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startPractice() {
    _practiceSession.startPractice();
  }

  void _resetPractice() {
    _practiceSession.resetPractice();
  }

  void _playVirtualNote(int note) {
    final midiState = Provider.of<MidiState>(context, listen: false);
    VirtualPianoUtils.playVirtualNote(
      note,
      midiState,
      _practiceSession.handleNotePressed,
      mounted: mounted,
    );
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
        actions: const [MidiStatusIndicator()],
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
                    PracticeSettingsPanel(
                      practiceMode: _practiceSession.practiceMode,
                      selectedKey: _practiceSession.selectedKey,
                      selectedScaleType: _practiceSession.selectedScaleType,
                      selectedRootNote: _practiceSession.selectedRootNote,
                      selectedArpeggioType: _practiceSession.selectedArpeggioType,
                      selectedArpeggioOctaves: _practiceSession.selectedArpeggioOctaves,
                      practiceActive: _practiceSession.practiceActive,
                      onStartPractice: _startPractice,
                      onResetPractice: _resetPractice,
                      onPracticeModeChanged: (mode) {
                        setState(() {
                          _practiceSession.setPracticeMode(mode);
                        });
                      },
                      onKeyChanged: (key) {
                        setState(() {
                          _practiceSession.setSelectedKey(key);
                        });
                      },
                      onScaleTypeChanged: (type) {
                        setState(() {
                          _practiceSession.setSelectedScaleType(type);
                        });
                      },
                      onRootNoteChanged: (rootNote) {
                        setState(() {
                          _practiceSession.setSelectedRootNote(rootNote);
                        });
                      },
                      onArpeggioTypeChanged: (type) {
                        setState(() {
                          _practiceSession.setSelectedArpeggioType(type);
                        });
                      },
                      onArpeggioOctavesChanged: (octaves) {
                        setState(() {
                          _practiceSession.setSelectedArpeggioOctaves(octaves);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    PracticeProgressDisplay(
                      practiceMode: _practiceSession.practiceMode,
                      practiceActive: _practiceSession.practiceActive,
                      currentSequence: _practiceSession.currentSequence,
                      currentNoteIndex: _practiceSession.currentNoteIndex,
                      currentChordIndex: _practiceSession.currentChordIndex,
                      currentChordProgression:
                          _practiceSession.currentChordProgression,
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
                // Calculate optimal range based on highlighted notes and exercise context
                final highlightedNotes = _highlightedNotes.isNotEmpty
                    ? _highlightedNotes
                    : midiState.highlightedNotePositions;

                NoteRange optimalRange;

                // For chord progression practice, use specialized range calculation
                if (_practiceSession.practiceMode == PracticeMode.chords &&
                    _practiceSession.currentChordProgression.isNotEmpty &&
                    _practiceSession.practiceActive) {
                  optimalRange =
                      PianoRangeUtils.calculateRangeForChordProgression(
                        _practiceSession.currentChordProgression,
                        4, // Same octave used for chord progression generation
                      );
                } else if (_practiceSession.currentSequence.isNotEmpty &&
                    _practiceSession.practiceActive) {
                  // For other exercises, optimize for the entire sequence
                  optimalRange = PianoRangeUtils.calculateRangeForExercise(
                    _practiceSession.currentSequence,
                  );
                } else {
                  // Otherwise, optimize for currently highlighted notes
                  optimalRange = PianoRangeUtils.calculateOptimalRange(
                    highlightedNotes,
                  );
                }

                return InteractivePiano(
                  highlightedNotes: highlightedNotes,
                  naturalColor: Colors.white,
                  accidentalColor: Colors.black,
                  keyWidth: PianoRangeUtils.calculateOptimalKeyWidth(
                    optimalRange,
                  ),
                  noteRange: optimalRange,
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
