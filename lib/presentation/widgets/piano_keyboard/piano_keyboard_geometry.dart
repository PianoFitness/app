import "package:flutter/rendering.dart";
import "package:meta/meta.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";
import "package:piano_fitness/presentation/utils/piano_key_utils.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/midi_note_range.dart";

/// Expands [range] outward to the nearest white-key boundary.
///
/// A range that starts or ends mid-octave (e.g. on a black key) is widened
/// — never truncated — so every requested note is always rendered.
MidiNoteRange expandToWhiteKeyBoundary(MidiNoteRange range) {
  var fromMidi = range.fromMidi;
  var toMidi = range.toMidi;
  while (isBlackKey(fromMidi)) {
    fromMidi -= 1;
  }
  while (isBlackKey(toMidi)) {
    toMidi += 1;
  }
  return MidiNoteRange(fromMidi: fromMidi, toMidi: toMidi);
}

/// The pixel rectangle occupied by a single key, keyed by MIDI note number.
@immutable
class PianoKeyRect {
  /// Creates a key rect for [midiNote] occupying [rect].
  const PianoKeyRect({required this.midiNote, required this.rect});

  /// The MIDI note number this rect represents.
  final int midiNote;

  /// The key's bounds within the keyboard's local coordinate space.
  final Rect rect;
}

/// Computed layout for a [MidiNoteRange] at a given key width/height.
///
/// White keys are laid out left-to-right at [whiteKeyWidth] each; black
/// keys are layered on top, centered on the boundary between the two
/// white keys they sit between (the common simplified piano-widget
/// layout, not scale-accurate sheet-music spacing).
@immutable
class PianoKeyboardLayout {
  /// Creates a layout for [range] (already expanded to white-key
  /// boundaries by the caller) at the given dimensions.
  PianoKeyboardLayout({
    required this.range,
    required this.whiteKeyWidth,
    required this.height,
  }) : whiteKeys = _layoutWhiteKeys(range, whiteKeyWidth, height),
       blackKeys = _layoutBlackKeys(range, whiteKeyWidth, height) {
    totalWidth = whiteKeys.isEmpty
        ? 0
        : whiteKeys.last.rect.right;
  }

  /// The expanded MIDI range this layout covers.
  final MidiNoteRange range;

  /// The width of a single white key in logical pixels.
  final double whiteKeyWidth;

  /// The height of the keyboard in logical pixels.
  final double height;

  /// White key rects in left-to-right order.
  final List<PianoKeyRect> whiteKeys;

  /// Black key rects in left-to-right order.
  final List<PianoKeyRect> blackKeys;

  /// The total scrollable width of the keyboard content.
  late final double totalWidth;

  static List<PianoKeyRect> _layoutWhiteKeys(
    MidiNoteRange range,
    double whiteKeyWidth,
    double height,
  ) {
    final whiteMidiNotes = getWhiteKeysInRange(range.fromMidi, range.toMidi);
    return [
      for (var i = 0; i < whiteMidiNotes.length; i++)
        PianoKeyRect(
          midiNote: whiteMidiNotes[i],
          rect: Rect.fromLTWH(i * whiteKeyWidth, 0, whiteKeyWidth, height),
        ),
    ];
  }

  static List<PianoKeyRect> _layoutBlackKeys(
    MidiNoteRange range,
    double whiteKeyWidth,
    double height,
  ) {
    final blackKeyWidth = whiteKeyWidth * ComponentDimensions.blackKeyWidthRatio;
    final blackKeyHeight = height * ComponentDimensions.blackKeyHeightRatio;
    final whiteMidiNotes = getWhiteKeysInRange(range.fromMidi, range.toMidi);
    final blackMidiNotes = getBlackKeysInRange(range.fromMidi, range.toMidi);

    final rects = <PianoKeyRect>[];
    for (final blackMidi in blackMidiNotes) {
      // Index of the preceding white key (the one immediately below this
      // black key chromatically) within the visible white-key sequence.
      final precedingWhiteIndex = whiteMidiNotes.lastIndexWhere(
        (whiteMidi) => whiteMidi < blackMidi,
      );
      if (precedingWhiteIndex == -1) continue;

      final boundaryX = (precedingWhiteIndex + 1) * whiteKeyWidth;
      rects.add(
        PianoKeyRect(
          midiNote: blackMidi,
          rect: Rect.fromLTWH(
            boundaryX - blackKeyWidth / 2,
            0,
            blackKeyWidth,
            blackKeyHeight,
          ),
        ),
      );
    }
    return rects;
  }

  /// Hit-tests [localPosition] against this layout.
  ///
  /// Black keys are checked first (they render on top and their bounding
  /// box only covers the flush-top overlap region); a miss falls through
  /// to the white key beneath. Returns `null` if [localPosition] is
  /// outside every key.
  int? hitTest(Offset localPosition) {
    for (final blackKey in blackKeys) {
      if (blackKey.rect.contains(localPosition)) {
        return blackKey.midiNote;
      }
    }
    for (final whiteKey in whiteKeys) {
      if (whiteKey.rect.contains(localPosition)) {
        return whiteKey.midiNote;
      }
    }
    return null;
  }
}
