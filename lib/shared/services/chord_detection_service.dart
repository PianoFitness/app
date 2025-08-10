/// Service for detecting chords from MIDI notes using comprehensive chord rules.
///
/// Implements a complete chord detection system covering:
/// - Core triads & power chords
/// - Add & 6 chords (no 7th)
/// - Seventh chords
/// - Extensions (with 7th implied)
/// - Altered dominants
/// - Detection rules and precedence
class ChordDetectionService {
  // MIDI note to note name mapping
  static const _noteNames = [
    "C",
    "C♯",
    "D",
    "D♯",
    "E",
    "F",
    "F♯",
    "G",
    "G♯",
    "A",
    "A♯",
    "B",
  ];

  /// Chord type definitions with required and optional intervals
  /// Ordered by detection precedence - higher priority types are checked first
  static const _chordTypes = [
    // Sus chords with 7th (highest priority for sus chords)
    ChordType("7sus4", {5, 7, 10}, {2}, 0.9),
    ChordType("7sus2", {2, 7, 10}, {}, 0.88),
    
    // Add & 6 chords (no 7th) - check most specific first
    ChordType("6/9", {4, 7, 9, 2}, {5}, 0.95), // Increased confidence to match regular 6
    ChordType("m6/9", {3, 7, 9, 2}, {5}, 0.94), // Increased confidence to match regular m6
    ChordType("6", {4, 7, 9}, {}, 0.93), // Reduced confidence so 6/9 takes precedence
    ChordType("m6", {3, 7, 9}, {}, 0.92),
    ChordType("add9", {4, 7, 2}, {}, 0.88),
    ChordType("madd9", {3, 7, 2}, {}, 0.88),
    ChordType("add11", {4, 7, 5}, {}, 0.86),
    
    // Altered dominants - check before regular 7ths
    ChordType("7♭5", {4, 6, 10}, {2, 5, 9}, 0.9),
    ChordType("7♯5", {4, 8, 10}, {2, 5}, 0.9),
    ChordType("7♭9", {4, 7, 10, 1}, {5, 9}, 0.9),
    ChordType("7♯9", {4, 7, 10, 3}, {5, 9}, 0.9),
    ChordType("7♯11", {4, 7, 10, 6}, {2, 9}, 0.9),
    ChordType("7♭13", {4, 10, 8}, {7, 2}, 0.9),
    ChordType("7(♭9,♭13)", {4, 10, 1, 8}, {7}, 0.88),
    ChordType("7(♭9,♯11)", {4, 10, 1, 6}, {7}, 0.88),
    ChordType("7(♯9,♭13)", {4, 10, 3, 8}, {7}, 0.88),
    
    // Special 7ths
    ChordType("dim7", {3, 6, 9}, {}, 0.92),
    ChordType("m7♭5", {3, 6, 10}, {2, 5, 9}, 0.9),
    
    // Extensions (with 7th implied)
    ChordType("maj13♯11", {4, 11, 6, 9}, {2, 5, 7}, 0.97), // Major 13♯11 - highest precedence
    ChordType("maj13", {4, 7, 11, 9}, {2, 5}, 0.96),
    ChordType("m13", {3, 7, 10, 9}, {2, 5}, 0.96),
    ChordType("13", {4, 7, 10, 9}, {2, 5}, 0.96),
    ChordType("maj7♯11", {4, 7, 11, 6}, {2}, 0.93),
    ChordType("maj11", {4, 7, 11, 2, 5}, {9}, 0.95), // Major 11th - more specific than maj9
    ChordType("m11", {3, 7, 10, 5}, {2, 9}, 0.94),
    ChordType("11", {5, 7, 10, 2}, {}, 0.94), // 9sus4 equivalent
    ChordType("maj9", {4, 7, 11, 2}, {5}, 0.96),
    ChordType("m9", {3, 7, 10, 2}, {5}, 0.96),
    ChordType("9", {4, 7, 10, 2}, {5}, 0.96),
    
    // Regular sevenths
    ChordType("mMaj7", {3, 7, 11}, {2, 5, 9}, 0.95),
    ChordType("maj7", {4, 7, 11}, {2, 5, 9}, 0.95),
    ChordType("m7", {3, 7, 10}, {2, 5, 9}, 0.95),
    ChordType("7", {4, 7, 10}, {2, 5, 9}, 0.95),
    
    // Sus chords without 7th (check after add chords to avoid conflicts)
    ChordType("sus24", {2, 5, 7}, {}, 0.75), // Both 2nd and 4th
    ChordType("sus4", {5, 7}, {}, 0.7),
    ChordType("sus2", {2, 7}, {}, 0.7),
    
    // Core triads (checked last)
    ChordType("Aug", {4, 8}, {}, 0.8),
    ChordType("Dim", {3, 6}, {}, 0.8),
    ChordType("Minor", {3, 7}, {}, 0.85),
    ChordType("Major", {4, 7}, {}, 0.85),
    
    // Power chord (lowest precedence for 2-note detection)
    ChordType("5", {7}, {}, 0.8),
  ];

