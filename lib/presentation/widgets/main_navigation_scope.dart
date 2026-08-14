import "package:flutter/widgets.dart";

/// Marks pages rendered inside the persistent application navigation shell.
class MainNavigationScope extends InheritedWidget {
  /// Creates a scope around the shell's content navigator.
  const MainNavigationScope({required super.child, super.key});

  /// Whether [context] is inside the persistent application shell.
  static bool isActive(BuildContext context) {
    return context.getInheritedWidgetOfExactType<MainNavigationScope>() != null;
  }

  @override
  bool updateShouldNotify(MainNavigationScope oldWidget) => false;
}
