# ADR-0022: Platform Support Strategy

**Status:** Accepted

**Date:** 2024-01-01

## Context

Flutter supports 6 platforms: iOS, Android, Web, macOS, Windows, Linux.

**Piano Fitness constraints:**

- **Development Environment:** macOS only (no Android tooling installed)
- **MIDI Requirements:** Bluetooth MIDI requires physical devices
- **Target Audience:** Musicians with iOS/Android devices
- **Future Expansion:** Desktop for practice at home

**Build capabilities:**

✅ **Supported:**
- iOS (Xcode toolchain)
- macOS (native platform)
- Web (browser-based)
- Linux (Flutter toolchain)
- Windows (Flutter toolchain)

❌ **Not Supported:**
- Android APK (no Android SDK/tooling)

## Decision

**Primary Platforms:** iOS, macOS, Web

**Secondary Platforms:** Linux, Windows (future consideration)

**Not Supported:** Android APK compilation (can be built on different machine)

**Build Commands:**

```bash
# Primary platforms
flutter build ios --release
flutter build macos --release
flutter build web

# Secondary platforms (available but not primary focus)
flutter build linux
flutter build windows

# Not available (no tooling)
flutter build apk  # ❌ ERROR: Android SDK not installed
```

**Development Workflow:**

1. **Local Development:** macOS, iOS Simulator, Chrome
2. **MIDI Testing:** Requires physical iOS/macOS device with Bluetooth MIDI
3. **CI/CD:** iOS via Fastlane + App Store Connect, Web via hosting
4. **Android:** Built on separate machine or CI/CD with Android tooling

**Platform-Specific Features:**

| Feature             | iOS | Android | macOS | Web | Desktop |
| ------------------- | --- | ------- | ----- | --- | ------- |
| Bluetooth MIDI      | ✅   | ✅       | ✅     | ❌   | ⚠️       |
| Local Notifications | ✅   | ✅       | ✅     | ❌   | ✅       |
| Audio Playback      | ✅   | ✅       | ✅     | ✅   | ✅       |
| File Storage        | ✅   | ✅       | ✅     | ⚠️   | ✅       |

## Consequences

### Positive

- **Focus** - Prioritize iOS/macOS/Web where tooling exists
- **Development Speed** - No Android setup delays
- **MIDI Reality** - Physical device testing matches target platforms
- **Web Accessibility** - Browser-based access for demonstrations

### Negative

- **Android Gap** - Cannot build APK locally (CI/CD required)
- **Testing Limitation** - Android MIDI testing requires separate environment

### Neutral

- **CI/CD Required** - Android builds via GitHub Actions or similar
- **Platform Parity** - Code supports Android, just can't build locally

## Related Decisions

- [ADR-0016: Accessibility](0016-accessibility-modular-architecture.md) - Cross-platform accessibility
- [ADR-0015: MIDI Processing](0015-midi-message-processing.md) - MIDI platform support

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Documented in: `AGENTS.md` (build targets section)
- Primary development: macOS with iOS Simulator
- MIDI testing: Physical iPad/iPhone with Bluetooth MIDI keyboard
- Web deployment: Browser-based demonstrations
- Android: Built via CI/CD or different development machine
