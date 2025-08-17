# Firebase Data Models Specification

## Overview

This specification defines the comprehensive data models for Piano Fitness application using Firebase Firestore. The models are designed for scalability, real-time synchronization, and offline-first functionality while maintaining data consistency across devices.

## Database Architecture

### Collection Structure Overview

```text
Firestore Database
├── users/{uid}/                          # User profiles and settings
├── exercises/{exerciseId}/                # Master exercise definitions
├── teacherStudents/{teacherId}/           # Teacher-student relationships
├── institutions/{institutionId}/          # Educational institutions
├── leaderboards/{leaderboardId}/          # Community features
└── systemData/                           # App configuration and metadata
```

## Core Data Models

### User Profile Model

```dart
// Firestore: users/{uid}
class UserProfileModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime? lastPracticeDate;
  final AccountType accountType;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> learningProfile;
  final List<String> connectedDevices;
  final Map<String, dynamic> subscription;
  
  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    'lastPracticeDate': lastPracticeDate != null ? Timestamp.fromDate(lastPracticeDate!) : null,
    'accountType': accountType.toString(),
    'preferences': preferences,
    'learningProfile': learningProfile,
    'connectedDevices': connectedDevices,
    'subscription': subscription,
  };
  
  static UserProfileModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      lastPracticeDate: data['lastPracticeDate'] != null 
          ? (data['lastPracticeDate'] as Timestamp).toDate() 
          : null,
      accountType: AccountType.values.firstWhere(
        (e) => e.toString() == data['accountType'],
        orElse: () => AccountType.free,
      ),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      learningProfile: Map<String, dynamic>.from(data['learningProfile'] ?? {}),
      connectedDevices: List<String>.from(data['connectedDevices'] ?? []),
      subscription: Map<String, dynamic>.from(data['subscription'] ?? {}),
    );
  }
}
```

### Practice Session Model

```dart
// Firestore: users/{uid}/practiceData/sessions/{sessionId}
class PracticeSessionModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration totalDuration;
  final List<ExerciseSessionModel> exercises;
  final List<BreakPeriodModel> breaks;
  final Map<String, double> overallMetrics;
  final String? notes;
  final String deviceId;
  final Map<String, dynamic> metronomeSettings;
  final bool isCompleted;
  
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'userId': userId,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'totalDuration': totalDuration.inSeconds,
    'exercises': exercises.map((e) => e.toMap()).toList(),
    'breaks': breaks.map((b) => b.toMap()).toList(),
    'overallMetrics': overallMetrics,
    'notes': notes,
    'deviceId': deviceId,
    'metronomeSettings': metronomeSettings,
    'isCompleted': isCompleted,
    'createdAt': FieldValue.serverTimestamp(),
  };
  
  static PracticeSessionModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PracticeSessionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      totalDuration: Duration(seconds: data['totalDuration'] ?? 0),
      exercises: (data['exercises'] as List<dynamic>?)
          ?.map((e) => ExerciseSessionModel.fromMap(e))
          .toList() ?? [],
      breaks: (data['breaks'] as List<dynamic>?)
          ?.map((b) => BreakPeriodModel.fromMap(b))
          .toList() ?? [],
      overallMetrics: Map<String, double>.from(data['overallMetrics'] ?? {}),
      notes: data['notes'],
      deviceId: data['deviceId'] ?? '',
      metronomeSettings: Map<String, dynamic>.from(data['metronomeSettings'] ?? {}),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}

class ExerciseSessionModel {
  final String exerciseId;
  final String exerciseName;
  final ExerciseType type;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int attempts;
  final double accuracy;
  final int tempo;
  final int targetTempo;
  final DifficultyLevel difficulty;
  final List<MidiEventModel> midiData;
  final Map<String, double> metrics;
  final String? notes;
  
  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'type': type.toString(),
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'duration': duration.inSeconds,
    'attempts': attempts,
    'accuracy': accuracy,
    'tempo': tempo,
    'targetTempo': targetTempo,
    'difficulty': difficulty.toString(),
    'midiData': midiData.map((m) => m.toMap()).toList(),
    'metrics': metrics,
    'notes': notes,
  };
  
  static ExerciseSessionModel fromMap(Map<String, dynamic> data) {
    return ExerciseSessionModel(
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      type: ExerciseType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ExerciseType.scale,
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      duration: Duration(seconds: data['duration'] ?? 0),
      attempts: data['attempts'] ?? 0,
      accuracy: (data['accuracy'] ?? 0.0).toDouble(),
      tempo: data['tempo'] ?? 0,
      targetTempo: data['targetTempo'] ?? 0,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == data['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      midiData: (data['midiData'] as List<dynamic>?)
          ?.map((m) => MidiEventModel.fromMap(m))
          .toList() ?? [],
      metrics: Map<String, double>.from(data['metrics'] ?? {}),
      notes: data['notes'],
    );
  }
}

class MidiEventModel {
  final int midiNote;
  final int velocity;
  final DateTime timestamp;
  final Duration relativeTime;
  final MidiEventType eventType;
  final int channel;
  
  Map<String, dynamic> toMap() => {
    'midiNote': midiNote,
    'velocity': velocity,
    'timestamp': Timestamp.fromDate(timestamp),
    'relativeTime': relativeTime.inMilliseconds,
    'eventType': eventType.toString(),
    'channel': channel,
  };
  
  static MidiEventModel fromMap(Map<String, dynamic> data) {
    return MidiEventModel(
      midiNote: data['midiNote'] ?? 0,
      velocity: data['velocity'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      relativeTime: Duration(milliseconds: data['relativeTime'] ?? 0),
      eventType: MidiEventType.values.firstWhere(
        (e) => e.toString() == data['eventType'],
        orElse: () => MidiEventType.noteOn,
      ),
      channel: data['channel'] ?? 0,
    );
  }
}

enum MidiEventType { noteOn, noteOff, controlChange, pitchBend }
```

