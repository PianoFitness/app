import "package:flutter/material.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() {
  runApp(const MyApp());
}

/// The root widget of the Piano Fitness application.
///
/// Sets up the app theme and defines the initial navigation structure.
/// Each page now manages its own local MIDI state for better isolation.
class MyApp extends StatelessWidget {
  /// Creates the root widget of the Piano Fitness app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Piano Fitness",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
