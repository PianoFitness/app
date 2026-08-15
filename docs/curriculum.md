# PianoFitness Curriculum: Exercise Families in Suggested Order

This document is the ordered inventory of piano exercise families — what to teach and in what
order. For the teaching philosophy behind that ordering (non-gating exploration, priority and
exercise-type labels, category-versus-variation), see [`pedagogy.md`](pedagogy.md).

Every family below is freely explorable regardless of its priority label — see
[`pedagogy.md`](pedagogy.md) §1 and §3.

## Exercise-system fit

The Curriculum tree contains only **closed, MIDI-assessable exercises**. A
playable exercise must resolve to an ordered sequence of one or more exact MIDI
pitch sets: a scale note, a broken-chord note, or a complete blocked chord. The
runner advances only when the expected set is held, then records pitch accuracy
and, when enough consistent MIDI onsets are available, performed exercise tempo.
It can show fingering and hand assignments as guidance, but ordinary MIDI input
cannot verify either one. A step's note value describes its intended rhythmic
distance and supports tempo reporting; it does not make the runner enforce a
metronome beat.

This gives the following status labels their precise meaning:

- **Available now** — the family can be expressed by an existing
  `ExerciseConfiguration` and strategy.
- **Planned generator** — the musical goal is a good closed exercise, but it
  needs a deterministic scale, chord, progression, or pattern generator before
  it can become a playable tree node.
- **Outside the current exercise system** — the goal depends on free note
  choice, backing playback, listening or analysis, subjective musical
  judgement, or recording. It belongs in a future feature rather than this
  MIDI exercise tree.

The current strategies already cover major/natural-minor/modal scales; the
available triad and seventh-chord qualities; straight and rolling arpeggios and
block chords; a small library of fixed triad progressions; and V–I cadences.
They do **not** yet generate harmonic or melodic minor, pentatonic or blues
scales, suspended chords, extensions/alterations, accompaniment patterns, or
the advanced harmonic progressions below. Those are retained as **planned
generator** families, not promises that an existing configuration can play
them.

Do not turn hand, octave range, inversion rotation, key, or tempo into separate
tree nodes. They are exercise variations or checkpoints of one measurable
skill. Likewise, a phrase may be taught as a fixed pattern, but the learner's
own improvisation is not scored by this system.

## Family index

### Part I: Start Here (Foundation)

1. Major and minor scales
2. Major and minor arpeggios
3. Foundational triads
4. Foundational chord progressions
5. Cadences

### Part II: Core Technique and Coordination

6. Suspended chords
7. Augmented and diminished triads
8. Broken-chord accompaniment patterns
9. Alberti bass
10. Ostinatos

### Part III: Harmony and Accompaniment

11. Seventh chords
12. Chord extensions
13. Altered dominant chords
14. Minor ii–V–i
15. General voice-leading exercises
16. Secondary dominants and tonicization
17. Tritone substitution
18. Modal interchange and borrowed chords
19. Applied diminished-seventh harmony

### Part IV: Scale Vocabulary and Transfer

20. Modes
21. Pentatonic and blues scales
22. Pentatonic and blues patterns
23. Transposition through keys

### Part V: Jazz, Chromatic, and Contemporary Harmony

24. Neapolitan sixth chord
25. Augmented-sixth chords
26. Common-tone augmented-sixth chords
27. Chromatic mediants
28. Neo-Riemannian transformations
29. Upper-structure triads
30. Drop-2 voicings
31. Drop-3 voicings
32. Quartal harmony
33. Quintal harmony

Plus an appendix of topics awaiting theoretical review, at the end of this document.

---

# Part I: Start Here

## 1. Major and minor scales

**Priority:** Foundation · **Type:** Technique exercise

**Connections:** leads into arpeggios (§2), diatonic harmony (§3–§4), and modes (§20).

### Core exercises

- Major scale, hands separately
- Major scale, hands together
- Natural minor scale
- Harmonic minor scale with raised seventh
- Melodic minor scale: raised sixth and seventh ascending, reverting to the natural minor form descending (classical convention)

