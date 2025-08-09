import "package:flutter/material.dart";
import "package:piano_fitness/features/play/play_page.dart";
import "package:piano_fitness/models/midi_state.dart";
import "package:provider/provider.dart";

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() {
  runApp(const MyApp());
}

/// The root widget of the Piano Fitness application.
///
/// Sets up the app theme, provides global state management via Provider,
/// and defines the initial navigation structure.
class MyApp extends StatelessWidget {
  /// Creates the root widget of the Piano Fitness app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MidiState(),
      child: MaterialApp(
        title: "Piano Fitness",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const PlayPage(),
      ),
    );
  }
}
