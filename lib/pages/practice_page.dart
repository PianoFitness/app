import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:piano_fitness/models/practice_session.dart";
import "package:piano_fitness/services/midi_service.dart";
import "package:piano_fitness/utils/note_utils.dart";
import "package:piano_fitness/utils/piano_range_utils.dart";
import "package:piano_fitness/utils/virtual_piano_utils.dart";
import "package:piano_fitness/widgets/midi_status_indicator.dart";
import "package:piano_fitness/widgets/practice_progress_display.dart";
import "package:piano_fitness/widgets/practice_settings_panel.dart";
import "package:provider/provider.dart";

/// A comprehensive piano practice page with guided exercises and real-time feedback.
///
/// This page provides structured practice sessions for scales, chords, and arpeggios
/// with MIDI input support, visual feedback, and progress tracking. It integrates
/// with the PracticeSession model to manage exercise state and user progress.
class PracticePage extends StatefulWidget {
  /// Creates a new practice page with optional initial configuration.
  ///
  /// The [initialMode] determines which type of practice to start with.
  /// The [midiChannel] sets the MIDI channel for input/output operations.
  const PracticePage({
    super.key,
    this.initialMode = PracticeMode.scales,
    this.midiChannel = 0,
  });

  /// The initial practice mode to display when the page loads.
  final PracticeMode initialMode;

  /// The MIDI channel to use for input and output (0-15).
  final int midiChannel;

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
    )..setPracticeMode(widget.initialMode);
    _setupMidiListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MidiState>(
        context,
        listen: false,
      ).setSelectedChannel(widget.midiChannel);
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
            print("Received MIDI data: ${packet.data}");
          }
          try {
            _handleMidiData(packet.data);
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

  void _handleMidiData(Uint8List data) {
    final midiState = Provider.of<MidiState>(context, listen: false);

    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          midiState.noteOn(event.data1, event.data2, event.channel);
          _practiceSession.handleNotePressed(event.data1);
        case MidiEventType.noteOff:
          midiState.noteOff(event.data1, event.channel);
          _practiceSession.handleNoteReleased(event.data1);
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          midiState.setLastNote(event.displayMessage);
      }
    });
  }

  void _completeExercise() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Exercise completed! Well done!"),
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
            Text("Piano Practice"),
          ],
        ),
        actions: const [MidiStatusIndicator()],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    PracticeSettingsPanel(
                      practiceMode: _practiceSession.practiceMode,
                      selectedKey: _practiceSession.selectedKey,
                      selectedScaleType: _practiceSession.selectedScaleType,
                      selectedRootNote: _practiceSession.selectedRootNote,
                      selectedArpeggioType:
                          _practiceSession.selectedArpeggioType,
                      selectedArpeggioOctaves:
                          _practiceSession.selectedArpeggioOctaves,
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
            child: Consumer<MidiState>(
              builder: (context, midiState, child) {
                // Calculate highlighted notes for display
                final highlightedNotes = _highlightedNotes.isNotEmpty
                    ? _highlightedNotes
                    : midiState.highlightedNotePositions;

                // Calculate 49-key range centered around practice exercise
                final practiceRange = PianoRangeUtils.calculateFixed49KeyRange(
                  _practiceSession.currentSequence,
                );

                // Calculate dynamic key width based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final dynamicKeyWidth =
                    PianoRangeUtils.calculateScreenBasedKeyWidth(
                      screenWidth,
                    );

                return InteractivePiano(
                  highlightedNotes: highlightedNotes,
                  keyWidth: dynamicKeyWidth,
                  noteRange: practiceRange,
                  onNotePositionTapped: (position) {
                    final midiNote = NoteUtils.convertNotePositionToMidi(
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