### Suggested development

- Learn each hand independently
- Combine the hands
- Play ascending and descending
- Extend the range
- Increase tempo while maintaining accuracy and consistency
- Relate major keys to their relative minor keys
- Hear scales in their associated harmonic contexts

---

## 2. Major and minor arpeggios

**Priority:** Foundation · **Type:** Technique exercise

**Connections:** builds on scales (§1); leads into broken-chord accompaniment (§8) and upper-structure triad arpeggiation (§29).

### Core exercises

- Simple ascending broken chord: root–third–fifth–octave
- Major arpeggios, hands separately
- Major arpeggios, hands together
- Minor arpeggios, hands separately
- Minor arpeggios, hands together
- Two-octave arpeggios ascending and descending

### Suggested development

- Root position and inversions
- Extend the range across multiple octaves
- Increase tempo while maintaining accuracy and consistency
- Dominant- and diminished-seventh arpeggios once triad arpeggios are secure

---

## 3. Foundational triads

**Priority:** Foundation · **Type:** Technique exercise

**Connections:** builds on scales (§1); leads into seventh chords (§11), cadences (§5), and voice leading (§15).

### Core exercises

- I–IV–V triads in root position
- All seven diatonic triads in a major key
- Major triads
- Minor triads
- Diminished triads
- Augmented triads
- Triad inversions: root, first, and second inversion

### Development

- Play each chord type in every key
- Cycle through all inversions
- Compare chord qualities by ear
- Resolve unstable triads into stable chords
- Connect triads with minimal hand movement
- Recognize their functions within a key

---

## 4. Foundational chord progressions

**Priority:** Foundation · **Type:** Technique exercise

**Connections:** builds on triads (§3) and cadences (§5); leads into secondary dominants (§16) and voice-leading exercises (§15).

### Core progressions

- I–IV–V–I
- I–vi–IV–V
- ii–V–I
- ii7–V7–Imaj7
- Minor iiø7–V7–im7

### Suggested development

- Root-position chords
- Inversions
- Whole-note chord changes
- Reduced transition time
- Smooth common-tone voice leading
- Left-hand roots with right-hand chords
- Rootless voicings
- Guide-tone-only versions
- Practice through all inversions

---

## 5. Cadences

**Priority:** Foundation · **Type:** Technique exercise

**Connections:** builds on triads (§3) and progressions (§4); leads into minor ii–V–i (§14) and modal interchange (§18).

### Authentic cadence

- V → I
- V7 → I
- Keep common tones
- Resolve scale degree 7 upward to 1
- Resolve the chordal seventh downward
- Practise until the resolution becomes reflexive

### Plagal cadence

- IV → I
- Keep common tones
- Move scale degree 6 smoothly to 5
- Compare its softer resolution with V–I

### Half cadence

- Any chord → V (commonly I → V, IV → V, or ii → V)
- Recognize its open, unresolved quality
- Compare with a full authentic cadence's sense of arrival

### Deceptive cadence

- V → vi
- V7 → vi
- Compare its surprise resolution with V → I

### Extended cadence exercises

- V–I with smooth voice leading
- IV–I with smooth voice leading
- Cadences in root position and inversions
- Cadences using seventh chords
- Cadences in both major and minor keys
- Cadences embedded in larger progressions
- Perfect versus imperfect authentic cadence (soprano voice on scale degree 1 versus not) as a later refinement once authentic, plagal, half, and deceptive cadences are secure

---

# Part II: Core Technique and Coordination

## 6. Suspended chords

**Priority:** Developing · **Type:** Technique exercise · **Status:** Available now

**Connections:** builds on triads (§3); related to dominant harmony in altered dominants (§13) and cadences (§5).

### Core exercises

- Sus4 chords: 1–4–5
- Sus2 chords: 1–2–5
- Sus4 to major resolution: 4→3
- Sus2 to major resolution: 2→3
- Dominant sus4 chords
- V7sus4 → V7 → I
- I → Isus4 → I
- ii7 → V7sus4 → V7 → I

