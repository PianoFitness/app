# Piano Fitness 🎹

Piano Fitness is an open-source, MIDI-aware piano practice app. It helps
learners make technical practice and foundational harmony visible, structured,
and easier to continue. It is designed to complement lessons, repertoire, and
self-directed study—not to replace a teacher.

## Current implementation

The app currently includes:

- Guided practice for scales, arpeggios, block chords, chord types, chord
  progressions, broken-chord accompaniment, and cadences.
- An interactive piano and MIDI device support, including visual note targets
  and progress through an exercise.
- Feedback based on completed notes, accuracy, and measured tempo. It does not
  assess physical hand posture or replace a teacher's musical judgment.
- A curriculum with skill progression and practice-history views.
- Local user profiles and persistent exercise history.
- A metronome, daily practice reminders, dark theme, and accessibility support.

## Data and privacy

Piano Fitness does not use Firebase, a hosted user account system, cloud
synchronization, or a first-party analytics service. Profiles, settings, and
practice history are stored locally using Drift (SQLite) and SharedPreferences.
MIDI events are handled on-device to run exercises and calculate practice
results.

The app does not currently include teacher accounts, assignment workflows,
cross-device sync, achievement badges, or adaptive recommendations. These may
be explored later only if they support the product's learner-agency and privacy
principles.

## Development

### Requirements

- Flutter `>=3.22.0 <4.0.0`
- Dart `>=3.8.1 <4.0.0`

### Common commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Run `dart format .` before committing source changes. See
[CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for the complete
development and quality workflow.

## Architecture

The application follows a three-layer architecture:

```text
Presentation → Application → Domain
```

- **Presentation** contains Flutter pages, widgets, and view models.
- **Application** implements repositories, persistence, MIDI coordination, and
  other application services.
- **Domain** contains the models and pure musical logic.

See the [architecture decision records](docs/ADRs/README.md) and the
[specifications index](docs/specifications/README.md) for the detailed design
and implementation record.

## Contributing

Contributions from musicians, educators, designers, and developers are welcome.
Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

Piano Fitness is licensed under the [Apache License 2.0](LICENSE).