### Exercise Progress Model

```dart
// Firestore: users/{uid}/practiceData/exercises/{exerciseId}
class ExerciseProgressModel {
  final String exerciseId;
  final String userId;
  final int totalAttempts;
  final double bestAccuracy;
  final int bestTempo;
  final DateTime firstAttempt;
  final DateTime lastPracticed;
  final DateTime? masteryDate;
  final bool isMastered;
  final List<PerformanceRecordModel> recentPerformances;
  final Map<String, double> skillMetrics;
  final List<String> achievedMilestones;
  final int consecutiveSuccesses;
  final Map<String, dynamic> adaptiveSettings;
  
  Map<String, dynamic> toFirestore() => {
    'exerciseId': exerciseId,
    'userId': userId,
    'totalAttempts': totalAttempts,
    'bestAccuracy': bestAccuracy,
    'bestTempo': bestTempo,
    'firstAttempt': Timestamp.fromDate(firstAttempt),
    'lastPracticed': Timestamp.fromDate(lastPracticed),
    'masteryDate': masteryDate != null ? Timestamp.fromDate(masteryDate!) : null,
    'isMastered': isMastered,
    'recentPerformances': recentPerformances.map((p) => p.toMap()).toList(),
    'skillMetrics': skillMetrics,
    'achievedMilestones': achievedMilestones,
    'consecutiveSuccesses': consecutiveSuccesses,
    'adaptiveSettings': adaptiveSettings,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  static ExerciseProgressModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseProgressModel(
      exerciseId: doc.id,
      userId: data['userId'] ?? '',
      totalAttempts: data['totalAttempts'] ?? 0,
      bestAccuracy: (data['bestAccuracy'] ?? 0.0).toDouble(),
      bestTempo: data['bestTempo'] ?? 0,
      firstAttempt: (data['firstAttempt'] as Timestamp).toDate(),
      lastPracticed: (data['lastPracticed'] as Timestamp).toDate(),
      masteryDate: data['masteryDate'] != null
          ? (data['masteryDate'] as Timestamp).toDate()
          : null,
      isMastered: data['isMastered'] ?? false,
      recentPerformances: (data['recentPerformances'] as List<dynamic>?)
          ?.map((p) => PerformanceRecordModel.fromMap(p))
          .toList() ?? [],
      skillMetrics: Map<String, double>.from(data['skillMetrics'] ?? {}),
      achievedMilestones: List<String>.from(data['achievedMilestones'] ?? []),
      consecutiveSuccesses: data['consecutiveSuccesses'] ?? 0,
      adaptiveSettings: Map<String, dynamic>.from(data['adaptiveSettings'] ?? {}),
    );
  }
}

class PerformanceRecordModel {
  final DateTime timestamp;
  final double accuracy;
  final int tempo;
  final Duration duration;
  final int attempts;
  final Map<String, double> metrics;
  final DifficultyLevel difficulty;
  
  Map<String, dynamic> toMap() => {
    'timestamp': Timestamp.fromDate(timestamp),
    'accuracy': accuracy,
    'tempo': tempo,
    'duration': duration.inSeconds,
    'attempts': attempts,
    'metrics': metrics,
    'difficulty': difficulty.toString(),
  };
  
  static PerformanceRecordModel fromMap(Map<String, dynamic> data) {
    return PerformanceRecordModel(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      accuracy: (data['accuracy'] ?? 0.0).toDouble(),
      tempo: data['tempo'] ?? 0,
      duration: Duration(seconds: data['duration'] ?? 0),
      attempts: data['attempts'] ?? 0,
      metrics: Map<String, double>.from(data['metrics'] ?? {}),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == data['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
    );
  }
}
```