### Learning goals

- Hear tension and release
- Distinguish unresolved suspension from resolved harmony
- Practise the movement of one suspended voice
- Delay dominant resolution for expressive effect

---

## 7. Augmented and diminished triads

**Priority:** Developing · **Type:** Technique exercise · **Status:** Available now

**Connections:** builds on triads (§3); leads into applied diminished-seventh harmony (§19) and chromatic mediants (§27).

### Augmented exercises

- Build augmented triads: 1–3–#5
- Play augmented inversions
- Explore the symmetry of augmented triads
- Map the four unique augmented-triad pitch collections
- I → I+ → vi
- I → I+ → first-inversion tonic
- I+ → IV
- I+ → V
- Use augmented chords as chromatic passing harmony

### Diminished exercises

- Build diminished triads: 1–♭3–♭5
- Play diminished inversions
- vii° → I
- Resolve leading-tone diminished chords in every key
- I → #I° → ii
- iii → #iii° → IV
- Use diminished chords between diatonic chords
- Practise half-step voice leading into the destination chord

---

## 8. Broken-chord accompaniment patterns

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on arpeggios (§2); combines with Alberti bass (§9) and ostinatos (§10) as accompaniment textures.

### Foundational exercises

- Two-octave broken chord ascending and descending
- Arpeggio patterns through chord progressions
- Repeating broken-chord accompaniment

### Development

- Transpose patterns through every key
- Apply patterns to major and minor harmony
- Use different inversions
- Extend the range
- Maintain consistent pulse
- Combine the pattern with a prescribed right-hand melody

---

## 9. Alberti bass

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** a variation on broken-chord accompaniment (§8).

### Core pattern

- Low–high–middle–high or equivalent chord-tone order

### Development

- Apply to major and minor triads
- Move through progressions
- Maintain even rhythm
- Change inversions smoothly
- Combine with a prescribed right-hand melody
- Increase tempo without tension

---

## 10. Ostinatos

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on broken-chord accompaniment (§8); prepares prescribed two-hand patterns (§22).

### Exercises

- Turn one progression into a repeating left-hand bed
- Build pentatonic ostinatos
- Build broken-chord ostinatos
- Build quartal or quintal ostinatos
- Create chromatic-mediant ostinatos
- Create minor ii–V–i ostinatos
- Maintain the ostinato while playing a prescribed right-hand line

### Learning goals

- Hand independence
- Groove
- Repetition without stiffness
- Dynamic control
- Layering melody over accompaniment

---

# Part III: Harmony and Accompaniment

## 11. Seventh chords

**Priority:** Developing · **Type:** Technique exercise · **Status:** Available now

**Connections:** builds on triads (§3); leads into chord extensions (§12) and drop voicings (§30–§31).

### Core chord types

- Dominant seventh
- Major seventh
- Minor seventh
- Half-diminished seventh or minor-seven-flat-five

### Suggested exercises

- Build each chord from scale-degree formulas
- Play all inversions
- Compare their harmonic functions
- Resolve dominant seventh chords
- Use minor seventh chords as ii, iii, and vi
- Use half-diminished seventh chords in minor ii–V–i
- Connect seventh chords through smooth voice leading

---

## 12. Chord extensions

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on seventh chords (§11); leads into altered dominants (§13) and upper-structure triads (§29).

### Ninth chords

- Major ninth: 1–3–5–7–9
- Minor ninth: 1–♭3–5–♭7–9
- Dominant ninth: 1–3–5–♭7–9

### Eleventh chords

- Dominant eleventh
- Dominant-eleventh voicings without the third
- Suspended dominant-eleventh colours

### Thirteenth chords

- Major thirteenth
- Dominant thirteenth
- Selective voicing of essential tones
- Root–third–seventh–ninth–thirteenth combinations

### Learning goals

