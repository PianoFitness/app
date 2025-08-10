import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/shared/services/chord_detection_service.dart";

/// Test case data structure for parameterized chord detection tests
class ChordTestCase {
  const ChordTestCase({
    required this.name,
    required this.midiNotes,
    required this.expectedChordName,
    required this.expectedRootNote,
    required this.expectedConfidence,
    required this.category,
    required this.status,
    this.description,
  });

  final String name;
  final Set<int> midiNotes;
  final String expectedChordName;
  final String expectedRootNote;
  final double expectedConfidence;
  final String category;
  final TestStatus status;
  final String? description;
}

enum TestStatus {
  implemented,
  partial,
  notImplemented,
}

void main() {
  group("ChordDetectionService", () {
    test("should return null for less than 3 notes", () {
      final result = ChordDetectionService.detectChord({60, 64});
      expect(result, isNull);
    });

    // Parameterized chord detection tests
    group("Chord Quality Detection", () {
      final chordTestCases = [
        // ================== BASIC TRIADS ==================
        ChordTestCase(
          name: "C Major",
          midiNotes: {60, 64, 67}, // C, E, G
          expectedChordName: "C Major",
          expectedRootNote: "C",
          expectedConfidence: 0.85,
          category: "Basic Triads",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "A Minor",
          midiNotes: {57, 60, 64}, // A, C, E
          expectedChordName: "A Minor",
          expectedRootNote: "A",
          expectedConfidence: 0.85,
          category: "Basic Triads",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "G Augmented",
          midiNotes: {67, 71, 75}, // G, B, D♯
          expectedChordName: "G Aug",
          expectedRootNote: "G",
          expectedConfidence: 0.8,
          category: "Basic Triads",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "B Diminished",
          midiNotes: {71, 74, 77}, // B, D, F
          expectedChordName: "B Dim",
          expectedRootNote: "B",
          expectedConfidence: 0.8,
          category: "Basic Triads",
          status: TestStatus.implemented,
        ),

        // ================== POWER CHORDS ==================
        ChordTestCase(
          name: "C Power Chord",
          midiNotes: {60, 67}, // C, G (only 2 notes)
          expectedChordName: "C5",
          expectedRootNote: "C",
          expectedConfidence: 0.8,
          category: "Power Chords",
          status: TestStatus.implemented,
          description: "Root + perfect 5th",
        ),

        // ================== SUSPENDED CHORDS ==================
        ChordTestCase(
          name: "C Sus2",
          midiNotes: {60, 62, 67}, // C, D, G
          expectedChordName: "C sus2",
          expectedRootNote: "C",
          expectedConfidence: 0.7,
          category: "Suspended Chords",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "F Sus4",
          midiNotes: {53, 58, 60}, // F, A♯, C (F + 4th + 5th)
          expectedChordName: "F sus4",
          expectedRootNote: "F",
          expectedConfidence: 0.7,
          category: "Suspended Chords",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "G Sus2Sus4",
          midiNotes: {67, 69, 72, 74}, // G, A, C, D
          expectedChordName: "G sus24",
          expectedRootNote: "G",
          expectedConfidence: 0.75,
          category: "Suspended Chords",
          status: TestStatus.implemented,
          description: "Both 2nd and 4th suspended",
        ),

        // ================== SUSPENDED SEVENTH CHORDS ==================
        ChordTestCase(
          name: "D 7sus4",
          midiNotes: {62, 67, 69, 72}, // D, G, A, C
          expectedChordName: "D 7sus4",
          expectedRootNote: "D",
          expectedConfidence: 0.9,
          category: "Suspended Seventh Chords",
          status: TestStatus.implemented,
          description: "Dominant 7th with suspended 4th",
        ),
        ChordTestCase(
          name: "G 7sus2",
          midiNotes: {67, 69, 74, 77}, // G, A, D, F
          expectedChordName: "G 7sus2",
          expectedRootNote: "G",
          expectedConfidence: 0.88,
          category: "Suspended Seventh Chords",
          status: TestStatus.implemented,
          description: "Dominant 7th with suspended 2nd",
        ),

        // ================== ADD & SIXTH CHORDS (NO 7TH) ==================
        ChordTestCase(
          name: "C Major 6/9",
          midiNotes: {60, 64, 67, 69, 74}, // C, E, G, A, D
          expectedChordName: "C 6/9",
          expectedRootNote: "C",
          expectedConfidence: 0.93,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Major 6th with added 9th",
        ),
        ChordTestCase(
          name: "A Minor 6/9",
          midiNotes: {57, 60, 64, 66, 71}, // A, C, E, F♯, B
          expectedChordName: "A m6/9",
          expectedRootNote: "A",
          expectedConfidence: 0.92,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Minor 6th with added 9th",
        ),
        ChordTestCase(
          name: "C Major 6th",
          midiNotes: {60, 64, 67, 69}, // C, E, G, A
          expectedChordName: "C 6",
          expectedRootNote: "C",
          expectedConfidence: 0.95,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Major triad + major 6th",
        ),
        ChordTestCase(
          name: "A Minor 6th",
          midiNotes: {57, 60, 64, 66}, // A, C, E, F♯
          expectedChordName: "A m6",
          expectedRootNote: "A",
          expectedConfidence: 0.92,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Minor triad + major 6th",
        ),
        ChordTestCase(
          name: "C Add9",
          midiNotes: {60, 64, 67, 74}, // C, E, G, D (no 7th)
          expectedChordName: "C add9",
          expectedRootNote: "C",
          expectedConfidence: 0.88,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Major triad + 9th without 7th",
        ),
        ChordTestCase(
          name: "F Minor Add9",
          midiNotes: {53, 56, 60, 62}, // F, A♭, C, D
          expectedChordName: "F madd9",
          expectedRootNote: "F",
          expectedConfidence: 0.88,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Minor triad + 9th without 7th",
        ),
        ChordTestCase(
          name: "G Add11",
          midiNotes: {67, 71, 74, 72}, // G, B, D, C
          expectedChordName: "G add11",
          expectedRootNote: "G",
          expectedConfidence: 0.86,
          category: "Add & Sixth Chords",
          status: TestStatus.implemented,
          description: "Major triad + 11th without 7th",
        ),

        // ================== ALTERED DOMINANTS ==================
        ChordTestCase(
          name: "C 7♭5",
          midiNotes: {60, 64, 66, 70}, // C, E, G♭, B♭
          expectedChordName: "C 7♭5",
          expectedRootNote: "C",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with flat 5th",
        ),
        ChordTestCase(
          name: "F 7♯5",
          midiNotes: {53, 57, 61, 63}, // F, A, C♯, E♭
          expectedChordName: "F 7♯5",
          expectedRootNote: "F",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with sharp 5th",
        ),
        ChordTestCase(
          name: "G 7♭9",
          midiNotes: {67, 71, 74, 77, 68}, // G, B, D, F, A♭
          expectedChordName: "G 7♭9",
          expectedRootNote: "G",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with flat 9th",
        ),
        ChordTestCase(
          name: "D 7♯9",
          midiNotes: {62, 66, 69, 72, 67}, // D, F♯, A, C, G♯
          expectedChordName: "D 7♯9",
          expectedRootNote: "D",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with sharp 9th",
        ),
        ChordTestCase(
          name: "A 7♯11",
          midiNotes: {57, 61, 64, 67, 63}, // A, C♯, E, G, D♯
          expectedChordName: "A 7♯11",
          expectedRootNote: "A",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with sharp 11th",
        ),
        ChordTestCase(
          name: "E 7♭13",
          midiNotes: {64, 68, 74, 72}, // E, G♯, D, C
          expectedChordName: "E 7♭13",
          expectedRootNote: "E",
          expectedConfidence: 0.9,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with flat 13th",
        ),
        ChordTestCase(
          name: "C 7(♭9,♭13)",
          midiNotes: {60, 64, 70, 61, 68}, // C, E, B♭, D♭, A♭
          expectedChordName: "C 7(♭9,♭13)",
          expectedRootNote: "C",
          expectedConfidence: 0.88,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with flat 9th and flat 13th",
        ),
        ChordTestCase(
          name: "F 7(♭9,♯11)",
          midiNotes: {53, 57, 63, 54, 59}, // F, A, E♭, F♯, B
          expectedChordName: "F 7(♭9,♯11)",
          expectedRootNote: "F",
          expectedConfidence: 0.88,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with flat 9th and sharp 11th",
        ),
        ChordTestCase(
          name: "G 7(♯9,♭13)",
          midiNotes: {67, 71, 77, 70, 75}, // G, B, F, A♯, E♭ (corrected A♯ = 70)
          expectedChordName: "G 7(♯9,♭13)",
          expectedRootNote: "G",
          expectedConfidence: 0.88,
          category: "Altered Dominants",
          status: TestStatus.implemented,
          description: "Dominant 7th with sharp 9th and flat 13th",
        ),

        // ================== SPECIAL SEVENTH CHORDS ==================
        ChordTestCase(
          name: "C Diminished 7th",
          midiNotes: {60, 63, 66, 69}, // C, E♭, G♭, B♭♭(A)
          expectedChordName: "C dim7",
          expectedRootNote: "C",
          expectedConfidence: 0.92,
          category: "Special Seventh Chords",
          status: TestStatus.implemented,
          description: "Fully diminished 7th chord",
        ),
        ChordTestCase(
          name: "B Half-Diminished 7th",
          midiNotes: {71, 74, 77, 81}, // B, D, F, A
          expectedChordName: "B m7♭5",
          expectedRootNote: "B",
          expectedConfidence: 0.9,
          category: "Special Seventh Chords",
          status: TestStatus.implemented,
          description: "Also known as B ø7",
        ),

        // ================== EXTENSIONS (WITH 7TH IMPLIED) ==================
        ChordTestCase(
          name: "C Major 13♯11",
          midiNotes: {60, 64, 67, 71, 66, 69}, // C, E, G, B, F♯, A
          expectedChordName: "C maj13♯11",
          expectedRootNote: "C",
          expectedConfidence: 0.97,
          category: "Extensions",
          status: TestStatus.implemented,
          description: "Major 13th with sharp 11th",
        ),
        ChordTestCase(
          name: "F Major 13th",
          midiNotes: {53, 57, 60, 64, 62}, // F, A, C, E, D
          expectedChordName: "F maj13",
          expectedRootNote: "F",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "A Minor 13th",
          midiNotes: {57, 60, 64, 67, 66}, // A, C, E, G, F♯
          expectedChordName: "A m13",
          expectedRootNote: "A",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "G 13th",
          midiNotes: {67, 71, 74, 77, 64}, // G, B, D, F, E
          expectedChordName: "G 13",
          expectedRootNote: "G",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "D Major 7♯11",
          midiNotes: {62, 66, 69, 73, 68}, // D, F♯, A, C♯, A♯
          expectedChordName: "D maj7♯11",
          expectedRootNote: "D",
          expectedConfidence: 0.93,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "E Minor 11th",
          midiNotes: {64, 67, 71, 74, 69}, // E, G, B, D, A
          expectedChordName: "E m11",
          expectedRootNote: "E",
          expectedConfidence: 0.94,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "C 11th",
          midiNotes: {60, 65, 67, 70, 74}, // C, F, G, B♭, D
          expectedChordName: "C 11",
          expectedRootNote: "C",
          expectedConfidence: 0.94,
          category: "Extensions",
          status: TestStatus.implemented,
          description: "Equivalent to C9sus4",
        ),
        ChordTestCase(
          name: "C Major 11th",
          midiNotes: {60, 64, 67, 71, 74, 77}, // C, E, G, B, D, F
          expectedChordName: "C maj11",
          expectedRootNote: "C",
          expectedConfidence: 0.95,
          category: "Extensions",
          status: TestStatus.implemented,
          description: "Major 11th chord with 9th and 11th extensions",
        ),
        ChordTestCase(
          name: "F Major 9th",
          midiNotes: {53, 57, 60, 64, 67}, // F, A, C, E, G
          expectedChordName: "F maj9",
          expectedRootNote: "F",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "B Minor 9th",
          midiNotes: {71, 74, 78, 81, 73}, // B, D, F♯, A, C♯
          expectedChordName: "B m9",
          expectedRootNote: "B",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "A 9th",
          midiNotes: {57, 61, 64, 67, 71}, // A, C♯, E, G, B
          expectedChordName: "A 9",
          expectedRootNote: "A",
          expectedConfidence: 0.96,
          category: "Extensions",
          status: TestStatus.implemented,
        ),

        // ================== REGULAR SEVENTH CHORDS ==================
        ChordTestCase(
          name: "A Minor Major 7th",
          midiNotes: {57, 60, 64, 68}, // A, C, E, G♯
          expectedChordName: "A mMaj7",
          expectedRootNote: "A",
          expectedConfidence: 0.95,
          category: "Regular Seventh Chords",
          status: TestStatus.implemented,
          description: "Minor triad with major 7th interval",
        ),
        ChordTestCase(
          name: "C Major 7th",
          midiNotes: {60, 64, 67, 71}, // C, E, G, B
          expectedChordName: "C maj7",
          expectedRootNote: "C",
          expectedConfidence: 0.95,
          category: "Regular Seventh Chords",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "D Minor 7th",
          midiNotes: {62, 65, 69, 72}, // D, F, A, C
          expectedChordName: "D m7",
          expectedRootNote: "D",
          expectedConfidence: 0.95,
          category: "Regular Seventh Chords",
          status: TestStatus.implemented,
        ),
        ChordTestCase(
          name: "G Dominant 7th",
          midiNotes: {67, 71, 74, 77}, // G, B, D, F
          expectedChordName: "G 7",
          expectedRootNote: "G",
          expectedConfidence: 0.95,
          category: "Regular Seventh Chords",
          status: TestStatus.implemented,
        ),
      ];

      // Generate test coverage report
      final implementedCount = chordTestCases
          .where((test) => test.status == TestStatus.implemented)
          .length;
      final totalCount = chordTestCases.length;
      final coveragePercentage = ((implementedCount / totalCount) * 100).round();

      print("\n📊 CHORD DETECTION TEST COVERAGE REPORT");
      print("════════════════════════════════════════════════");
      print("Implemented: $implementedCount/$totalCount ($coveragePercentage%)");

      // Group by category for detailed report
      final categories = chordTestCases.map((test) => test.category).toSet();
      for (final category in categories) {
        final categoryTests = chordTestCases.where((test) => test.category == category);
        final categoryImplemented = categoryTests
            .where((test) => test.status == TestStatus.implemented)
            .length;
        final categoryTotal = categoryTests.length;
        final categoryPercentage = ((categoryImplemented / categoryTotal) * 100).round();
        
        final statusIcon = categoryPercentage == 100 ? "✅" : 
                          categoryPercentage > 0 ? "🔄" : "❌";
        
        print("$statusIcon $category: $categoryImplemented/$categoryTotal ($categoryPercentage%)");
      }
      print("════════════════════════════════════════════════\n");

      // Generate individual test cases
      for (final testCase in chordTestCases) {
        if (testCase.status == TestStatus.implemented) {
          test("✅ should detect ${testCase.name}", () {
            final result = ChordDetectionService.detectChord(testCase.midiNotes);
            
            expect(result, isNotNull, 
                reason: "${testCase.name} should be detected");
            expect(result!.chordName, equals(testCase.expectedChordName),
                reason: "Expected chord name for ${testCase.name}");
            expect(result.rootNote, equals(testCase.expectedRootNote),
                reason: "Expected root note for ${testCase.name}");
            expect(result.confidence, closeTo(testCase.expectedConfidence, 0.05),
                reason: "Expected confidence for ${testCase.name}");
          });
        } else if (testCase.status == TestStatus.partial) {
          test("🔄 PARTIAL: ${testCase.name}", () {
            final result = ChordDetectionService.detectChord(testCase.midiNotes);
            expect(result, isNotNull, 
                reason: "${testCase.name} should be partially detected");
            // Add partial validation logic here
          });
        } else {
          test("❌ TODO: ${testCase.name}", () {
            // Placeholder for future implementation
            print('   📝 ${testCase.description ?? 'Implementation needed'}');
          }, skip: "Not yet implemented - ${testCase.category}");
        }
      }
    });

    // ================== EDGE CASE TESTS ==================
    group("Edge Cases", () {
      test("should handle octave-wrapped notes correctly", () {
        // C Major in different octaves: C4 (60), E5 (76), G3 (55)
        final result = ChordDetectionService.detectChord({60, 76, 55});
        expect(result, isNotNull);
        expect(result!.chordName, contains("Major"));
        expect(result.confidence, greaterThan(0.5));
      });

      test("should handle complex extended chords", () {
        // Extended chord with 5 notes
        final result = ChordDetectionService.detectChord({60, 64, 67, 70, 74});
        expect(result, isNotNull);
        expect(result!.confidence, greaterThan(0.0));
      });

      test("should prefer extended chords over simple triads", () {
        // Ensure 7th chord has higher confidence than triad
        final triad = ChordDetectionService.detectChord({60, 64, 67});
        final seventh = ChordDetectionService.detectChord({60, 64, 67, 70});

        expect(triad!.confidence, equals(0.85));
        expect(seventh!.confidence, equals(0.95));
        expect(seventh.confidence, greaterThan(triad.confidence));
      });
    });
  });

  group("ChordDetectionResult", () {
    test("should convert to string correctly", () {
      const result = ChordDetectionResult(
        chordName: "C Major",
        rootNote: "C",
        notes: ["C", "E", "G"],
        confidence: 0.9,
      );

      expect(result.toString(), equals("C Major"));
    });
  });
}