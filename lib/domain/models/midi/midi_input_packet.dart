import "dart:typed_data";

import "package:meta/meta.dart";

/// A MIDI packet stamped at the first application boundary.
///
/// [receivedAt] is sampled from PianoFitness' monotonic input clock. The
/// plugin's [transportTimestamp] is retained only for diagnostics because its
/// epoch and units are not portable across MIDI transports.
@immutable
class MidiInputPacket {
  const MidiInputPacket({
    required this.data,
    required this.receivedAt,
    this.transportTimestamp,
  });

  final Uint8List data;
  final Duration receivedAt;
  final int? transportTimestamp;
}

/// A consumer of a MIDI packet stamped at the application input boundary.
typedef MidiInputHandler = void Function(MidiInputPacket packet);