- Hear the difference between basic seventh chords and extensions
- Learn which notes may be omitted
- Avoid muddy or conflicting voicings
- Use extensions in jazz, neo-soul, R&B, and contemporary harmony

---

## 13. Altered dominant chords

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on chord extensions (§12); connects to tritone substitution (§17) and upper-structure triads (§29).

### Core alterations

- Dominant ♭9
- Dominant #9
- Dominant #11
- Dominant ♭13
- Fully altered dominant
- Diminished-dominant combinations

### Applications

- Use altered dominants before major or minor resolutions
- Combine ♭9 and ♭13 for darker dominant colour
- Use #9 for blues and rock colour
- Use #11 for Lydian-dominant or tritone-substitution colour
- Select rather than stack every available alteration
- Compare increasing levels of dominant tension

---

## 14. Minor ii–V–i

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on seventh chords (§11) and cadences (§5); leads into tritone substitution (§17) and drop voicings (§30–§31).

### Core exercises

- iiø7–V7–im7
- Smooth guide-tone voice leading
- Third-and-seventh-only exercise
- Altered V7 with ♭9 and ♭13
- Rootless right-hand voicings
- All inversions
- Drop-2 voicings
- Spread voicings
- Left-hand shell voicings
- Quartal voicings
- Minor ii–V–i ostinato

### Reharmonized versions

- iiø7–♭II7–im7
- Double tritone substitution
- Chromatic bass-line versions

---

## 15. General voice-leading exercises

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** applies across progressions (§4), cadences (§5), and minor ii–V–i (§14).

### Core principles

- Keep common tones stationary
- Move remaining voices by step where possible
- Prefer half-step resolutions when harmonically appropriate
- Minimize unnecessary hand movement
- Practise guide tones independently
- Create clear soprano and bass lines
- Explore contrary motion between outer voices

### Key exercises

- Smooth I–IV–V–I
- Smooth ii–V–I
- Smooth minor ii–V–i
- Chord progressions through inversions
- Chromatic passing chords
- Suspensions resolving by step
- Diminished chords resolving inward or outward
- Borrowed chords with chromatic inner lines

---

## 16. Secondary dominants and tonicization

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on progressions (§4); leads into tritone substitution (§17).

### Individual secondary dominants

- V7/V → V
- V7/ii → ii
- V7/iii → iii
- V7/IV → IV
- V7/vi → vi

### Progression exercises

- Chain of secondary dominants
- V7/vi → vi → V7/V → V → I
- I → V7/IV → IV → V7 → I
- Secondary dominants inserted into familiar progressions
- Chromatic leading-tone resolution into each target chord

---

## 17. Tritone substitution

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on secondary dominants (§16) and minor ii–V–i (§14); connects to upper-structure triads (§29).

### Core exercises

- Replace V7 with ♭II7
- ii–♭II7–I
- Preserve the dominant guide tones
- Practise descending chromatic bass motion
- Double tritone substitution
- Tritone substitutions in turnarounds
- Practise a prescribed turnaround containing a tritone substitution

### Combined applications

- Tritone substitutions in major ii–V–I
- Tritone substitutions in minor ii–V–i
- Tritone substitution with upper-structure triads
- Tritone substitution as reharmonization

---

## 18. Modal interchange and borrowed chords

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on cadences (§5) and triads (§3); connects to chromatic mediants (§27).

### Borrowing into major

- Minor iv
- ♭VI major
- ♭VII major
- ♭II or Neapolitan colour

### Borrowing into minor

- Major tonic or Picardy third
- Major IV

### Progression exercises

- I–iv–I
- I–♭VI–IV–I
- I–♭VII–IV–I
- I–♭II–V–I
- i–iv–V–I (Picardy third)
- i–IV–V7–i
- Progressions using several borrowed chords
- Smooth chromatic voice leading between borrowed and diatonic harmony

---

## 19. Applied diminished-seventh harmony

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on diminished triads (§7); connects to modal interchange (§18).

### Leading-tone diminished chords

