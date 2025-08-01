# Authentication & Authorization System Specification

## Overview

The Piano Fitness authentication system provides secure user management and data synchronization across devices using Firebase Authentication and Firestore. The system supports multiple authentication methods while maintaining privacy and security standards appropriate for educational applications.

## Authentication Flow

### Supported Authentication Methods

#### Primary Methods
- **Email/Password**: Traditional account creation with email verification
- **Google Sign-In**: Streamlined authentication using Google accounts
- **Apple Sign-In**: Required for iOS App Store compliance
- **Guest Mode**: Limited functionality without account creation

#### Future Authentication Methods
- **Microsoft Azure AD**: For educational institution integration
- **SAML/SSO**: Enterprise and school district authentication
- **Magic Links**: Passwordless authentication via email

### Authentication Architecture
```dart
class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Authentication methods
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> signUpWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential?> signInWithApple();
  Future<void> signInAsGuest();
  Future<void> signOut();
  
  // Account management
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount();
}
```

## User Profile Management

### User Data Model
```dart
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserPreferences preferences;
  final LearningProfile learningProfile;
  final List<String> connectedDevices;
  final AccountType accountType;
  
  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    required this.preferences,
    required this.learningProfile,
    required this.connectedDevices,
    required this.accountType,
  });
  
  Map<String, dynamic> toFirestore();
  static UserProfile fromFirestore(DocumentSnapshot doc);
}

enum AccountType {
  free,
  premium,
  student,
  teacher,
  institution
}
```

### User Preferences
```dart
class UserPreferences {
  final String preferredLanguage;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool analyticsEnabled;
  final MetronomePreferences metronomePreferences;
  final DisplayPreferences displayPreferences;
  final PrivacySettings privacySettings;
  
  const UserPreferences({
    this.preferredLanguage = 'en',
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.analyticsEnabled = true,
    required this.metronomePreferences,
    required this.displayPreferences,
    required this.privacySettings,
  });
}

class MetronomePreferences {
  final MetronomeSound defaultSound;
  final int defaultTempo;
  final TimeSignature defaultTimeSignature;
  final bool visualPulseEnabled;
  
  const MetronomePreferences({
    this.defaultSound = MetronomeSound.click,
    this.defaultTempo = 120,
    this.defaultTimeSignature = TimeSignature.fourFour,
    this.visualPulseEnabled = true,
  });
}

class PrivacySettings {
  final bool shareProgressWithTeachers;
  final bool allowAnonymousAnalytics;
  final bool syncAcrossDevices;
  final DataRetentionPeriod dataRetentionPeriod;
  
  const PrivacySettings({
    this.shareProgressWithTeachers = false,
    this.allowAnonymousAnalytics = true,
    this.syncAcrossDevices = true,
    this.dataRetentionPeriod = DataRetentionPeriod.twoYears,
  });
}

enum DataRetentionPeriod {
  sixMonths,
  oneYear,
  twoYears,
  indefinite
}
```

### Learning Profile
```dart
class LearningProfile {
  final SkillLevel currentSkillLevel;
  final List<String> completedExercises;
  final Map<String, DateTime> exerciseMasteryDates;
  final List<LearningGoal> currentGoals;
  final Map<String, double> skillAssessments;
  final TeacherConnection? teacherConnection;
  
  const LearningProfile({
    required this.currentSkillLevel,
    required this.completedExercises,
    required this.exerciseMasteryDates,
    required this.currentGoals,
    required this.skillAssessments,
    this.teacherConnection,
  });
}

enum SkillLevel {
  beginner,
  earlyIntermediate,
  intermediate,
  lateIntermediate,
  earlyAdvanced,
  advanced,
  expert
}

class LearningGoal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final DateTime targetDate;
  final double progress;
  final bool isCompleted;
  
  const LearningGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetDate,
    required this.progress,
    required this.isCompleted,
  });
}

enum GoalType {
  practiceTime,
  exerciseCompletion,
  skillImprovement,
  tempoIncrease,
  accuracyImprovement
}
```

## Firebase Data Architecture

