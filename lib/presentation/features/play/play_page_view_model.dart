import "dart:async";
import "package:flutter/foundation.dart";
import "package:piano/piano.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/application/utils/virtual_piano_utils.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/models/midi/midi_event.dart";
import "package:piano_fitness/presentation/utils/piano_range_utils.dart";

/// ViewModel for managing play page state and MIDI operations.
///
/// This class handles all business logic for the main play interface,
/// using the global MIDI state for note tracking and visual feedback
/// while coordinating with the MIDI repository for device operations.
class PlayPageViewModel extends ChangeNotifier {
  /// Creates a new PlayPageViewModel with dependency injection.
  PlayPageViewModel({
    required MidiCoordinator midiCoordinator,
    required IMidiRepository midiRepository,
    required MidiState midiState,
    int initialChannel = 0,
  }) : _midiRepository = midiRepository,
       _midiState = midiState,
       _midiChannel = initialChannel {
    _midiState.setSelectedChannel(_midiChannel);
    _midiState.addListener(_forwardMidiStateChanges);
    _subscription = midiCoordinator.subscribe(midiState, _handleMidiEvent);
  }

  final IMidiRepository _midiRepository;
  final MidiState _midiState;
  final int _midiChannel;
  late final MidiSubscription _subscription;

  /// Forwards MIDI state changes to ViewModel listeners.
  void _forwardMidiStateChanges() {
    notifyListeners();
  }

  /// Global MIDI state shared across the application.
  MidiState get midiState => _midiState;

  /// MIDI channel for input and output operations (0-15).
  int get midiChannel => _midiChannel;

  void _handleMidiEvent(MidiEvent event) {
    switch (event.type) {
      case MidiEventType.noteOn:
        _midiState.noteOn(event.data1, event.data2, event.channel);
        break;
      case MidiEventType.noteOff:
        _midiState.noteOff(event.data1, event.channel);
        break;
      case MidiEventType.controlChange:
      case MidiEventType.programChange:
      case MidiEventType.pitchBend:
      case MidiEventType.other:
        _midiState.setLastNote(event.displayMessage);
        break;
    }
  }

  /// Plays a virtual note through MIDI output.
  Future<void> playVirtualNote(int note) async {
    await VirtualPianoUtils.playVirtualNote(
      note,
      _midiRepository,
      _midiState,
      (_) {}, // No specific callback needed for play page
    );
  }

  /// Returns the fixed 49-key range (C2 to C6) for consistent layout.
  NoteRange getFixed49KeyRange() {
    return PianoRangeUtils.standard49KeyRange;
  }

  @override
  void dispose() {
    _midiState.removeListener(_forwardMidiStateChanges);
    _subscription.cancel();
    super.dispose();
  }
}
