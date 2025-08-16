import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano_fitness/shared/models/midi_state.dart";
import "package:piano_fitness/shared/services/midi_connection_service.dart";
import "package:piano_fitness/shared/utils/virtual_piano_utils.dart";
import "package:piano_fitness/shared/utils/scales.dart" as scales;
import "package:piano_fitness/shared/utils/chords.dart";
import "package:piano_fitness/shared/utils/note_utils.dart";

/// Reference mode options for the reference page.
enum ReferenceMode {
  /// Display scales on the piano
  scales,

  /// Display chords on the piano
  chords,
}

/// ViewModel for managing reference page state and logic.
///
/// This class handles the business logic for the reference page,
/// managing scale and chord selections and providing highlighted notes
/// for the piano display.
class ReferencePageViewModel extends ChangeNotifier {
  /// Creates a new ReferencePageViewModel.
  ReferencePageViewModel() {
    _initializeMidiConnection();
  }

  final MidiConnectionService _midiConnectionService = MidiConnectionService();
  MidiState? _midiState;

  // Current selections
  ReferenceMode _selectedMode = ReferenceMode.scales;
  scales.Key _selectedKey = scales.Key.c;
  scales.ScaleType _selectedScaleType = scales.ScaleType.major;
  ChordType _selectedChordType = ChordType.major;
  ChordInversion _selectedChordInversion = ChordInversion.root;

  /// The currently selected reference mode (scales or chords).
  ReferenceMode get selectedMode => _selectedMode;

  /// The currently selected musical key.
  scales.Key get selectedKey => _selectedKey;

  /// The currently selected scale type.
  scales.ScaleType get selectedScaleType => _selectedScaleType;

  /// The currently selected chord type.
  ChordType get selectedChordType => _selectedChordType;

  /// The currently selected chord inversion.
  ChordInversion get selectedChordInversion => _selectedChordInversion;

  /// Sets the MIDI state reference for updating UI state.
  void setMidiState(MidiState midiState) {
    _midiState = midiState;
    _updateHighlightedNotes(); // Initialize with default scale
  }

  /// Sets the selected reference mode and updates the display.
  void setSelectedMode(ReferenceMode mode) {
    if (_selectedMode != mode) {
      _selectedMode = mode;
      _updateHighlightedNotes();
      notifyListeners();
    }
  }

  /// Sets the selected key and updates the display.
  void setSelectedKey(scales.Key key) {
    if (_selectedKey != key) {
      _selectedKey = key;
      _updateHighlightedNotes();
      notifyListeners();
    }
  }

  /// Sets the selected scale type and updates the display.
  void setSelectedScaleType(scales.ScaleType type) {
    if (_selectedScaleType != type) {
      _selectedScaleType = type;
      _updateHighlightedNotes();
      notifyListeners();
    }
  }

  /// Sets the selected chord type and updates the display.
  void setSelectedChordType(ChordType type) {
    if (_selectedChordType != type) {
      _selectedChordType = type;
      _updateHighlightedNotes();
      notifyListeners();
    }
  }

  /// Sets the selected chord inversion and updates the display.
  void setSelectedChordInversion(ChordInversion inversion) {
    if (_selectedChordInversion != inversion) {
      _selectedChordInversion = inversion;
      _updateHighlightedNotes();
      notifyListeners();
    }
  }

  /// Returns the MIDI note numbers that should be highlighted on the piano.
  Set<int> getHighlightedMidiNotes() {
    if (_selectedMode == ReferenceMode.scales) {
      return _getScaleMidiNotes();
    } else {
      return _getChordMidiNotes();
    }
  }

  /// Gets the MIDI note numbers for the currently selected scale.
  Set<int> _getScaleMidiNotes() {
    final scale = scales.ScaleDefinitions.getScale(
      _selectedKey,
      _selectedScaleType,
    );
    final scaleNotes = scale.getNotes();
    final midiNotes = <int>{};

    // Show the scale across multiple octaves for better visibility
    for (var octave = 3; octave <= 5; octave++) {
      for (final note in scaleNotes) {
        final midiNote = NoteUtils.noteToMidiNumber(note, octave);
        midiNotes.add(midiNote);
      }
    }

    return midiNotes;
  }

  /// Gets the MIDI note numbers for the currently selected chord.
  Set<int> _getChordMidiNotes() {
    final rootNote = _keyToMusicalNote(_selectedKey);
    final chord = ChordDefinitions.getChord(
      rootNote,
      _selectedChordType,
      _selectedChordInversion,
    );

    final midiNotes = <int>{};

    // Show the chord in multiple octaves for better visibility
    for (var octave = 3; octave <= 5; octave++) {
      final chordMidiNotes = chord.getMidiNotes(octave);
      midiNotes.addAll(chordMidiNotes);
    }

    return midiNotes;
  }

  /// Converts a Key enum to a MusicalNote enum.
  MusicalNote _keyToMusicalNote(scales.Key key) {
    switch (key) {
      case scales.Key.c:
        return MusicalNote.c;
      case scales.Key.cSharp:
        return MusicalNote.cSharp;
      case scales.Key.d:
        return MusicalNote.d;
      case scales.Key.dSharp:
        return MusicalNote.dSharp;
      case scales.Key.e:
        return MusicalNote.e;
      case scales.Key.f:
        return MusicalNote.f;
      case scales.Key.fSharp:
        return MusicalNote.fSharp;
      case scales.Key.g:
        return MusicalNote.g;
      case scales.Key.gSharp:
        return MusicalNote.gSharp;
      case scales.Key.a:
        return MusicalNote.a;
      case scales.Key.aSharp:
        return MusicalNote.aSharp;
      case scales.Key.b:
        return MusicalNote.b;
    }
  }

  /// Updates the highlighted notes on the piano based on current selections.
  void _updateHighlightedNotes() {
    if (_midiState == null) return;

    final highlightedMidiNotes = getHighlightedMidiNotes();
    _midiState!.setHighlightedNotes(highlightedMidiNotes);
  }

  /// Plays a note through MIDI output.
  Future<void> playNote(int midiNote) async {
    if (_midiState == null) return;

    await VirtualPianoUtils.playVirtualNote(
      midiNote,
      _midiState!,
      (_) {}, // No specific callback needed for reference page
    );
  }

  /// Initializes the MIDI connection and sets up data handling.
  void _initializeMidiConnection() {
    _midiConnectionService
      ..registerDataHandler(_handleMidiData)
      ..connect();
  }

  /// Handles incoming MIDI data and updates state.
  void _handleMidiData(Uint8List data) {
    if (_midiState == null) return;

    MidiConnectionService.handleStandardMidiData(data, _midiState!);
  }

  @override
  void dispose() {
    _midiConnectionService.unregisterDataHandler(_handleMidiData);
    super.dispose();
  }
}