### Firestore Database Structure
```
users/{uid}
├── profile/
│   ├── email: string
│   ├── displayName: string
│   ├── createdAt: timestamp
│   ├── lastLoginAt: timestamp
│   ├── accountType: string
│   └── preferences: object
├── practiceData/
│   ├── sessions/{sessionId}
│   │   ├── startTime: timestamp
│   │   ├── endTime: timestamp
│   │   ├── totalDuration: number (seconds)
│   │   ├── exercises: array
│   │   └── metrics: object
│   ├── exercises/{exerciseId}
│   │   ├── attempts: number
│   │   ├── bestAccuracy: number
│   │   ├── bestTempo: number
│   │   ├── masteryDate: timestamp
│   │   └── recentPerformances: array
│   └── dailyStats/{date}
│       ├── totalPracticeTime: number
│       ├── sessionCount: number
│       ├── exercisesCompleted: array
│       └── averageAccuracy: number
├── progress/
│   ├── achievements/{achievementId}
│   │   ├── unlockedAt: timestamp
│   │   ├── type: string
│   │   └── metadata: object
│   ├── streaks/
│   │   ├── current: number
│   │   ├── longest: number
│   │   └── history: array
│   └── milestones/{milestoneId}
│       ├── achievedAt: timestamp
│       ├── skillLevel: string
│       └── notes: string
└── settings/
    ├── metronome: object
    ├── display: object
    └── privacy: object
```

### Security Rules
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Practice data subcollection
      match /practiceData/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Progress data subcollection
      match /progress/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Settings subcollection
      match /settings/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public exercise definitions (read-only)
    match /exercises/{exerciseId} {
      allow read: if true;
      allow write: if false; // Only server can write
    }
    
    // Teacher-student connections
    match /teacherStudents/{teacherId} {
      allow read: if request.auth != null && 
        (request.auth.uid == teacherId || 
         resource.data.students[request.auth.uid] != null);
      allow write: if request.auth != null && request.auth.uid == teacherId;
    }
  }
}
```

## Data Synchronization

### Real-time Synchronization Service
```dart
class DataSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  
  DataSyncService(this.userId);
  
  // Practice session synchronization
  Stream<List<PracticeSession>> get practiceSessionsStream {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('sessions')
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PracticeSession.fromFirestore(doc))
            .toList());
  }
  
  // Save practice session
  Future<void> savePracticeSession(PracticeSession session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('sessions')
        .doc(session.id)
        .set(session.toFirestore());
    
    // Update daily statistics
    await _updateDailyStats(session);
  }
  
  // Update daily statistics
  Future<void> _updateDailyStats(PracticeSession session) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(session.startTime);
    final dailyStatsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('dailyStats')
        .doc(dateKey);
    
    await _firestore.runTransaction((transaction) async {
      final dailyStats = await transaction.get(dailyStatsRef);
      
      if (dailyStats.exists) {
        // Update existing stats
        final data = dailyStats.data()!;
        transaction.update(dailyStatsRef, {
          'totalPracticeTime': data['totalPracticeTime'] + session.totalDuration.inSeconds,
          'sessionCount': data['sessionCount'] + 1,
          'exercisesCompleted': FieldValue.arrayUnion(
            session.exercises.map((e) => e.exerciseId).toList(),
          ),
        });
      } else {
        // Create new daily stats
        transaction.set(dailyStatsRef, {
          'date': session.startTime,
          'totalPracticeTime': session.totalDuration.inSeconds,
          'sessionCount': 1,
          'exercisesCompleted': session.exercises.map((e) => e.exerciseId).toList(),
          'averageAccuracy': session.exercises.isEmpty ? 0.0 : 
            session.exercises.map((e) => e.accuracy).reduce((a, b) => a + b) / session.exercises.length,
        });
      }
    });
  }
  
  // Sync exercise progress
  Future<void> syncExerciseProgress(String exerciseId, ExercisePerformance performance) async {
    final exerciseRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('exercises')
        .doc(exerciseId);
    
    await _firestore.runTransaction((transaction) async {
      final exerciseDoc = await transaction.get(exerciseRef);
      
      if (exerciseDoc.exists) {
        final data = exerciseDoc.data()!;
        transaction.update(exerciseRef, {
          'attempts': data['attempts'] + 1,
          'bestAccuracy': math.max(data['bestAccuracy'] ?? 0.0, performance.accuracy),
          'bestTempo': math.max(data['bestTempo'] ?? 0, performance.tempo),
          'lastPracticed': FieldValue.serverTimestamp(),
          'recentPerformances': FieldValue.arrayUnion([performance.toMap()]),
        });
      } else {
        transaction.set(exerciseRef, {
          'exerciseId': exerciseId,
          'attempts': 1,
          'bestAccuracy': performance.accuracy,
          'bestTempo': performance.tempo,
          'firstAttempt': FieldValue.serverTimestamp(),
          'lastPracticed': FieldValue.serverTimestamp(),
          'recentPerformances': [performance.toMap()],
        });
      }
    });
  }
}
```

### Offline Data Handling
```dart
class OfflineDataManager {
  final LocalDatabase _localDb;
  final DataSyncService _syncService;
  
