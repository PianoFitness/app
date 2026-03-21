import "package:flutter/foundation.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_data_handler.dart";
import "package:piano_fitness/domain/models/midi/midi_event.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// A handle to a MIDI event subscription returned by [MidiCoordinator.subscribe].
///
/// Call [cancel] in the owning object's [dispose] method to unregister the
/// handler from the MIDI repository. After cancellation the subscription is
/// inert and [cancel] is safe to call again.
class MidiSubscription {
  MidiSubscription._(this._cancel);

  final void Function() _cancel;
  bool _cancelled = false;

  /// Unregisters the handler from the MIDI repository.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  void cancel() {
    if (!_cancelled) {
      _cancelled = true;
      _cancel();
    }
  }
}

/// Application-layer coordinator for MIDI event subscriptions.
///
/// Encapsulates handler registration and unregistration against
/// [IMidiRepository], delegating raw-data parsing to [MidiDataHandler].
///
/// ViewModels subscribe once in their constructor and call
/// [MidiSubscription.cancel] in [ChangeNotifier.dispose], without directly
/// importing or managing the repository handler lifecycle.
///
/// Example usage in a ViewModel:
/// ```dart
/// class MyViewModel extends ChangeNotifier {
///   MyViewModel({
///     required MidiCoordinator midiCoordinator,
///     required MidiState midiState,
///   }) {
///     _subscription = midiCoordinator.subscribe(midiState, _onMidiEvent);
///   }
///
///   late final MidiSubscription _subscription;
///
///   void _onMidiEvent(MidiEvent event) { ... }
///
///   @override
///   void dispose() {
///     _subscription.cancel();
///     super.dispose();
///   }
/// }
/// ```
class MidiCoordinator {
  /// Creates a coordinator backed by the given [repository].
  const MidiCoordinator(this._repository);

  final IMidiRepository _repository;

  /// Registers [onEvent] to receive parsed [MidiEvent]s and returns a
  /// [MidiSubscription] that cancels the registration when disposed.
  ///
  /// Raw MIDI bytes are parsed by [MidiDataHandler.dispatch]; [midiState] is
  /// updated as a side-effect of each dispatch.
  MidiSubscription subscribe(
    MidiState midiState,
    void Function(MidiEvent event) onEvent,
  ) {
    void handler(Uint8List data) {
      MidiDataHandler.dispatch(data, midiState, onEvent);
    }

    _repository.registerDataHandler(handler);
    return MidiSubscription._(() => _repository.unregisterDataHandler(handler));
  }
}