  /// Attempts to detect a chord from the given MIDI note numbers.
  ///
  /// Returns a [ChordDetectionResult] containing the detected chord name
  /// and additional information, or null if no clear chord is detected.
  static ChordDetectionResult? detectChord(Set<int> midiNotes) {
    if (midiNotes.isEmpty) return null;
    
    // Handle power chords (2 notes)
    if (midiNotes.length == 2) {
      return _detectPowerChord(midiNotes);
    }

    if (midiNotes.length < 2) {
      return null;
    }

    // Convert to pitch classes and find bass note
    final pitchClasses = midiNotes.map((midi) => midi % 12).toSet();
    final bassNote = midiNotes.reduce((a, b) => a < b ? a : b) % 12;
    
    // Try each pitch class as root with precedence rules
    return _findBestChordMatch(pitchClasses, bassNote);
  }

  /// Finds the best chord match using precedence rules and root position preference.
  static ChordDetectionResult? _findBestChordMatch(
    Set<int> pitchClasses,
    int bassNote,
  ) {
    ChordDetectionResult? bestResult;
    double bestScore = 0.0;

    // First try bass note as root with strong preference
    final bassResult = _analyzeChordWithRoot(pitchClasses, bassNote, bassNote);
    if (bassResult != null && bassResult.confidence > 0.5) {
      bestResult = bassResult;
      bestScore = bassResult.confidence * 1.1; // Moderate bias for root position
    }

    // Only consider other roots if bass note match is poor (< 0.5 confidence)
    if (bestScore < 0.6) {
      for (final root in pitchClasses) {
        if (root == bassNote) continue; // Already tried
        
        final result = _analyzeChordWithRoot(pitchClasses, root, bassNote);
        if (result != null) {
          final score = result.confidence;
          
          // Only accept inversions if they're much better than root position attempt
          if (score > bestScore * 1.5) {
            bestResult = result;
            bestScore = score;
          }
        }
      }
    }

    return bestResult;
  }

  /// Analyzes pitch classes with a specific root note using chord type matching.
  static ChordDetectionResult? _analyzeChordWithRoot(
    Set<int> pitchClasses,
    int root,
    int bassNote,
  ) {
    // Calculate intervals from root
    final intervals = <int>{};
    for (final pc in pitchClasses) {
      if (pc != root) {
        final interval = (pc - root) % 12;
        if (interval != 0) intervals.add(interval);
      }
    }

    // Try to match chord types with precedence order
    ChordType? bestMatch;
    double bestFitScore = 0.0;
    
    for (final chordType in _chordTypes) {
      final fitScore = _calculateChordTypeFit(intervals, chordType);
      if (fitScore > 0.0) {
        // Calculate completeness score - prefer chords that use more of the available intervals
        final completeness = chordType.required.length / intervals.length.clamp(1, 10);
        final adjustedScore = fitScore * (1.0 + completeness * 0.1);
        
        
        if (adjustedScore > bestFitScore) {
          bestMatch = chordType;
          bestFitScore = adjustedScore;
        }
      }
    }

    if (bestMatch == null || bestFitScore < 0.5) return null;

    final rootNoteName = _noteNames[root];
    final noteNames = pitchClasses.map((pc) => _noteNames[pc]).toList();
    
    // Format chord name with proper spacing
    String formatChordName(String chordType) {
      if (chordType == "Major") return " Major";
      if (chordType == "Minor") return " Minor";
      if (chordType == "Dim") return " Dim";
      if (chordType == "Aug") return " Aug";
      if (chordType == "5") return "5";
      // Add spaces before chord qualities for readability
      return " $chordType";
    }
    
    // Add slash chord notation if not in root position
    final chordName = root == bassNote 
        ? "$rootNoteName${formatChordName(bestMatch.name)}"
        : "$rootNoteName${formatChordName(bestMatch.name)}/${_noteNames[bassNote]}";

    return ChordDetectionResult(
      chordName: chordName,
      rootNote: rootNoteName,
      notes: noteNames,
      confidence: (bestMatch.confidence * bestFitScore).clamp(0.0, 1.0),
    );
  }