  OfflineDataManager(this._localDb, this._syncService);
  
  // Save practice session locally when offline
  Future<void> savePracticeSessionLocally(PracticeSession session) async {
    await _localDb.insertPracticeSession(session);
    
    // Mark for sync when online
    await _localDb.addToSyncQueue('practice_session', session.id);
  }
  
  // Sync queued data when connection restored
  Future<void> syncQueuedData() async {
    final queuedItems = await _localDb.getSyncQueue();
    
    for (final item in queuedItems) {
      try {
        switch (item.type) {
          case 'practice_session':
            final session = await _localDb.getPracticeSession(item.itemId);
            if (session != null) {
              await _syncService.savePracticeSession(session);
              await _localDb.removeFromSyncQueue(item.id);
            }
            break;
          case 'exercise_progress':
            // Handle exercise progress sync
            break;
        }
      } catch (e) {
        // Handle sync errors - retry later
        print('Sync error for ${item.type}:${item.itemId}: $e');
      }
    }
  }
  
  // Check if device is online
  bool get isOnline => /* connectivity check */;
  
  // Stream of connectivity changes
  Stream<bool> get connectivityStream => /* connectivity stream */;
}
```

## Teacher-Student Integration

### Teacher Dashboard Access
```dart
class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String teacherId;
  
  TeacherService(this.teacherId);
  
  // Get teacher's students
  Stream<List<StudentSummary>> get studentsStream {
    return _firestore
        .collection('teacherStudents')
        .doc(teacherId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return <StudentSummary>[];
      
      final studentIds = Map<String, dynamic>.from(doc.data()!['students'] ?? {}).keys.toList();
      final studentSummaries = <StudentSummary>[];
      
      for (final studentId in studentIds) {
        final summary = await _getStudentSummary(studentId);
        if (summary != null) studentSummaries.add(summary);
      }
      
      return studentSummaries;
    });
  }
  
  // Add student to teacher's class
  Future<void> addStudent(String studentId, String inviteCode) async {
    // Verify invite code
    final isValidCode = await _verifyInviteCode(inviteCode, studentId);
    if (!isValidCode) throw Exception('Invalid invite code');
    
    // Add student to teacher's list
    await _firestore
        .collection('teacherStudents')
        .doc(teacherId)
        .set({
      'students.$studentId': {
        'addedAt': FieldValue.serverTimestamp(),
        'permissions': ['view_progress', 'assign_exercises'],
      }
    }, SetOptions(merge: true));
    
    // Update student's teacher connection
    await _firestore
        .collection('users')
        .doc(studentId)
        .update({
      'learningProfile.teacherConnection': {
        'teacherId': teacherId,
        'connectedAt': FieldValue.serverTimestamp(),
        'permissions': ['share_progress'],
      }
    });
  }
  
  // Get student progress summary
  Future<StudentProgressSummary?> getStudentProgress(String studentId) async {
    // Check if teacher has permission to view this student
    final hasPermission = await _hasStudentPermission(studentId, 'view_progress');
    if (!hasPermission) return null;
    
    final progressDoc = await _firestore
        .collection('users')
        .doc(studentId)
        .collection('progress')
        .doc('summary')
        .get();
    
    if (!progressDoc.exists) return null;
    return StudentProgressSummary.fromFirestore(progressDoc);
  }
}

class StudentSummary {
  final String studentId;
  final String displayName;
  final DateTime lastActive;
  final int totalPracticeHours;
  final double averageAccuracy;
  final int currentStreak;
  
