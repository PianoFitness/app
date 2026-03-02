<!--
  Status: Draft
  Created: 2026-03-02
-->

# User Profile Specification

## Overview

User profiles allow multiple people to use Piano Fitness on a single device without sharing practice history, settings, or progress. Each profile is independent and lightweight — identified by a display name only, with no personally identifiable information required.

## Goals

- **Device sharing**: Enable families or students sharing a device to maintain separate practice identities.
- **Privacy by default**: Require only a display name; no email, photo, or account credentials.
- **Frictionless switching**: Make it trivial to switch between profiles or create a new one.

## Requirements

### Functional Requirements

- A profile must have a **display name** (required, 1–30 characters).
- A profile may store the **last practice date** for display purposes.
- The app must support an **unlimited number of profiles** on a single device.
- Profiles are stored locally using Drift (see ADR-0024).
- When the app launches:
  - If **no profiles exist**, prompt the user to create one.
  - If **one profile exists**, use it automatically without prompting.
  - If **multiple profiles exist**, display the profile chooser screen.
- The **currently active profile** is displayed in the upper-right corner of the main UI, near the settings icon.
- Tapping the active profile name opens the profile chooser to allow switching.
- Users must be able to **edit a profile's display name**.
- Users must be able to **delete a profile** with a confirmation dialog warning about data loss.

### Profile Chooser Screen

- Display one button per profile, showing the display name.
- Profiles are sorted by **most recent practice** (most recent first) by default.
- A **toggle button** allows switching between **alphabetical** and **last active** sorting.
- The chosen sort order is persisted per device (not per profile).
- Each profile entry has **secondary actions** for edit and delete (e.g., icon buttons, context menu, or swipe actions).
- **Tapping the profile button** (primary action) switches to that profile and returns to the main screen.
- **Tapping the edit action** shows a dialog or inline editor to rename the profile.
- **Tapping the delete action** shows a confirmation dialog before deleting the profile.
- The confirmation dialog must warn that all associated practice data will be permanently deleted.
- A clearly labelled action to **create a new profile** must be present.

### Data Scope

Each profile owns:

- Practice session history
- Exercise progress and statistics
- User preferences (metronome settings, notification preferences, etc.)

Profiles do **not** store:

- Email addresses, passwords, or authentication credentials
- Photos or avatars
- Device connection history
- Subscription or account type information

### Profile Display Name

- Display names must be **1–30 characters**.
- Suggest using **first name only** (via placeholder text or onboarding hint) for simplicity and privacy.
- If a display name exceeds available space in the UI, **truncate with ellipsis** (e.g., "Christopher" → "Christ…").

## Accessibility

- **Screen reader**: The profile chooser buttons must be labelled with the display name. Edit and delete actions must announce their function (e.g., "Edit [profile name]", "Delete [profile name]"). The sort toggle button must announce the current sort order and the action (e.g., "Sort alphabetically" or "Sort by last active"). The "create new profile" action must have a distinct semantic label.
- **Contrast**: Profile chooser buttons and edit/delete actions must meet WCAG AA contrast requirements (4.5:1 for text).
- **Touch targets**: Each profile button, edit action, delete action, and the sort toggle button must be at least 44×44 dp.
- **Text scaling**: The profile chooser layout must accommodate system font scaling up to 200% without clipping profile names or obscuring edit/delete actions.
- **Reduced motion**: No animations required; profile switching is instantaneous.

## Design Notes

**Profile model**

- Must hold: `id` (UUID), `displayName` (String), `lastPracticeDate` (DateTime, nullable).
- Must enforce: `displayName` is non-empty and ≤30 characters.

**Profile selection logic**

- On app start, query the Drift database for all profiles.
- If count == 0: show profile creation prompt.
- If count == 1: load that profile and proceed to main screen.
- If count > 1: show profile chooser screen.

**Active profile persistence**

- Store the currently active profile ID in shared preferences or Drift app state table.
- Load the active profile on app restart; fall back to profile chooser if the stored ID no longer exists.
- Store the profile chooser sort preference (alphabetical or last active) in shared preferences; default to last active on first launch.

**Profile deletion**

- Before deleting, confirm with a dialog warning that all practice data, settings, and progress associated with the profile will be permanently lost.
- When a profile is deleted, all related records (practice sessions, progress, preferences) must be removed from the database.
- If the deleted profile is the currently active profile, automatically redirect to the profile chooser.

## Integration Points

- **Drift database**: Profile table persists profile records locally (see ADR-0024).
- **Practice sessions**: Each practice session record must reference the active profile ID.
- **Settings and preferences**: All user-configurable settings (metronome tempo, notification times) are scoped to the active profile.
- **Progress tracking**: Exercise progress, statistics, and achievements are per-profile.

## Acceptance Criteria

- [ ] User can create a new profile with a display name.
- [ ] User can switch between profiles via the profile chooser.
- [ ] User can edit a profile's display name.
- [ ] User can delete a profile with a confirmation dialog that warns about data loss.
- [ ] When a profile is deleted, all associated data is removed from the database.
- [ ] If the active profile is deleted, the user is redirected to the profile chooser.
- [ ] User can toggle between alphabetical and last active sorting on the profile chooser.
- [ ] The chosen sort order persists across app restarts.
- [ ] The active profile display name appears in the upper-right corner of the main UI.
- [ ] Profile chooser is shown on app launch only when multiple profiles exist.
- [ ] A single profile auto-loads without displaying the chooser.
- [ ] Display names truncate gracefully when they exceed available space.
- [ ] All practice data is isolated per profile.
- [ ] Edit and delete actions are secondary to profile selection (visually and interactively).

## Future Enhancements

- Optional profile colour or icon for visual distinction.
- Export/import profile data for backup or device transfer.
- Profile analytics showing total practice time and session count.