### Daily Statistics Model

```dart
// Firestore: users/{uid}/practiceData/dailyStats/{date}
class DailyStatsModel {
  final String userId;
  final DateTime date;
  final Duration totalPracticeTime;
  final int sessionCount;
  final List<String> exercisesCompleted;
  final List<String> exercisesMastered;
  final double averageAccuracy;
  final int averageTempo;
  final Map<ExerciseType, Duration> exerciseTypeBreakdown;
  final int streakDay;
  final Map<String, double> dailyMetrics;
  final List<String> achievementsUnlocked;
  final Map<String, int> skillPointsEarned;
  
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'totalPracticeTime': totalPracticeTime.inSeconds,
    'sessionCount': sessionCount,
    'exercisesCompleted': exercisesCompleted,
    'exercisesMastered': exercisesMastered,
    'averageAccuracy': averageAccuracy,
    'averageTempo': averageTempo,
    'exerciseTypeBreakdown': exerciseTypeBreakdown.map(
      (key, value) => MapEntry(key.toString(), value.inSeconds),
    ),
    'streakDay': streakDay,
    'dailyMetrics': dailyMetrics,
    'achievementsUnlocked': achievementsUnlocked,
    'skillPointsEarned': skillPointsEarned,
    'createdAt': FieldValue.serverTimestamp(),
  };
  
  static DailyStatsModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyStatsModel(
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      totalPracticeTime: Duration(seconds: data['totalPracticeTime'] ?? 0),
      sessionCount: data['sessionCount'] ?? 0,
      exercisesCompleted: List<String>.from(data['exercisesCompleted'] ?? []),
      exercisesMastered: List<String>.from(data['exercisesMastered'] ?? []),
      averageAccuracy: (data['averageAccuracy'] ?? 0.0).toDouble(),
      averageTempo: data['averageTempo'] ?? 0,
      exerciseTypeBreakdown: (data['exerciseTypeBreakdown'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(
                ExerciseType.values.firstWhere((e) => e.toString() == key),
                Duration(seconds: value),
              )) ?? {},
      streakDay: data['streakDay'] ?? 0,
      dailyMetrics: Map<String, double>.from(data['dailyMetrics'] ?? {}),
      achievementsUnlocked: List<String>.from(data['achievementsUnlocked'] ?? []),
      skillPointsEarned: Map<String, int>.from(data['skillPointsEarned'] ?? {}),
    );
  }
}
```

### Achievement Model

