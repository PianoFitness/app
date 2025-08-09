import "dart:typed_data";
import "package:flutter/foundation.dart";

/// Represents a parsed MIDI event with all relevant information.
///
/// This class encapsulates all the components of a MIDI message after parsing,
/// making it easier to handle different types of MIDI events consistently
/// throughout the application.
class MidiEvent {
  /// Creates a new MIDI event with all required components.
  const MidiEvent({
    required this.status,
    required this.channel,
    required this.data1,
    required this.data2,
    required this.type,
    required this.displayMessage,
  });

  /// The raw MIDI status byte including channel information.
  final int status;

  /// The MIDI channel number (1-16, human-readable format).
  final int channel;

  /// First data byte (note number, controller number, etc.).
  final int data1;

  /// Second data byte (velocity, controller value, etc.).
  final int data2;

  /// The categorized type of this MIDI event.
  final MidiEventType type;

  /// Human-readable description of this MIDI event for debugging/display.
  final String displayMessage;
}

/// Types of MIDI events that can be parsed by the MidiService.
///
/// These categories help the application respond appropriately to different
/// kinds of MIDI messages from connected devices.
enum MidiEventType {
  /// Note on message - key pressed with velocity > 0
  noteOn,

  /// Note off message - key released or note on with velocity 0
  noteOff,

  /// Control change message - knobs, sliders, pedals, etc.
  controlChange,

  /// Program change message - instrument/patch selection
  programChange,

  /// Pitch bend message - pitch wheel movement
  pitchBend,

  /// Any other MIDI message not specifically categorized above
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
  static void handleMidiData(Uint8List data, void Function(MidiEvent) onEvent) {
    if (data.isEmpty || data.length > 256) return; // Prevent oversized packets

    // Validate MIDI data bytes (must be 0-127)
    for (var i = 1; i < data.length; i++) {
      if (data[i] > 127) return; // Invalid MIDI data
    }

    final status = data[0];

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
    void Function(MidiEvent) onEvent,
  ) {
    final rawStatus = status & 0xF0;
    final channel = (status & 0x0F) + 1;
    final data1 = data[1];
    final data2 = data[2];

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
            displayMessage: "Note ON: $data1 (Ch: $channel, Vel: $data2)",
          );
        } else {
          // Note On with velocity 0 is equivalent to Note Off
          event = MidiEvent(
            status: status,
            channel: channel,
            data1: data1,
            data2: data2,
            type: MidiEventType.noteOff,
            displayMessage: "Note OFF: $data1 (Ch: $channel)",
          );
        }

      case 0x80: // Note Off
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.noteOff,
          displayMessage: "Note OFF: $data1 (Ch: $channel)",
        );

      case 0xB0: // Control Change
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.controlChange,
          displayMessage: "CC: Controller $data1 = $data2 (Ch: $channel)",
        );

      case 0xC0: // Program Change
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.programChange,
          displayMessage: "Program Change: $data1 (Ch: $channel)",
        );

      case 0xE0: // Pitch Bend
        final rawPitch = data1 + (data2 << 7);
        final pitchValue = ((rawPitch / 0x3FFF) * 2.0) - 1;
        event = MidiEvent(
          status: status,
          channel: channel,
          data1: data1,
          data2: data2,
          type: MidiEventType.pitchBend,
          displayMessage:
              "Pitch Bend: ${pitchValue.toStringAsFixed(2)} (Ch: $channel)",
        );

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
    void Function(MidiEvent) onEvent,
  ) {
    final rawStatus = status & 0xF0;
    final channel = (status & 0x0F) + 1;

    if (rawStatus == 0xC0) {
      // Program Change
      final event = MidiEvent(
        status: status,
        channel: channel,
        data1: data[1],
        data2: 0,
        type: MidiEventType.programChange,
        displayMessage: "Program Change: ${data[1]} (Ch: $channel)",
      );
      onEvent(event);
    }
  }

  /// Gets the pitch bend value as a normalized float (-1.0 to 1.0)
  /// from raw MIDI pitch bend data
  static double getPitchBendValue(int data1, int data2) {
    final rawPitch = data1 + (data2 << 7);
    return ((rawPitch / 0x3FFF) * 2.0) - 1;
  }
}
