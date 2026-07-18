// Widget tests for PianoKeyboard: rendering, gestures (tap, glissando,
// multi-touch, cancellation), controller, and accessibility.

import "package:flutter/material.dart";
import "package:flutter/semantics.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/presentation/widgets/piano_keyboard/piano_keyboard.dart";

void main() {
  // A two-white-key range (C4, D4) with a black key (C#4) between them,
  // at a generous key width so gesture coordinates are easy to reason about.
  const range = MidiNoteRange(fromMidi: 60, toMidi: 62);
  const keyWidth = 100.0;
  const keyboardHeight = 120.0;

  Widget buildKeyboard({
    required ValueNotifier<Map<int, PianoKeyVisual>> keyVisuals,
    void Function(int)? onKeyDown,
    void Function(int)? onKeyUp,
    bool enableGlissando = true,
    NoteLabelMode noteLabelMode = NoteLabelMode.none,
    PianoKeyboardController? controller,
    MidiNoteRange range = range,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: keyboardHeight,
          child: PianoKeyboard(
            range: range,
            keyVisuals: keyVisuals,
            keyWidth: keyWidth,
            enableGlissando: enableGlissando,
            noteLabelMode: noteLabelMode,
            controller: controller,
            onKeyDown: onKeyDown,
            onKeyUp: onKeyUp,
          ),
        ),
      ),
    );
  }

  // Well inside the C4 white key, below the black-key overlap band.
  const c4Offset = Offset(50, keyboardHeight - 10);
  // Well inside the D4 white key. The range (60-62) has two white keys
  // (C4, D4) at 100px each, so D4 spans x in [100, 200).
  const d4Offset = Offset(150, keyboardHeight - 10);

  testWidgets("renders without error for an empty keyVisuals map", (
    tester,
  ) async {
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    await tester.pumpWidget(buildKeyboard(keyVisuals: keyVisuals));
    expect(find.byType(PianoKeyboard), findsOneWidget);
  });

  testWidgets("renders without error with fill, outline, dot, and label set", (
    tester,
  ) async {
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({
      60: const PianoKeyVisual(
        fill: Colors.blue,
        outline: Colors.red,
        dot: Colors.green,
        label: "2",
      ),
    });
    await tester.pumpWidget(buildKeyboard(keyVisuals: keyVisuals));
    expect(tester.takeException(), isNull);
  });

  testWidgets("tapping a key fires onKeyDown then onKeyUp", (tester) async {
    final events = <String>[];
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        onKeyDown: (m) => events.add("down:$m"),
        onKeyUp: (m) => events.add("up:$m"),
      ),
    );

    final gesture = await tester.startGesture(c4Offset);
    await tester.pump();
    expect(events, ["down:60"]);

    await gesture.up();
    await tester.pump();
    expect(events, ["down:60", "up:60"]);
  });

  testWidgets("glissando: dragging across keys emits up/down pairs", (
    tester,
  ) async {
    final events = <String>[];
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        onKeyDown: (m) => events.add("down:$m"),
        onKeyUp: (m) => events.add("up:$m"),
      ),
    );

    final gesture = await tester.startGesture(c4Offset);
    await tester.pump();
    await gesture.moveTo(d4Offset);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(events, ["down:60", "up:60", "down:62", "up:62"]);
  });

  testWidgets(
    "enableGlissando: false cancels the note instead of retriggering",
    (tester) async {
      final events = <String>[];
      final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
      await tester.pumpWidget(
        buildKeyboard(
          keyVisuals: keyVisuals,
          enableGlissando: false,
          onKeyDown: (m) => events.add("down:$m"),
          onKeyUp: (m) => events.add("up:$m"),
        ),
      );

      final gesture = await tester.startGesture(c4Offset);
      await tester.pump();
      await gesture.moveTo(d4Offset);
      await tester.pump();

      // Only the cancellation of C4 fires — no retrigger of D4.
      expect(events, ["down:60", "up:60"]);

      await gesture.up();
      await tester.pump();
      // Lifting after having slid off doesn't emit a second up.
      expect(events, ["down:60", "up:60"]);
    },
  );

  testWidgets("multi-touch: two concurrent pointers produce independent chords", (
    tester,
  ) async {
    final events = <String>[];
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        onKeyDown: (m) => events.add("down:$m"),
        onKeyUp: (m) => events.add("up:$m"),
      ),
    );

    final gesture1 = await tester.startGesture(c4Offset);
    await tester.pump();
    final gesture2 = await tester.startGesture(d4Offset, pointer: 2);
    await tester.pump();

    expect(events, containsAll(["down:60", "down:62"]));
    expect(events.length, 2);

    await gesture1.up();
    await gesture2.up();
    await tester.pump();

    expect(events, containsAll(["up:60", "up:62"]));
    expect(events.length, 4);
  });

  testWidgets("a PointerCancelEvent still emits onKeyUp (no stuck notes)", (
    tester,
  ) async {
    final events = <String>[];
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        onKeyDown: (m) => events.add("down:$m"),
        onKeyUp: (m) => events.add("up:$m"),
      ),
    );

    final gesture = await tester.startGesture(c4Offset);
    await tester.pump();
    expect(events, ["down:60"]);

    await gesture.cancel();
    await tester.pump();
    expect(events, ["down:60", "up:60"]);
  });

  testWidgets("controller.ensureVisible scrolls the target key into view", (
    tester,
  ) async {
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    final controller = PianoKeyboardController();
    addTearDown(controller.dispose);

    // A wide range that needs scrolling at this key width/viewport.
    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        controller: controller,
        range: const MidiNoteRange(fromMidi: 36, toMidi: 84),
      ),
    );
    await tester.pump();

    expect(controller.scrollController.offset, 0);

    controller.ensureVisible(84);
    await tester.pumpAndSettle();

    expect(controller.scrollController.offset, greaterThan(0));
  });

  testWidgets("each key exposes a semantics tap action wired to the callbacks", (
    tester,
  ) async {
    final events = <String>[];
    final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({});
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      buildKeyboard(
        keyVisuals: keyVisuals,
        onKeyDown: (m) => events.add("down:$m"),
        onKeyUp: (m) => events.add("up:$m"),
      ),
    );
    await tester.pump();

    // The per-key nodes come from CustomPainter.semanticsBuilder, not a
    // widget-declared Semantics, so find.bySemanticsLabel (an Element-tree
    // finder) can't see them — walk the raw SemanticsNode tree instead.
    final root = tester.getSemantics(find.byType(PianoKeyboard));
    final c4Node = findSemanticsNodeByLabel(root, "C4");
    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!.performAction(
      c4Node.id,
      SemanticsAction.tap,
    );
    await tester.pump();

    expect(events, ["down:60", "up:60"]);
    handle.dispose();
  });

  testWidgets(
    "the per-key label is independent of the widget-level note-label mode",
    (tester) async {
      final keyVisuals = ValueNotifier<Map<int, PianoKeyVisual>>({
        60: const PianoKeyVisual(label: "2"),
      });
      final handle = tester.ensureSemantics();

      // noteLabelMode.none (the default) only controls the static painted
      // label; the per-key finger-number label still shows up in the
      // semantics text regardless of that mode.
      await tester.pumpWidget(buildKeyboard(keyVisuals: keyVisuals));
      await tester.pump();

      final root = tester.getSemantics(find.byType(PianoKeyboard));
      expect(
        () => findSemanticsNodeByLabel(root, "C4, finger 2"),
        returnsNormally,
      );
      handle.dispose();
    },
  );
}

/// Depth-first search for a [SemanticsNode] with an exact-match [label]
/// within [root]'s subtree. Throws [StateError] if none is found.
SemanticsNode findSemanticsNodeByLabel(SemanticsNode root, String label) {
  SemanticsNode? found;
  void visit(SemanticsNode node) {
    if (found != null) return;
    if (node.getSemanticsData().label == label) {
      found = node;
      return;
    }
    node.visitChildren((child) {
      visit(child);
      return found == null;
    });
  }

  visit(root);
  if (found == null) {
    throw StateError("No SemanticsNode found with label '$label'");
  }
  return found!;
}
