import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano_fitness/domain/constants/musical_constants.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";
import "package:piano_fitness/domain/services/music_theory/scales.dart"
    as scales;
import "package:piano_fitness/domain/services/music_theory/chords.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/music_theory/chord_inversion_utils.dart";

/// Reference mode options for the reference page.
enum ReferenceMode {
  /// Display scales on the piano
  scales,

  /// Display chord types and inversions on the piano
  chordTypes,
}

/// ViewModel for managing reference page state and logic.
///
/// This class handles the business logic for the reference page,
/// managing scale and chord selections and providing highlighted notes
/// for the piano display. It maintains its own display state separate
/// from the shared MIDI state to prevent cross-page interference.
class ReferencePageViewModel extends ChangeNotifier {
  /// Creates a new ReferencePageViewModel.
  ReferencePageViewModel({
    required IMidiRepository midiRepository,
    required MidiState midiState,
  }) : _midiRepository = midiRepository,
       _localMidiState = midiState {
    _midiRepository.registerDataHandler(_handleMidiData);
    _initializeState();
  }

  final IMidiRepository _midiRepository;
  final MidiState _localMidiState;

  // Current selections
  ReferenceMode _selectedMode = ReferenceMode.scales;
  scales.Key _selectedKey = scales.Key.c;
  scales.ScaleType _selectedScaleType = scales.ScaleType.major;
  ChordType _selectedChordType = ChordType.major;
  ChordInversion _selectedChordInversion = ChordInversion.root;

  // Local reference highlighting state (separate from shared MIDI state)
  Set<int> _localHighlightedNotes = <int>{};

  /// The currently selected reference mode (scales or chord types).
  ReferenceMode get selectedMode => _selectedMode;

  /// The currently selected musical key.
  scales.Key get selectedKey => _selectedKey;

  /// The currently selected scale type.
  scales.ScaleType get selectedScaleType => _selectedScaleType;

  /// The currently selected chord type.
  ChordType get selectedChordType => _selectedChordType;

  /// The currently selected chord inversion.
  ChordInversion get selectedChordInversion => _selectedChordInversion;

  /// Gets the locally managed highlighted notes for this reference page.
  Set<int> get localHighlightedNotes =>
      Set.unmodifiable(_localHighlightedNotes);

  /// Gets the local MIDI state for this reference view model.
  MidiState get localMidiState => _localMidiState;

  /// Activates the reference display with current scale/chord selection.
  /// Call this when the reference page becomes visible or active.
  void activateReferenceDisplay() {
    _updateLocalHighlightedNotes();
    notifyListeners();
  }

  /// Clears the reference display, removing all highlighted notes.
  /// Call this when leaving the reference page.
  void deactivateReferenceDisplay() {
    _localHighlightedNotes.clear();
    notifyListeners();
  }

  /// Sets the selected reference mode and updates the display.
  void setSelectedMode(ReferenceMode mode) {
    if (_selectedMode != mode) {
      _applyConfigChange(() => _selectedMode = mode);
    }
  }

  /// Sets the selected key and updates the display.
  void setSelectedKey(scales.Key key) {
    if (_selectedKey != key) {
      _applyConfigChange(() => _selectedKey = key);
    }
  }

  /// Sets the selected scale type and updates the display.
  void setSelectedScaleType(scales.ScaleType type) {
    if (_selectedScaleType != type) {
      _applyConfigChange(() => _selectedScaleType = type);
    }
  }

  /// Sets the selected chord type and updates the display.
  void setSelectedChordType(ChordType type) {
    if (_selectedChordType != type) {
      _applyConfigChange(() => _selectedChordType = type);
    }
  }

  /// Sets the selected chord inversion and updates the display.
  void setSelectedChordInversion(ChordInversion inversion) {
    if (_selectedChordInversion != inversion) {
      _applyConfigChange(() => _selectedChordInversion = inversion);
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

    // Show the scale in only one octave for cleaner learning
    // Use base octave (middle octave) for consistency
    // Only include the 7 scale degrees (not the octave)
    const startOctave = MusicalConstants.baseOctave;
    var currentOctave = startOctave;

    // The scale.getNotes() returns 8 notes (including octave),
    // but we only want the 7 scale degrees for learning
    final scaleDegreesToShow = scaleNotes.take(7);

    MusicalNote? previousNote;

    for (final note in scaleDegreesToShow) {
      // If this note's index is lower than the previous note's index,
      // we've wrapped around the octave, so move to the next octave
      if (previousNote != null && note.index < previousNote.index) {
        currentOctave++;
      }

      final midiNote = NoteUtils.noteToMidiNumber(note, currentOctave);
      midiNotes.add(midiNote);
      previousNote = note;
    }

    return midiNotes;
  }

  /// Gets the MIDI note numbers for the currently selected chord.
  Set<int> _getChordMidiNotes() {
    final rootNote = ChordInversionUtils.keyToMusicalNote(_selectedKey);

    // Use the standard chord inversion utility
    final midiNotes = ChordInversionUtils.getChordMidiNotes(
      rootNote: rootNote,
      chordType: _selectedChordType,
      inversion: _selectedChordInversion,
      octave: MusicalConstants.baseOctave, // Base octave for chord display
    );

    return midiNotes.toSet();
  }

  /// Handles incoming MIDI data and updates state.
  void _handleMidiData(Uint8List data) {
    // Use domain service for MIDI parsing and update local application state
    MidiService.handleMidiData(data, (MidiEvent event) {
      switch (event.type) {
        case MidiEventType.noteOn:
          _localMidiState.noteOn(event.data1, event.data2, event.channel);
          break;
        case MidiEventType.noteOff:
          _localMidiState.noteOff(event.data1, event.channel);
          break;
        case MidiEventType.controlChange:
        case MidiEventType.programChange:
        case MidiEventType.pitchBend:
        case MidiEventType.other:
          _localMidiState.setLastNote(event.displayMessage);
          break;
      }
    });
  }

  /// Applies a config mutation, then resets/stops any ongoing operations and rebuilds the display.
  void _applyConfigChange(void Function() update) {
    update();
    _updateLocalHighlightedNotes();
    notifyListeners();
  }

  /// Initializes the state with default values through the centralized config flow.
  void _initializeState() {
    _updateLocalHighlightedNotes();
  }

  /// Updates the local highlighted notes based on current selections.
  void _updateLocalHighlightedNotes() {
    final highlightedMidiNotes = getHighlightedMidiNotes();
    _localHighlightedNotes = highlightedMidiNotes;
  }

  /// Plays a note through MIDI output.
  Future<void> playNote(int midiNote) async {
    await VirtualPianoUtils.playVirtualNote(
      midiNote,
      _localMidiState,
      (_) {}, // No specific callback needed for reference page
    );
  }

  @override
  void dispose() {
    // Clear reference display when disposing
    deactivateReferenceDisplay();
    _midiRepository.unregisterDataHandler(_handleMidiData);
    super.dispose();
  }
}