```dart
// Firestore: users/{uid}/progress/achievements/{achievementId}
class AchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final AchievementType type;
  final String title;
  final String description;
  final DateTime unlockedAt;
  final Map<String, dynamic> criteria;
  final Map<String, dynamic> metadata;
  final int pointValue;
  final String badgeImageUrl;
  final bool isVisible;
  final AchievementRarity rarity;
  
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'userId': userId,
    'achievementId': achievementId,
    'type': type.toString(),
    'title': title,
    'description': description,
    'unlockedAt': Timestamp.fromDate(unlockedAt),
    'criteria': criteria,
    'metadata': metadata,
    'pointValue': pointValue,
    'badgeImageUrl': badgeImageUrl,
    'isVisible': isVisible,
    'rarity': rarity.toString(),
  };
  
  static AchievementModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      achievementId: data['achievementId'] ?? '',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => AchievementType.practiceTime,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
      criteria: Map<String, dynamic>.from(data['criteria'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      pointValue: data['pointValue'] ?? 0,
      badgeImageUrl: data['badgeImageUrl'] ?? '',
      isVisible: data['isVisible'] ?? true,
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == data['rarity'],
        orElse: () => AchievementRarity.common,
      ),
    );
  }
}

enum AchievementType {
  practiceTime,
  exerciseCompletion,
  streak,
  accuracy,
  tempo,
  skill,
  social,
  challenge
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary
}
```

### Learning Goal Model

```dart
// Firestore: users/{uid}/progress/goals/{goalId}
class LearningGoalModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final DateTime createdAt;
  final DateTime targetDate;
  final DateTime? completedAt;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final Map<String, dynamic> targetCriteria;
  final Map<String, dynamic> currentProgress;
  final List<String> milestones;
  final int priority; // 1-5
  final bool isArchived;
  
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'type': type.toString(),
    'createdAt': Timestamp.fromDate(createdAt),
    'targetDate': Timestamp.fromDate(targetDate),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'progress': progress,
    'isCompleted': isCompleted,
    'targetCriteria': targetCriteria,
    'currentProgress': currentProgress,
    'milestones': milestones,
    'priority': priority,
    'isArchived': isArchived,
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  static LearningGoalModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearningGoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => GoalType.practiceTime,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      progress: (data['progress'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      targetCriteria: Map<String, dynamic>.from(data['targetCriteria'] ?? {}),
      currentProgress: Map<String, dynamic>.from(data['currentProgress'] ?? {}),
      milestones: List<String>.from(data['milestones'] ?? []),
      priority: data['priority'] ?? 3,
      isArchived: data['isArchived'] ?? false,
    );
  }
}

enum GoalType {
  practiceTime,
  exerciseCompletion,
  skillImprovement,
  tempoIncrease,
  accuracyImprovement,
  streak,
  custom
}
```

## Master Exercise Definitions

### Exercise Definition Model

```dart
// Firestore: exercises/{exerciseId}
class ExerciseDefinitionModel {
  final String id;
  final String name;
  final String description;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final List<String> musicalKeys;
  final int minTempo;
  final int maxTempo;
  final int targetTempo;
  final List<PracticeMode> supportedModes;
  final Map<String, dynamic> fingeringPatterns;
  final List<String> prerequisites;
  final List<String> tags;
  final String? instructionsUrl;
  final String? demoAudioUrl;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.toString(),
    'difficulty': difficulty.toString(),
    'musicalKeys': musicalKeys,
    'minTempo': minTempo,
    'maxTempo': maxTempo,
    'targetTempo': targetTempo,
    'supportedModes': supportedModes.map((m) => m.toString()).toList(),
    'fingeringPatterns': fingeringPatterns,
    'prerequisites': prerequisites,
    'tags': tags,
    'instructionsUrl': instructionsUrl,
    'demoAudioUrl': demoAudioUrl,
    'metadata': metadata,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
  
  static ExerciseDefinitionModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseDefinitionModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: ExerciseType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ExerciseType.scale,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == data['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      musicalKeys: List<String>.from(data['musicalKeys'] ?? []),
      minTempo: data['minTempo'] ?? 60,
      maxTempo: data['maxTempo'] ?? 200,
      targetTempo: data['targetTempo'] ?? 120,
      supportedModes: (data['supportedModes'] as List<dynamic>?)
          ?.map((m) => PracticeMode.values.firstWhere(
                (e) => e.toString() == m,
                orElse: () => PracticeMode.handsTogether,
              ))
          .toList() ?? [],
      fingeringPatterns: Map<String, dynamic>.from(data['fingeringPatterns'] ?? {}),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      instructionsUrl: data['instructionsUrl'],
      demoAudioUrl: data['demoAudioUrl'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

enum ExerciseType {
  scale,
  chord,
  arpeggio,
  progression,
  etude,
  technique,
  custom
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced
}

enum PracticeMode {
  leftHand,
  rightHand,
  handsTogether,
  alternating,
  canon,
  contrary
}
```

