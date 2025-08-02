import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:piano/piano.dart';

class MidiState extends ChangeNotifier {
  final Set<int> _activeNotes = <int>{};
  String _lastNote = '';
  int _selectedChannel = 0;
  bool _hasRecentActivity = false;
  Timer? _activityTimer;

  Set<int> get activeNotes => Set.unmodifiable(_activeNotes);
  String get lastNote => _lastNote;
  int get selectedChannel => _selectedChannel;
  bool get hasRecentActivity => _hasRecentActivity;

  List<NotePosition> get highlightedNotePositions {
    return _activeNotes
        .map((midiNote) => _convertMidiToNotePosition(midiNote))
        .where((position) => position != null)
        .cast<NotePosition>()
        .toList();
  }

  void setSelectedChannel(int channel) {
    if (channel >= 0 && channel <= 15 && channel != _selectedChannel) {
      _selectedChannel = channel;
      notifyListeners();
    }
  }

  void noteOn(int midiNote, int velocity, int channel) {
    _activeNotes.add(midiNote);
    _lastNote = 'Note ON: $midiNote (Ch: $channel, Vel: $velocity)';
    _triggerActivity();
  }

  void noteOff(int midiNote, int channel) {
    _activeNotes.remove(midiNote);
    _lastNote = 'Note OFF: $midiNote (Ch: $channel)';
    _triggerActivity();
  }

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

    int octave = (midiNote ~/ 12) - 1;
    int noteInOctave = midiNote % 12;

    Note note;
    Accidental? accidental;

    switch (noteInOctave) {
      case 0:
        note = Note.C;
        break;
      case 1:
        note = Note.C;
        accidental = Accidental.Sharp;
        break;
      case 2:
        note = Note.D;
        break;
      case 3:
        note = Note.D;
        accidental = Accidental.Sharp;
        break;
      case 4:
        note = Note.E;
        break;
      case 5:
        note = Note.F;
        break;
      case 6:
        note = Note.F;
        accidental = Accidental.Sharp;
        break;
      case 7:
        note = Note.G;
        break;
      case 8:
        note = Note.G;
        accidental = Accidental.Sharp;
        break;
      case 9:
        note = Note.A;
        break;
      case 10:
        note = Note.A;
        accidental = Accidental.Sharp;
        break;
      case 11:
        note = Note.B;
        break;
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