- vii°7/ii → ii
- vii°7/iii → iii
- vii°7/IV → IV
- vii°7/V → V
- vii°7/vi → vi

### Additional exercises

- Passing diminished chords
- Symmetrical diminished-seventh inversions
- Map the three unique diminished-seventh pitch collections
- Resolve every voice by half-step
- Use diminished harmony to connect diatonic chords

---

# Part IV: Scale Vocabulary and Transfer

## 20. Modes

**Priority:** Developing · **Type:** Technique exercise · **Status:** Available now

**Connections:** builds on scales (§1); supports fixed scale-pattern work (§22) and quartal harmony's modal voicings (§32).

### Core modes

- Ionian: major-scale sound
- Dorian: minor with natural sixth
- Phrygian: minor with flattened second
- Lydian: major with raised fourth
- Mixolydian: major with flattened seventh
- Aeolian: natural minor
- Locrian: minor with flattened second and fifth

### Context labels

- Dorian for minor, funk, soul, and modal-jazz harmony
- Mixolydian over dominant-seventh chords and blues
- Lydian for bright, floating, or cinematic harmony
- Phrygian for darker or Spanish-influenced sounds
- Aeolian for conventional minor-key melody
- Locrian over half-diminished harmony
- Ionian as the modal understanding of the major scale

---

## 21. Pentatonic and blues scales

**Priority:** Foundation · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on scales (§1); leads into pentatonic and blues patterns (§22).

### Foundational scales

- Major pentatonic: 1–2–3–5–6
- Minor pentatonic: 1–♭3–4–5–♭7
- Blues scale: 1–♭3–4–♭5–5–♭7

An added ninth is the same pitch class as scale degree 2; use “9th” only when
the octave/register of that note is musically relevant.

### Conceptual relationships

- Relative major and minor pentatonic scales
- Switching tonal centre while using the same pitch collection
- Combining major and minor pentatonic sounds
- Matching pentatonic scales to individual chords
- Targeting chord tones on strong beats

---

## 22. Pentatonic and blues patterns

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on pentatonic scales (§21) and modes (§20); supports transposition through keys (§23).

### Fixed-pattern exercises

- Ascending and descending pentatonic patterns
- Skip patterns, then patterns in thirds and fourths
- Groups of three, four, and five notes
- Repeated melodic sequences
- Blues patterns that resolve ♭5 to 5
- Chromatic approach notes into a prescribed chord tone
- A fixed left-hand ostinato with a prescribed right-hand pentatonic line

### Generator requirements

- Each exercise must specify every target pitch and its note value.
- A two-hand variation must specify both hands’ notes at each onset; it may not
  leave the melody or accompaniment open for learner choice.
- Phrase shape, swing feel, call-and-response quality, and freely chosen notes
  remain outside the current scoring model.

---

## 23. Transposition through keys

**Priority:** Developing · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** applies across all prior families; reinforces key fluency alongside scales (§1) and progressions (§4).

- Practise one prescribed pentatonic or blues pattern in three new keys
- Practise a prescribed chord progression in the next circle-of-fifths key
- Practise one prescribed voicing pattern in every supported key
- Use the same fixed accompaniment pattern over its configured harmonic roots

The curriculum treats this as repeated performance of equivalent generated
exercises in different keys, not as assessment of a learner-created lick.

---

# Part V: Jazz, Chromatic, and Contemporary Harmony

## 24. Neapolitan sixth chord

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on modal interchange (§18); related to augmented-sixth chords (§25).

### Construction

- Build ♭II in first inversion
- Double the bass or chordal third
- Compare first inversion with root position

### Core progressions

- N6 → V → i
- N6 → V → I
- i → N6 → V → i
- N6 → I6/4 → V → i
- N6 → vii°7/V → V → i
- N6 → V → vi
- Root-position ♭II → V → i

### Voice-leading exercises

- ♭2 resolving downward
- Bass and inner-voice motion into V
- Avoid parallel fifths
- Maintain smooth four-part movement
- Use the Neapolitan for modulation or enharmonic reinterpretation