## Teacher-Student Models

### Teacher Profile Model

```dart
// Firestore: teacherStudents/{teacherId}
class TeacherProfileModel {
  final String teacherId;
  final String displayName;
  final String email;
  final String? institution;
  final List<String> qualifications;
  final Map<String, StudentConnectionModel> students;
  final Map<String, dynamic> teachingPreferences;
  final DateTime createdAt;
  final bool isVerified;
  final String? bio;
  final String? profileImageUrl;
  
  Map<String, dynamic> toFirestore() => {
    'teacherId': teacherId,
    'displayName': displayName,
    'email': email,
    'institution': institution,
    'qualifications': qualifications,
    'students': students.map((key, value) => MapEntry(key, value.toMap())),
    'teachingPreferences': teachingPreferences,
    'createdAt': Timestamp.fromDate(createdAt),
    'isVerified': isVerified,
    'bio': bio,
    'profileImageUrl': profileImageUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class StudentConnectionModel {
  final String studentId;
  final DateTime connectedAt;
  final List<String> permissions;
  final Map<String, dynamic> assignedExercises;
  final String? notes;
  final bool isActive;
  
  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'connectedAt': Timestamp.fromDate(connectedAt),
    'permissions': permissions,
    'assignedExercises': assignedExercises,
    'notes': notes,
    'isActive': isActive,
  };
}
```

## Data Aggregation Models

### Weekly Summary Model

```dart
// Firestore: users/{uid}/practiceData/weeklySummaries/{weekId}
class WeeklySummaryModel {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final Duration totalPracticeTime;
  final int totalSessions;
  final double averageSessionLength;
  final List<String> exercisesPracticed;
  final List<String> exercisesMastered;
  final double weeklyAccuracyAverage;
  final Map<String, int> dailyPracticeDays;
  final int streakDays;
  final Map<ExerciseType, Duration> exerciseTypeDistribution;
  final List<String> goalsCompleted;
  final List<String> achievementsUnlocked;
  final Map<String, double> skillProgressMetrics;
  
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'weekStart': Timestamp.fromDate(weekStart),
    'weekEnd': Timestamp.fromDate(weekEnd),
    'totalPracticeTime': totalPracticeTime.inSeconds,
    'totalSessions': totalSessions,
    'averageSessionLength': averageSessionLength,
    'exercisesPracticed': exercisesPracticed,
    'exercisesMastered': exercisesMastered,
    'weeklyAccuracyAverage': weeklyAccuracyAverage,
    'dailyPracticeDays': dailyPracticeDays,
    'streakDays': streakDays,
    'exerciseTypeDistribution': exerciseTypeDistribution.map(
      (key, value) => MapEntry(key.toString(), value.inSeconds),
    ),
    'goalsCompleted': goalsCompleted,
    'achievementsUnlocked': achievementsUnlocked,
    'skillProgressMetrics': skillProgressMetrics,
    'generatedAt': FieldValue.serverTimestamp(),
  };
}
```

## Offline Data Models

### Local Database Schema

