import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

/// Pumps [widget] at a portrait phone size.
///
/// The default flutter_test viewport (800x600) is landscape-shaped, but
/// many tests assert on portrait-only layouts (e.g. the bottom nav bar
/// vs. the landscape drawer), so they need an explicit portrait size
/// rather than the test default.
Future<void> pumpPortrait(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}