---

## 25. Augmented-sixth chords

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on the Neapolitan sixth (§24); leads into common-tone augmented-sixth chords (§26).

### Foundational interval

- Build the augmented sixth between ♭6 and #4
- Resolve both notes outward by half-step to scale degree 5

### Italian augmented sixth

- Construct It+6
- Resolve It+6 → V

### German augmented sixth

- Construct Ger+6
- Resolve through cadential I6/4 where needed
- Ger+6 → I6/4 → V → i

### French augmented sixth

- Construct Fr+6
- Resolve directly to V
- Compare its colour with Italian and German forms

### Further exercises

- Use augmented-sixth chords in major keys
- Compare Italian, German, and French forms
- Substitute augmented-sixth harmony for iv
- Enharmonically reinterpret German sixth as a dominant seventh
- Connect augmented-sixth harmony with jazz altered dominants
- Practise complete chromatic pre-dominant progressions

---

## 26. Common-tone augmented-sixth chords

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on augmented-sixth chords (§25).

### Core forms

- Common-tone Italian augmented sixth
- Common-tone German augmented sixth
- Common-tone French augmented sixth

### Applications

- Resolve directly to tonic
- Keep the common tone stationary
- Insert between diatonic chords
- Use before tonic in major and minor
- Compare standard augmented-sixth-to-dominant motion with common-tone-to-tonic motion
- Apply common-tone augmented sixths as reharmonization devices
- Explore enharmonic reinterpretations

---

## 27. Chromatic mediants

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on modal interchange (§18) and augmented/diminished triads (§7); connects to Neo-Riemannian transformations (§28).

### Foundational relationships

- I → ♭VI
- I → III (major)
- i → ♭VI
- I → chromatic minor-mediant relationships

### Key exercises

- Move between parallel major triads a third apart
- Preserve common tones
- Hold a common tone in the melody
- Chain descending-third relationships
- I → ♭VI → ♭III → I
- I → ♭VI → ♭III → ♭VII → I
- Combine chromatic mediants with tritone-related harmony
- Practise an alternating I/♭VI ostinato as a fixed pattern
- Play a prescribed melodic line over repeated chromatic-mediant shifts
- Catalogue available mediant relationships from one tonic

### Musical goals

- Develop cinematic harmonic colour
- Hear non-functional but connected triadic motion
- Create emotional pivots using shared tones
- Use shared tones in a prescribed melodic line

---

## 28. Neo-Riemannian transformations

**Priority:** Exploratory · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on chromatic mediants (§27); see the appendix at the end of this document for unverified extensions to this family.

### Core transformations

- Parallel transformation: major ↔ parallel minor
- Relative transformation: major ↔ relative minor
- Leading-tone exchange
- Strict common-tone voice leading

### Development exercises

- Practise P, L, and R in all keys
- Combine transformations into chains
- Alternate transformations to create cycles
- Explore hexatonic cycles
- Explore octatonic relationships
- Derive chromatic-mediant relationships through compound transformations
- Reverse transformation chains
- Play a prescribed P/L/R chain within a tonal progression

---

## 29. Upper-structure triads

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on chord extensions (§12) and altered dominants (§13); connects to tritone substitution (§17).

### Foundational concept

Play a simple right-hand triad over a dominant-chord shell or bass to create upper extensions.

### Principal upper structures over V7

- v minor triad: natural dominant ninth colour
- II major triad: 9, #11, and 13
- ♭II major triad: ♭9 and ♭13 colour
- ♭VI major triad: altered ♯9 and ♭13 colour
- ♭VII major triad: sus or dominant-eleventh colour
- iii minor triad: basic dominant quality
- vi minor triad: natural upper extensions
- ii minor triad: 9, 11, and 13
- Diminished upper structures
- Additional major and minor triads for ambiguous colours

### Applications

