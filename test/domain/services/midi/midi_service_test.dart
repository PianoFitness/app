// Unit tests for MidiService.
//
// Tests the centralized MIDI message parsing functionality.

import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/services/midi/midi_service.dart";

void main() {
  group("MidiService Tests", () {
    group("handleMidiData", () {
      test("should skip empty data", () {
        var eventReceived = false;

        MidiService.handleMidiData(Uint8List(0), (event) {
          eventReceived = true;
        });

        expect(eventReceived, false);
      });

      test("should skip timing clock messages (0xF8)", () {
        var eventReceived = false;
        final data = Uint8List.fromList([0xF8]);

        MidiService.handleMidiData(data, (event) {
          eventReceived = true;
        });

        expect(eventReceived, false);
      });

      test("should skip active sensing messages (0xFE)", () {
        var eventReceived = false;
        final data = Uint8List.fromList([0xFE]);

        MidiService.handleMidiData(data, (event) {
          eventReceived = true;
        });

        expect(eventReceived, false);
      });
    });

    group("Note On Messages (0x90)", () {
      test("should parse note on message correctly", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x90,
          60,
          127,
        ]); // Note On, Middle C, max velocity, channel 1

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.noteOn);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 60);
        expect(receivedEvent!.data2, 127);
        expect(receivedEvent!.displayMessage, "Note ON: 60 (Ch: 1, Vel: 127)");
      });

      test("should parse note on with different channel", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x93,
          64,
          100,
        ]); // Note On, channel 4 (0x93 = 0x90 + 3)

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent!.channel, 4);
        expect(receivedEvent!.data1, 64);
        expect(receivedEvent!.data2, 100);
      });

      test("should treat note on with velocity 0 as note off", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x90,
          60,
          0,
        ]); // Note On with velocity 0

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent!.type, MidiEventType.noteOff);
        expect(receivedEvent!.displayMessage, "Note OFF: 60 (Ch: 1)");
      });
    });

    group("Note Off Messages (0x80)", () {
      test("should parse note off message correctly", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x80,
          60,
          64,
        ]); // Note Off, Middle C, channel 1

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.noteOff);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 60);
        expect(receivedEvent!.data2, 64);
        expect(receivedEvent!.displayMessage, "Note OFF: 60 (Ch: 1)");
      });
    });

    group("Control Change Messages (0xB0)", () {
      test("should parse control change message correctly", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xB0,
          7,
          100,
        ]); // CC 7 (volume), value 100, channel 1

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.controlChange);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 7);
        expect(receivedEvent!.data2, 100);
        expect(receivedEvent!.displayMessage, "CC: Controller 7 = 100 (Ch: 1)");
      });
    });

    group("Program Change Messages (0xC0)", () {
      test("should parse 3-byte program change message", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xC0,
          42,
          0,
        ]); // Program Change to 42, channel 1

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.programChange);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 42);
        expect(receivedEvent!.displayMessage, "Program Change: 42 (Ch: 1)");
      });

      test("should parse 2-byte program change message", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xC0,
          42,
        ]); // Program Change to 42, channel 1

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.programChange);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 42);
        expect(receivedEvent!.displayMessage, "Program Change: 42 (Ch: 1)");
      });
    });

    group("Pitch Bend Messages (0xE0)", () {
      test("should parse pitch bend message correctly", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xE0,
          0,
          64,
        ]); // Pitch bend center position

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.pitchBend);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.data1, 0);
        expect(receivedEvent!.data2, 64);
        expect(receivedEvent!.displayMessage, contains("Pitch Bend:"));
        expect(receivedEvent!.displayMessage, contains("(Ch: 1)"));
      });

      test("should calculate pitch bend value correctly", () {
        // Test center position (should be close to 0)
        final centerValue = MidiService.getPitchBendValue(0, 64);
        expect(centerValue, closeTo(0.0, 0.01));

        // Test minimum position (should be close to -1)
        final minValue = MidiService.getPitchBendValue(0, 0);
        expect(minValue, closeTo(-1.0, 0.01));

        // Test maximum position (should be close to 1)
        final maxValue = MidiService.getPitchBendValue(127, 127);
        expect(maxValue, closeTo(1.0, 0.01));
      });
    });

    group("Other MIDI Messages", () {
      test("should handle unknown MIDI messages", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xA0,
          60,
          64,
        ]); // Polyphonic key pressure (not explicitly handled)

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.other);
        expect(receivedEvent!.channel, 1);
        expect(receivedEvent!.displayMessage, contains("MIDI: Status 0xA0"));
      });
    });

    group("Channel Parsing", () {
      test("should correctly parse different MIDI channels", () {
        for (var channel = 0; channel < 16; channel++) {
          MidiEvent? receivedEvent;
          final statusByte = 0x90 + channel; // Note On + channel
          final data = Uint8List.fromList([statusByte, 60, 127]);

          MidiService.handleMidiData(data, (event) {
            receivedEvent = event;
          });

          expect(
            receivedEvent!.channel,
            channel + 1,
            reason:
                "Channel should be 1-based (status byte: 0x${statusByte.toRadixString(16)})",
          );
        }
      });
    });

    group("Edge Cases", () {
      test("should handle minimum data length gracefully", () {
        final data = Uint8List.fromList([0x90]); // Only status byte

        MidiService.handleMidiData(data, (event) {
          // Should not be called with insufficient data
          fail("Event callback should not be called with insufficient data");
        });

        // Should not crash and not call the callback
        // The important thing is that it doesn't throw an exception
        expect(true, true); // Test passes if no exception is thrown
      });

      test("should handle data with extra bytes", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x90,
          60,
          127,
          0x40,
          0x7F,
        ]); // Extra bytes (but valid MIDI data bytes 0-127)

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, MidiEventType.noteOn);
        expect(receivedEvent!.data1, 60);
        expect(receivedEvent!.data2, 127);
      });
    });

    group("Security Validation", () {
      test("should reject data with invalid MIDI data bytes (>127)", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x90,
          60,
          0xFF, // Invalid data byte (>127)
        ]);

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNull); // Should be rejected
      });

      test("should reject oversized packets", () {
        MidiEvent? receivedEvent;
        final data = Uint8List(300); // Oversized packet
        data[0] = 0x90;
        data[1] = 60;
        data[2] = 127;

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNull); // Should be rejected
      });

      test("should accept valid MIDI data bytes (0-127)", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0x90,
          60,
          127, // Valid data byte (0-127)
        ]);

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent, isNotNull); // Should be accepted
        expect(receivedEvent!.type, MidiEventType.noteOn);
      });
    });

    group("Message Display Formatting", () {
      test("should format hex values correctly in other messages", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xA5,
          0x7F,
          0x00,
        ]); // Status A5, data 7F, 00

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(receivedEvent!.displayMessage, contains("0xA5"));
        expect(receivedEvent!.displayMessage, contains("0x7F"));
        expect(receivedEvent!.displayMessage, contains("0x00"));
      });

      test("should include pitch bend precision in display message", () {
        MidiEvent? receivedEvent;
        final data = Uint8List.fromList([
          0xE0,
          32,
          80,
        ]); // Some pitch bend value

        MidiService.handleMidiData(data, (event) {
          receivedEvent = event;
        });

        expect(
          receivedEvent!.displayMessage,
          matches(r"Pitch Bend: -?\d+\.\d{2}"),
        );
      });
    });
  });
}
