import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Represents a parsed MIDI event with all relevant information
class MidiEvent {
  final int status;
  final int channel;
  final int data1;
  final int data2;
  final MidiEventType type;
  final String displayMessage;

  const MidiEvent({
    required this.status,
    required this.channel,
    required this.data1,
    required this.data2,
    required this.type,
    required this.displayMessage,
  });
}

/// Types of MIDI events that can be parsed
enum MidiEventType {
  noteOn,
  noteOff,
  controlChange,
  programChange,
  pitchBend,
  other,
}

/// Centralized MIDI message parsing service
///
/// Handles parsing of MIDI data and converts it to structured events
/// that can be consumed by different parts of the application.
class MidiService {
  /// Parses MIDI data and calls the provided callback with the parsed event
  ///
  /// This method handles the common MIDI message parsing logic that was
  /// duplicated across multiple pages in the application.
  ///
  /// [data] - Raw MIDI data bytes
  /// [onEvent] - Callback function that receives the parsed MIDI event
  static void handleMidiData(Uint8List data, Function(MidiEvent) onEvent) {
    if (data.isEmpty) return;

    var status = data[0];

    // Skip timing clock and active sensing messages
    if (status == 0xF8 || status == 0xFE) return;

    if (data.length >= 3) {
      _parseThreeByteMessage(data, status, onEvent);
    } else if (data.length >= 2) {
      _parseTwoByteMessage(data, status, onEvent);
    }
  }

  /// Parses three-byte MIDI messages (most common)
  static void _parseThreeByteMessage(
    Uint8List data,
    int status,
    Function(MidiEvent) onEvent,
  ) {
    var rawStatus = status & 0xF0;
    var channel = (status & 0x0F) + 1;
    int data1 = data[1];
    int data2 = data[2];

    MidiEvent event;

    switch (rawStatus) {
      case 0x90: // Note On
        if (data2 > 0) {
          event = MidiEvent(
            status: status,
            channel: channel,
            data1: data1,
            data2: data2,
            type: MidiEventType.noteOn,
            displayMessage: 'Note ON: $data1 (Ch: $channel, Vel: $data2)',
          );
        } else {
          // Note On with velocity 0 is equivalent to Note Off
          event = MidiEvent(
            status: status,
            channel: channel,
            data1: data1,
            data2: data2,
            type: MidiEventType.noteOff,
            displayMessage: 'Note OFF: $data1 (Ch: $channel)',
          );
        }
        break;

      case 0x80: // Note Off
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.noteOff,
          displayMessage: 'Note OFF: $data1 (Ch: $channel)',
        );
        break;

      case 0xB0: // Control Change
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.controlChange,
          displayMessage: 'CC: Controller $data1 = $data2 (Ch: $channel)',
        );
        break;

      case 0xC0: // Program Change
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.programChange,
          displayMessage: 'Program Change: $data1 (Ch: $channel)',
        );
        break;

      case 0xE0: // Pitch Bend
        var rawPitch = data1 + (data2 << 7);
        var pitchValue = (((rawPitch) / 0x3FFF) * 2.0) - 1;
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.pitchBend,
          displayMessage:
              'Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)',
        );
        break;

      default: // Other MIDI messages
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.other,
          displayMessage:
              'MIDI: Status 0x${status.toRadixString(16).toUpperCase().padLeft(2, '0')} Data: ${data.map((b) => '0x${b.toRadixString(16).toUpperCase().padLeft(2, '0')}').join(' ')}',
        );
    }

    onEvent(event);
  }

  /// Parses two-byte MIDI messages (less common)
  static void _parseTwoByteMessage(
    Uint8List data,
    int status,
    Function(MidiEvent) onEvent,
  ) {
    var rawStatus = status & 0xF0;
    var channel = (status & 0x0F) + 1;

    if (rawStatus == 0xC0) {
      // Program Change
      var event = MidiEvent(
        status: status,
        channel: channel,
        data1: data[1],
        data2: 0,
        type: MidiEventType.programChange,
        displayMessage: 'Program Change: ${data[1]} (Ch: $channel)',
      );
      onEvent(event);
    }
  }

  /// Gets the pitch bend value as a normalized float (-1.0 to 1.0)
  /// from raw MIDI pitch bend data
  static double getPitchBendValue(int data1, int data2) {
    var rawPitch = data1 + (data2 << 7);
    return (((rawPitch) / 0x3FFF) * 2.0) - 1;
  }
}
