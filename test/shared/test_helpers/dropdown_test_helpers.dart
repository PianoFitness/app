import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

/// Selects [value] on the `DropdownButtonFormField<T>` in the tree by
/// invoking its `onChanged` callback directly, rather than opening the
/// dropdown menu overlay and tapping option text.
///
/// This matches this project's convention of avoiding brittle
/// `find.text()`-based interactions (see
/// `practice_settings_panel_test.dart`), and relies on each dropdown's
/// generic type being unique within the widget tree being tested, so
/// `find.byType(DropdownButtonFormField<T>)` resolves to exactly one
/// widget.
Future<void> selectDropdownValue<T>(WidgetTester tester, T value) async {
  final dropdown = tester.widget<DropdownButtonFormField<T>>(
    find.byType(DropdownButtonFormField<T>),
  );
  dropdown.onChanged!(value);
  await tester.pumpAndSettle();
}
