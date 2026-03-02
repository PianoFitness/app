# Architecture Decision Records (ADRs)

## Why ADRs?

Architecture Decision Records (ADRs) document significant architectural choices made in Piano Fitness. They provide context for why decisions were made, what alternatives were considered, and what consequences resulted. This helps:

- **Preserve institutional knowledge** - Capture the reasoning behind architectural choices
- **Onboard new developers** - Understand the "why" behind the current architecture
- **Guide future decisions** - Learn from past decisions and maintain consistency
- **Facilitate discussion** - Provide a structured format for proposing changes
- **Track evolution** - See how the architecture has evolved over time

ADRs are lightweight documents that focus on significant decisions affecting multiple features, external dependencies, or foundational patterns.

## Maintenance

ADRs are numbered sequentially (0001-0024, etc.). When creating new ADRs:

1. Use the next available number (4-digit format)
2. Follow the [template.md](template.md) structure
3. Add an entry to this list with the date
4. Use descriptive titles and cross-reference related ADRs

## Architecture Decision Records

### Foundation Architecture

- [ADR-0001: Clean Architecture with Three Layers](0001-clean-architecture-three-layers.md) - 2024-01-01
- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md) - 2024-01-01
- [ADR-0003: Provider for Dependency Injection](0003-provider-dependency-injection.md) - 2024-01-01
- [ADR-0004: Repository Pattern for External Dependencies](0004-repository-pattern-external-dependencies.md) - 2026-02-03
- [ADR-0005: MidiConnectionService as Internal Singleton](0005-midi-connection-service-singleton.md) - 2026-02-03

### State Management

- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - 2026-02-03
- [ADR-0007: Factory Pattern for Audio Service](0007-factory-pattern-audio-service.md) - 2026-02-03
- [ADR-0008: Notification Service Initialization in Repository Constructor](0008-notification-service-initialization.md) - 2026-02-03

### Testing Infrastructure

- [ADR-0009: Repository-Level Test Mocking](0009-repository-level-test-mocking.md) - 2026-02-03
- [ADR-0010: Shared Test Helper Infrastructure](0010-shared-test-helper-infrastructure.md) - 2026-02-03
- [ADR-0011: 80% Test Coverage Requirements](0011-test-coverage-requirements.md) - 2024-01-01
- [ADR-0012: Test Organization Mirrors Source Structure](0012-test-organization-mirrors-source.md) - 2024-01-01

### Domain and Features

- [ADR-0013: Music Theory Domain Services](0013-music-theory-domain-services.md) - 2024-01-01
- [ADR-0014: Piano Keyboard Layout Strategy](0014-piano-keyboard-layout-strategy.md) - 2024-01-01
- [ADR-0015: MIDI Message Processing](0015-midi-message-processing.md) - 2024-01-01
- [ADR-0016: Accessibility Modular Architecture](0016-accessibility-modular-architecture.md) - 2024-01-01
- [ADR-0017: Notification Scheduling Strategy](0017-notification-scheduling-strategy.md) - 2024-01-01
- [ADR-0018: Audio Playback Factory Pattern](0018-audio-playback-factory-pattern.md) - 2024-01-01

### Development Conventions

- [ADR-0019: CLI-Only Package Management](0019-cli-only-package-management.md) - 2024-01-01
- [ADR-0020: Lefthook for Automated Quality Controls](0020-lefthook-automated-quality-controls.md) - 2024-01-01
- [ADR-0021: Platform Support Strategy](0021-platform-support-strategy.md) - 2024-01-01
- [ADR-0022: Structured Logging Strategy](0022-structured-logging-strategy.md) - 2024-01-01
- [ADR-0023: Import Organization Conventions](0023-import-organization-conventions.md) - 2024-01-01

### Data Persistence

- [ADR-0024: Drift for Database Persistence](0024-drift-database-persistence.md) - 2026-03-02
