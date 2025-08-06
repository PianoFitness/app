import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano/piano.dart";

/// Manages MIDI input state and provides real-time updates to the UI.
/// 
/// This class tracks active MIDI notes, recent activity, and selected MIDI channel.
/// It converts MIDI data to visual representations for the piano interface and
/// notifies listeners when the state changes.
class MidiState extends ChangeNotifier {
  final Set<int> _activeNotes = <int>{};
  String _lastNote = "";
  int _selectedChannel = 0;
  bool _hasRecentActivity = false;
  Timer? _activityTimer;

  /// The set of currently active MIDI note numbers.
  /// 
  /// Returns an unmodifiable view of notes that are currently being held down.
  /// MIDI note numbers range from 0-127.
  Set<int> get activeNotes => Set.unmodifiable(_activeNotes);
  
  /// The most recent MIDI message or note event as a human-readable string.
  String get lastNote => _lastNote;
  
  /// The currently selected MIDI channel (0-15).
  /// 
  /// MIDI channels are zero-indexed internally but typically displayed as 1-16.
  int get selectedChannel => _selectedChannel;
  
  /// Whether there has been MIDI activity in the last second.
  /// 
  /// This is used to show visual indicators of MIDI communication.
  bool get hasRecentActivity => _hasRecentActivity;

  /// Converts active MIDI notes to piano keyboard positions for highlighting.
  /// 
  /// Returns a list of [NotePosition] objects representing the keys that should
  /// be highlighted on the piano interface based on currently active notes.
  List<NotePosition> get highlightedNotePositions {
    return _activeNotes
        .map(_convertMidiToNotePosition)
        .where((position) => position != null)
        .cast<NotePosition>()
        .toList();
  }

  /// Sets the selected MIDI channel for input/output operations.
  /// 
  /// The [channel] must be in the range 0-15 (representing MIDI channels 1-16).
  /// Only updates and notifies listeners if the channel actually changes.
  void setSelectedChannel(int channel) {
    if (channel >= 0 && channel <= 15 && channel != _selectedChannel) {
      _selectedChannel = channel;
      notifyListeners();
    }
  }

  /// Handles a MIDI note on event.
  /// 
  /// Adds the note to the active notes set and updates the last note message.
  /// The [midiNote] is the MIDI note number (0-127), [velocity] is the note
  /// velocity (0-127), and [channel] is the MIDI channel (0-15).
  void noteOn(int midiNote, int velocity, int channel) {
    _activeNotes.add(midiNote);
    _lastNote = "Note ON: $midiNote (Ch: $channel, Vel: $velocity)";
    _triggerActivity();
    notifyListeners(); // Always notify for note changes
  }

  /// Handles a MIDI note off event.
  /// 
  /// Removes the note from the active notes set and updates the last note message.
  /// The [midiNote] is the MIDI note number (0-127) and [channel] is the MIDI
  /// channel (0-15).
  void noteOff(int midiNote, int channel) {
    _activeNotes.remove(midiNote);
    _lastNote = "Note OFF: $midiNote (Ch: $channel)";
    _triggerActivity();
    notifyListeners(); // Always notify for note changes
  }

  /// Updates the last note message with custom text.
  /// 
  /// This method allows setting arbitrary MIDI-related messages for display
  /// in the UI, such as control change events or system messages. The [note]
  /// parameter should be a human-readable description of the MIDI event.
  void setLastNote(String note) {
    _lastNote = note;
    _triggerActivity();
  }

  void _triggerActivity() {
    if (!_hasRecentActivity) {
      _hasRecentActivity = true;
      notifyListeners();
    }

    _activityTimer?.cancel();
    _activityTimer = Timer(const Duration(seconds: 1), () {
      _hasRecentActivity = false;
      notifyListeners();
    });
  }

  /// Clears all currently active notes.
  /// 
  /// This is useful for resetting the visual state when MIDI connections
  /// are lost or when starting fresh practice sessions.
  void clearActiveNotes() {
    if (_activeNotes.isNotEmpty) {
      _activeNotes.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }

  NotePosition? _convertMidiToNotePosition(int midiNote) {
    if (midiNote < 0 || midiNote > 127) return null;

    final octave = (midiNote ~/ 12) - 1;
    final noteInOctave = midiNote % 12;

    Note note;
    Accidental? accidental;

    switch (noteInOctave) {
      case 0:
        note = Note.C;
      case 1:
        note = Note.C;
        accidental = Accidental.Sharp;
      case 2:
        note = Note.D;
      case 3:
        note = Note.D;
        accidental = Accidental.Sharp;
      case 4:
        note = Note.E;
      case 5:
        note = Note.F;
      case 6:
        note = Note.F;
        accidental = Accidental.Sharp;
      case 7:
        note = Note.G;
      case 8:
        note = Note.G;
        accidental = Accidental.Sharp;
      case 9:
        note = Note.A;
      case 10:
        note = Note.A;
        accidental = Accidental.Sharp;
      case 11:
        note = Note.B;
      default:
        return null;
    }

    if (accidental != null) {
      return NotePosition(note: note, octave: octave, accidental: accidental);
    } else {
      return NotePosition(note: note, octave: octave);
    }
  }
}