- Compare several upper structures over one dominant
- Apply them to major ii–V–I
- Apply altered structures to minor ii–V–i
- Move upper structures with smooth voice leading
- Combine left-hand guide-tone shells with right-hand triads
- Use upper structures in prescribed rhythmic chord steps
- Arpeggiate an upper structure as a fixed pattern
- Play a prescribed melody target above an upper structure
- Combine upper structures with tritone substitutions
- Use upper structures in extended dominant chains
- Use them over a fixed modal-dominant progression

---

## 30. Drop-2 voicings

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on seventh chords (§11) and minor ii–V–i (§14); compare with drop-3 voicings (§31).

### Foundational exercises

- Understand dropping the second voice from the top
- Major seventh drop-2
- Dominant seventh drop-2
- Minor seventh drop-2
- Half-diminished seventh drop-2
- All four inversions

### Progression exercises

- Major ii–V–I in drop-2
- Minor ii–V–i in drop-2
- Chromatic parallel motion
- Contrary motion
- Prescribed melody note above drop-2 targets
- Prescribed bass-and-drop-2 targets
- Rootless drop-2 voicings
- Drop-2 with extensions
- Chromatic approaches into target voicings

---

## 31. Drop-3 voicings

**Priority:** Advanced · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on drop-2 voicings (§30).

### Foundational exercises

- Understand dropping the third voice from the top
- Major seventh drop-3
- Dominant seventh drop-3
- Minor seventh drop-3
- Half-diminished seventh drop-3
- All four inversions

### Applications

- Major ii–V–I in drop-3
- Minor ii–V–i in drop-3
- Compare drop-2 and drop-3 spacing
- Mix drop-2 and drop-3 in one progression
- Play prescribed melody notes above drop-3 targets
- Rootless drop-3 voicings
- Drop-3 voicings with extensions
- Chromatic approach voicings
- Practise drop voicings through all keys

---

## 32. Quartal harmony

**Priority:** Exploratory · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on modes (§20); compare with quintal harmony (§33).

### Construction exercises

- Three-note quartal voicings
- Four-note quartal voicings
- Five-note quartal voicings
- Quartal inversions
- Close quartal clusters
- Spread quartal voicings

### Scale and modal applications

- Quartal voicings derived from major scales
- Dorian quartal voicings
- Lydian quartal voicings
- Mixolydian quartal voicings
- Phrygian quartal voicings
- Chromatic perfect-fourth voicings

### Movement and progression exercises

- Parallel quartal motion
- Chromatic planing
- Quartal voicings over specific bass notes
- Quartal ii–V–I
- Quartal voicings over a fixed modal bass pattern
- Smooth quartal voice leading
- Quartal tension resolving to tertian harmony

### Fixed-pattern applications

- Prescribed left-hand quartal chord patterns
- Quartal ostinatos
- Prescribed melodic patterns using one quartal voicing
- "So What"-style voicings
- Quartal upper structures over conventional chord roots

---

## 33. Quintal harmony

**Priority:** Exploratory · **Type:** Technique exercise · **Status:** Planned generator

**Connections:** builds on quartal harmony (§32).

### Core exercises

- Three-note quintal voicings
- Four-note quintal voicings
- Quintal voicings derived from a major scale
- Parallel quintal motion
- Quintal voicings over a bass note
- Quintal inversions

### Combined quartal/quintal work

- Hybrid fourth-and-fifth voicings
- Quartal/quintal ostinatos
- Convert quartal forms into quintal inversions
- Practise a fixed quartal/quintal pattern in several keys
- Resolve a prescribed quartal or quintal target into a tertian target

---

# Appendix: Topics requiring pedagogical or theoretical review

The following entries from the source material are exploratory, self-correcting, or not yet
independently verified, and are quarantined here rather than presented as settled teaching
material — see [`pedagogy.md`](pedagogy.md) §5. They relate most closely to Neo-Riemannian
transformations (§28) and would be reviewed before promotion into that family.

- Slide transformations
- Nebenverwandt transformations
- Transformation algebra and symmetry
- Analysis of Romantic and film-score progressions