  /// Calculates how well a set of intervals fits a chord type.
  /// Returns a score from 0.0 to 1.0 where 1.0 is a perfect match.
  static double _calculateChordTypeFit(Set<int> intervals, ChordType chordType) {
    // Check if all required intervals are present
    final missingRequired = chordType.required.difference(intervals);
    if (missingRequired.isNotEmpty) {
      
      // Special handling for missing 5th (allowed for most chord families)
      if (missingRequired.length == 1 && missingRequired.first == 7) {
        // Missing 5th is tolerated unless it's a power chord or sus chord
        if (chordType.name == "5" || chordType.name.contains("sus")) {
          return 0.0; // 5th is essential for power and sus chords
        }
        return _calculateFitScore(intervals, chordType) * 0.95;
      }
      return 0.0; // Missing other required intervals = no match
    }
    
    return _calculateFitScore(intervals, chordType);
  }
  
  /// Calculates the fit score for a chord type match.
  static double _calculateFitScore(Set<int> intervals, ChordType chordType) {
    final allExpected = {...chordType.required, ...chordType.optional};
    final unexpected = intervals.difference(allExpected);
    
    // Apply special rules for chord detection
    
    // Rule: Require no 7th for add/6 chords
    final has7th = intervals.contains(10) || intervals.contains(11);
    if ((chordType.name.contains("add") || chordType.name.contains("6")) && 
        !chordType.name.contains("7") && has7th) {
      return 0.0; // No 7th allowed for add/6 chords
    }
    
    // Rule: Require 7th for extensions (9/11/13) but NOT for add chords or 6/9 chords
    if ((chordType.name.contains("9") || chordType.name.contains("11") || chordType.name.contains("13")) &&
        !chordType.name.contains("add") && !chordType.name.contains("6") && !has7th) {
      return 0.0; // 7th required for extensions
    }
    
    // Rule: Require no 3rd for sus chords
    final has3rd = intervals.contains(3) || intervals.contains(4);
    if (chordType.name.contains("sus") && has3rd) {
      return 0.0; // No 3rd allowed for sus chords
    }
    
    // Rule: Prefer complete triad + 9 over m7 without 5th
    if (chordType.name.contains("9") && intervals.contains(2) && 
        (intervals.contains(3) || intervals.contains(4))) {
      // Bonus for complete 9th chord
      if (unexpected.isEmpty) return 1.0;
    }
    
    // Perfect match bonus
    if (unexpected.isEmpty && intervals.containsAll(chordType.required)) {
      return 1.0;
    }
    
    // Penalty for unexpected intervals
    final penaltyPerUnexpected = 0.15;
    final penalty = unexpected.length * penaltyPerUnexpected;
    
    return (1.0 - penalty).clamp(0.0, 1.0);
  }


  /// Detects power chords (root + 5th only).
  static ChordDetectionResult? _detectPowerChord(Set<int> midiNotes) {
    final pitchClasses = midiNotes.map((midi) => midi % 12).toSet();
    if (pitchClasses.length != 2) return null;

    final bassNote = midiNotes.reduce((a, b) => a < b ? a : b) % 12;
    final pitchList = pitchClasses.toList();

    // Try bass note as root first
    for (final root in [bassNote, ...pitchList.where((pc) => pc != bassNote)]) {
      if (!pitchClasses.contains(root)) continue;
      
      final other = pitchClasses.firstWhere((pc) => pc != root);
      final interval = (other - root) % 12;

      // Check for perfect 5th (7 semitones)
      if (interval == 7) {
        final rootNoteName = _noteNames[root];
        final noteNames = pitchClasses.map((pc) => _noteNames[pc]).toList();
        final confidence = root == bassNote ? 0.8 : 0.75;

        return ChordDetectionResult(
          chordName: "${rootNoteName}5",
          rootNote: rootNoteName,
          notes: noteNames,
          confidence: confidence,
        );
      }
    }

    return null;
  }
}

/// Represents a chord type with required and optional intervals.
class ChordType {
  const ChordType(this.name, this.required, this.optional, this.confidence);

  final String name;
  final Set<int> required;
  final Set<int> optional;
  final double confidence;
}

/// Result of chord detection containing chord information and confidence.
class ChordDetectionResult {
  const ChordDetectionResult({
    required this.chordName,
    required this.rootNote,
    required this.notes,
    required this.confidence,
  });

  /// The detected chord name (e.g., "C Major", "Am7").
  final String chordName;

  /// The root note of the chord.
  final String rootNote;

  /// List of all notes in the chord.
  final List<String> notes;

  /// Confidence score from 0.0 to 1.0.
  final double confidence;

  @override
  String toString() => chordName;
}
