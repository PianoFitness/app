# Repertoire Feature Specification

## Overview

Add a fourth navigation tab "Repertoire" that provides practice time management for piece study, with educational guidance toward dedicated repertoire apps.

## User Flow

1. User taps Repertoire tab
2. Sees explanatory text about technical vs. repertoire practice
3. Sets timer duration (default: 15 minutes)
4. Starts timer and switches to repertoire app/sheet music
5. Receives gentle notification when time expires

## Incremental Development Phases

### Phase 1: Basic Page Structure (MVP)

**Goal**: Working navigation tab with static content

- Add repertoire tab to bottom navigation
- Create `RepertoirePage` with explanatory text
- Add app recommendations (Flowkey, Simply Piano) with external links
- Create basic `RepertoirePageViewModel`

**Deliverable**: Functional page with educational content

### Phase 2: Timer UI (Silent Timer)

**Goal**: Functional timer without audio/notifications

- Add timer duration selector (5, 10, 15, 20, 30 minutes)
- Implement countdown display (MM:SS format)
- Add start/pause/reset controls
- Timer state management in ViewModel

**Deliverable**: Visual timer that counts down silently

### Phase 3: Audio Feedback

**Goal**: Gentle sound notification

- Add timer completion sound (gentle chime)
- Use built-in system sounds or simple audio asset
- Test audio on macOS/iOS targets

**Assets Needed**: Audio file for timer completion (gentle bell/chime)
**Packages**: May need `audioplayers` or use system notification sounds

### Phase 4: Visual Polish

**Goal**: Enhanced UX and visual design

- Progress ring/bar visualization
- Improved timer controls styling
- Consistent theme with app design
- Loading states and animations

### Phase 5: Background Support (Future)

**Goal**: Timer continues when app is backgrounded
**Permissions**: Background processing capabilities
**Platform Considerations**: iOS background limitations, macOS better support

### Phase 6: System Notifications (Future)

**Goal**: Push notification when timer completes
**Permissions**: Notification permissions
**Packages**: `flutter_local_notifications`

## Technical Architecture

### File Structure

```text
lib/features/repertoire/
├── repertoire_page.dart
└── repertoire_page_view_model.dart
```

### Navigation Integration

- Update `main_navigation.dart` to include fourth tab
- Add repertoire icon to navigation

### State Management

- `RepertoirePageViewModel extends ChangeNotifier`
- Timer state: duration, remaining time, isRunning, isPaused
- Dispose pattern for timer cleanup

## External Dependencies

### Phase 1-2: None required

### Phase 3: Audio

- Consider `audioplayers` package or system sounds

### Phase 5-6: Advanced Features

- `flutter_local_notifications` for system notifications
- Platform-specific background processing setup

## Success Criteria

- Seamless integration with existing bottom navigation
- Timer accurately tracks practice time
- Educational content guides users to appropriate repertoire apps
- Follows existing app architecture patterns
- Maintains performance on all supported platforms (macOS, iOS, web)