  const StudentSummary({
    required this.studentId,
    required this.displayName,
    required this.lastActive,
    required this.totalPracticeHours,
    required this.averageAccuracy,
    required this.currentStreak,
  });
}
```

## Privacy and Security

### Data Privacy Implementation
```dart
class PrivacyManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  
  PrivacyManager(this.userId);
  
  // Export user data (GDPR compliance)
  Future<Map<String, dynamic>> exportUserData() async {
    final userData = <String, dynamic>{};
    
    // Export profile data
    final profileDoc = await _firestore.collection('users').doc(userId).get();
    userData['profile'] = profileDoc.data();
    
    // Export practice sessions
    final sessionsQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .collection('sessions')
        .get();
    userData['practiceSessions'] = sessionsQuery.docs.map((doc) => doc.data()).toList();
    
    // Export progress data
    final progressQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .get();
    userData['progress'] = progressQuery.docs.map((doc) => doc.data()).toList();
    
    return userData;
  }
  
  // Delete user data (GDPR compliance)
  Future<void> deleteUserData() async {
    final batch = _firestore.batch();
    
    // Delete practice data
    final practiceDataQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('practiceData')
        .get();
    
    for (final doc in practiceDataQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete progress data
    final progressQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('progress')
        .get();
    
    for (final doc in progressQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete user profile
    batch.delete(_firestore.collection('users').doc(userId));
    
    await batch.commit();
    
    // Delete Firebase Auth account
    await FirebaseAuth.instance.currentUser?.delete();
  }
  
  // Anonymize user data for analytics
  Future<void> anonymizeUserData() async {
    final anonymizedId = _generateAnonymousId();
    
    // Create anonymized copy of relevant data
    await _firestore.collection('anonymizedData').doc(anonymizedId).set({
      'practicePatterns': await _getAnonymizedPracticePatterns(),
      'learningProgress': await _getAnonymizedLearningProgress(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

### Security Best Practices
- **Authentication Required**: All user data access requires valid authentication
- **Data Ownership**: Users can only access their own data
- **Encrypted Storage**: Sensitive data encrypted at rest and in transit
- **Audit Logging**: User actions logged for security monitoring
- **Rate Limiting**: API calls rate-limited to prevent abuse
- **Input Validation**: All user inputs validated and sanitized

## Account Management

### Account Lifecycle
```dart
class AccountManager {
  final AuthenticationService _authService;
  final DataSyncService _syncService;
  final PrivacyManager _privacyManager;
  
  AccountManager(this._authService, this._syncService, this._privacyManager);
  
  // Create new account
  Future<UserProfile> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final userCredential = await _authService.signUpWithEmail(email, password);
    if (userCredential?.user == null) throw Exception('Account creation failed');
    
    final user = userCredential!.user!;
    
    // Create user profile
    final profile = UserProfile(
      uid: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName,
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: UserPreferences.defaults(),
      learningProfile: LearningProfile.initial(),
      connectedDevices: [],
      accountType: AccountType.free,
    );
    
    // Save to Firestore
    await _syncService.saveUserProfile(profile);
    
    // Send email verification
    await _authService.sendEmailVerification();
    
    return profile;
  }
  
  // Upgrade account
  Future<void> upgradeAccount(AccountType newAccountType) async {
    // Handle payment processing here
    
    // Update account type
    await _syncService.updateAccountType(newAccountType);
    
    // Unlock premium features
    await _unlockPremiumFeatures(newAccountType);
  }
  
  // Merge guest account with permanent account
  Future<void> convertGuestAccount(String email, String password) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('No guest account to convert');
    }
    
    // Create email credential
    final credential = EmailAuthProvider.credential(email: email, password: password);
    
    // Link credential to anonymous account
    await currentUser.linkWithCredential(credential);
    
    // Update user profile
    await _syncService.updateUserProfile({
      'email': email,
      'accountType': AccountType.free.toString(),
    });
    
    // Send verification email
    await _authService.sendEmailVerification();
  }
}
```

## Testing and Validation

### Authentication Testing
```dart
class AuthenticationTest {
  static Future<void> testEmailSignUp() async {
    final authService = AuthenticationService();
    
    // Test successful sign up
    final result = await authService.signUpWithEmail('test@example.com', 'password123');
    expect(result, isNotNull);
    expect(result!.user!.email, equals('test@example.com'));
    
    // Test duplicate email
    try {
      await authService.signUpWithEmail('test@example.com', 'password456');
      fail('Should throw exception for duplicate email');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
    }
  }
  
  static Future<void> testDataSynchronization() async {
    final syncService = DataSyncService('test_user_id');
    
    final session = PracticeSession(
      id: 'test_session',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(minutes: 30)),
      exercises: [],
    );
    
    await syncService.savePracticeSession(session);
    
    // Verify data was saved
    final sessions = await syncService.practiceSessionsStream.first;
    expect(sessions.any((s) => s.id == 'test_session'), isTrue);
  }
}
```

## Future Enhancements

### Phase 2 Features
- **Multi-factor Authentication**: SMS and authenticator app support
- **Social Login**: Facebook, Twitter, and other social providers
- **Single Sign-On**: Integration with school and organization systems
- **Biometric Authentication**: Fingerprint and Face ID support

### Phase 3 Features
- **Blockchain Identity**: Decentralized identity verification
- **Zero-Knowledge Proofs**: Privacy-preserving authentication
- **Advanced Analytics**: AI-powered user behavior analysis
- **Cross-Platform Sync**: Real-time sync across all platforms and devices