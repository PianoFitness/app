# Practice Sessions Specification

## Overview

A practice session structures a student's time at the piano — from warm-up through focused work to cool-down — so that practice is purposeful, sustainable, and easy to reflect on. Sessions track elapsed time, guide progression through phases, and prompt breaks to prevent fatigue and maintain focus.

## Goals

- **Purposeful structure**: Guide students through warm-up, focused practice, and cool-down rather than unstructured playing.
- **Sustainable habits**: Encourage regular, appropriately-timed breaks to prevent physical strain and mental fatigue.
- **Progress visibility**: Give students a clear sense of how long they have practiced and what they have covered in a session.

## Requirements

### Session Structure

A session comprises three phases:

- **Warm-up**: Light exercises or scales to prepare hands and focus.
- **Main practice**: Targeted work on exercises, repertoire, or technique.
- **Cool-down**: Short review and reflection before finishing.

Students may move between phases manually. The app should offer guidance without enforcing rigid transitions.

### Session Timer

- Must support **count-up** (open-ended) and **countdown** (target duration) modes.
- Must support **pause and resume** at any point during a session.
- Must continue tracking time when the app is backgrounded.
- Display resolution of one second is sufficient.

### Session Goals

- Students may set a target total session duration (e.g., 30 minutes).
- Students may set a minimum time per exercise type.
- The app must indicate clearly when a goal is reached without interrupting practice.

### Practice Modes

- **Focused practice**: Student works on a single exercise in depth.
- **Rotation practice**: Student cycles through a defined set of exercises.
- **Free practice**: Unstructured — no exercise guidance, timer optional.

### Break Prompts

- The app should suggest breaks based on elapsed practice time:
  - **Micro break** (30–60 seconds): hand and wrist stretches, suggested after 20–30 continuous minutes.
  - **Short break** (5–10 minutes): rest and reset, suggested after 45–60 continuous minutes.
- Break prompts must be easily dismissable; students are never forced to stop.
- Prompts must be infrequent enough that they don't become a distraction.

### Session Templates

Predefined starting points matched to experience level:

- **Beginner**: 15–30 minute sessions with phase guidance enabled.
- **Intermediate**: 30–60 minute sessions with flexible phase allocation.
- **Advanced**: 60+ minute sessions with minimal scaffolding.

Students must be able to save custom templates for their own routines.

## Integration Points

- **Exercise System**: Session records per-exercise durations and the sequence of exercises practiced.
- **Metronome** (see `metronome-component.md`): Tempo is associated with the current exercise and persists across pause/resume.
- **Progress Tracking**: Completed sessions are logged with phase durations, exercises practiced, and goal outcomes.
- **Notifications**: Break reminders and daily practice prompts are delivered through the notification system.

## Future Enhancements

- **Smart break detection**: Infer optimal break timing from performance data rather than elapsed time alone.
- **Weekly planning view**: Visual calendar for scheduling and reviewing practice across days.
- **Session summary export**: Share a session summary with a teacher or save to a practice journal.