```dart
// SQLite Local Database Models
class LocalPracticeSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String exerciseData; // JSON string
  final bool isSynced;
  final DateTime createdAt;
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'exerciseData': exerciseData,
    'isSynced': isSynced ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
  };
  
  static LocalPracticeSession fromMap(Map<String, dynamic> map) {
    return LocalPracticeSession(
      id: map['id'],
      userId: map['userId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      exerciseData: map['exerciseData'],
      isSynced: map['isSynced'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class SyncQueueItem {
  final String id;
  final String type; // 'practice_session', 'exercise_progress', etc.
  final String itemId;
  final String operation; // 'create', 'update', 'delete'
  final String data; // JSON string
  final DateTime createdAt;
  final int retryCount;
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'itemId': itemId,
    'operation': operation,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };
}
```

## Data Query Patterns

### Common Queries

```dart
class FirestoreQueries {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get recent practice sessions
  Query<Map<String, dynamic>> getRecentSessions(String userId, {int limit = 10}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('sessions')
        .orderBy('startTime', descending: true)
        .limit(limit);
  }
  
  // Get exercise progress for specific exercises
  Query<Map<String, dynamic>> getExerciseProgress(String userId, List<String> exerciseIds) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('exercises')
        .where(FieldPath.documentId, whereIn: exerciseIds);
  }
  
  // Get daily stats for date range
  Query<Map<String, dynamic>> getDailyStatsRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('dailyStats')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date');
  }
  
  // Get achievements by type
  Query<Map<String, dynamic>> getAchievementsByType(String userId, AchievementType type) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .collection('achievements')
        .where('type', isEqualTo: type.toString())
        .orderBy('unlockedAt', descending: true);
  }
  
  // Get active learning goals
  Query<Map<String, dynamic>> getActiveGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .collection('goals')
        .where('isCompleted', isEqualTo: false)
        .where('isArchived', isEqualTo: false)
        .orderBy('priority', descending: true)
        .orderBy('targetDate');
  }
}
```

## Data Migration and Versioning

### Schema Version Management

```dart
class SchemaVersion {
  static const int currentVersion = 1;
  
  static Future<void> migrateIfNeeded(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    final currentUserVersion = userDoc.data()?['schemaVersion'] ?? 0;
    
    if (currentUserVersion < currentVersion) {
      await _performMigration(userId, currentUserVersion, currentVersion);
    }
  }
  
  static Future<void> _performMigration(
    String userId,
    int fromVersion,
    int toVersion,
  ) async {
    // Migration logic based on version differences
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      switch (version) {
        case 1:
          await _migrateToV1(userId);
          break;
        // Add future migrations here
      }
    }
    
    // Update schema version
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'schemaVersion': toVersion});
  }
  
  static Future<void> _migrateToV1(String userId) async {
    // Example migration: Add new fields to existing documents
    // This would be specific migration logic
  }
}
```

## Performance Optimization

### Data Indexing Strategy

```javascript
// Firestore Indexes (firestore.indexes.json)
{
  "indexes": [
    {
      "collectionGroup": "sessions",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "startTime", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "exercises",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "lastPracticed", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "dailyStats",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "date", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "achievements",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "type", "order": "ASCENDING"},
        {"fieldPath": "unlockedAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

### Data Size Optimization

- **Batch Operations**: Use Firestore batch writes for multiple updates
- **Pagination**: Implement cursor-based pagination for large result sets
- **Data Aggregation**: Pre-calculate summary statistics to reduce query complexity
- **Field Selection**: Only query necessary fields to reduce bandwidth
- **Caching**: Implement local caching for frequently accessed data

## Security and Privacy

### Data Encryption

- **Field-Level Encryption**: Sensitive data encrypted before storage
- **Key Management**: User-specific encryption keys
- **PII Protection**: Personal information anonymized in analytics
- **Data Minimization**: Only store necessary data for functionality

### Audit Trail

```dart
class AuditLogModel {
  final String id;
  final String userId;
  final String action;
  final String resource;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'userId': userId,
    'action': action,
    'resource': resource,
    'metadata': metadata,
    'timestamp': Timestamp.fromDate(timestamp),
    'ipAddress': ipAddress,
    'userAgent': userAgent,
  };
}
```

This comprehensive Firebase data model specification provides the foundation for a scalable, secure, and feature-rich piano learning application with robust offline capabilities and cross-device synchronization.
