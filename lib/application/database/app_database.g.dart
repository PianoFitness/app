// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfileTableTable extends UserProfileTable
    with TableInfo<$UserProfileTableTable, UserProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPracticeDateMeta = const VerificationMeta(
    'lastPracticeDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPracticeDate =
      GeneratedColumn<DateTime>(
        'last_practice_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    lastPracticeDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('last_practice_date')) {
      context.handle(
        _lastPracticeDateMeta,
        lastPracticeDate.isAcceptableOrUnknown(
          data['last_practice_date']!,
          _lastPracticeDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      lastPracticeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_practice_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }
}

class UserProfileTableData extends DataClass
    implements Insertable<UserProfileTableData> {
  /// Unique identifier (UUID) for the profile.
  final String id;

  /// Display name for the profile (1-30 characters).
  /// Typically the user's first name for privacy and simplicity.
  final String displayName;

  /// The last date when this profile practiced.
  /// Null if the profile has never practiced.
  final DateTime? lastPracticeDate;

  /// The timestamp when this profile was created.
  final DateTime createdAt;
  const UserProfileTableData({
    required this.id,
    required this.displayName,
    this.lastPracticeDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || lastPracticeDate != null) {
      map['last_practice_date'] = Variable<DateTime>(lastPracticeDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfileTableCompanion(
      id: Value(id),
      displayName: Value(displayName),
      lastPracticeDate: lastPracticeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPracticeDate),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileTableData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      lastPracticeDate: serializer.fromJson<DateTime?>(
        json['lastPracticeDate'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'lastPracticeDate': serializer.toJson<DateTime?>(lastPracticeDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileTableData copyWith({
    String? id,
    String? displayName,
    Value<DateTime?> lastPracticeDate = const Value.absent(),
    DateTime? createdAt,
  }) => UserProfileTableData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    lastPracticeDate: lastPracticeDate.present
        ? lastPracticeDate.value
        : this.lastPracticeDate,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfileTableData copyWithCompanion(UserProfileTableCompanion data) {
    return UserProfileTableData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      lastPracticeDate: data.lastPracticeDate.present
          ? data.lastPracticeDate.value
          : this.lastPracticeDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('lastPracticeDate: $lastPracticeDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, lastPracticeDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileTableData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.lastPracticeDate == this.lastPracticeDate &&
          other.createdAt == this.createdAt);
}

class UserProfileTableCompanion extends UpdateCompanion<UserProfileTableData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<DateTime?> lastPracticeDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.lastPracticeDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileTableCompanion.insert({
    required String id,
    required String displayName,
    this.lastPracticeDate = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<UserProfileTableData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<DateTime>? lastPracticeDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (lastPracticeDate != null) 'last_practice_date': lastPracticeDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileTableCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<DateTime?>? lastPracticeDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (lastPracticeDate.present) {
      map['last_practice_date'] = Variable<DateTime>(lastPracticeDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('lastPracticeDate: $lastPracticeDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseHistoryTableTable extends ExerciseHistoryTable
    with TableInfo<$ExerciseHistoryTableTable, ExerciseHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES user_profile_table(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _practiceModeMeta = const VerificationMeta(
    'practiceMode',
  );
  @override
  late final GeneratedColumn<String> practiceMode = GeneratedColumn<String>(
    'practice_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handSelectionMeta = const VerificationMeta(
    'handSelection',
  );
  @override
  late final GeneratedColumn<String> handSelection = GeneratedColumn<String>(
    'hand_selection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _musicalKeyMeta = const VerificationMeta(
    'musicalKey',
  );
  @override
  late final GeneratedColumn<String> musicalKey = GeneratedColumn<String>(
    'musical_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scaleTypeMeta = const VerificationMeta(
    'scaleType',
  );
  @override
  late final GeneratedColumn<String> scaleType = GeneratedColumn<String>(
    'scale_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chordTypeMeta = const VerificationMeta(
    'chordType',
  );
  @override
  late final GeneratedColumn<String> chordType = GeneratedColumn<String>(
    'chord_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _includeInversionsMeta = const VerificationMeta(
    'includeInversions',
  );
  @override
  late final GeneratedColumn<bool> includeInversions = GeneratedColumn<bool>(
    'include_inversions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_inversions" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeSeventhChordsMeta =
      const VerificationMeta('includeSeventhChords');
  @override
  late final GeneratedColumn<bool> includeSeventhChords = GeneratedColumn<bool>(
    'include_seventh_chords',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_seventh_chords" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _musicalNoteMeta = const VerificationMeta(
    'musicalNote',
  );
  @override
  late final GeneratedColumn<String> musicalNote = GeneratedColumn<String>(
    'musical_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arpeggioTypeMeta = const VerificationMeta(
    'arpeggioType',
  );
  @override
  late final GeneratedColumn<String> arpeggioType = GeneratedColumn<String>(
    'arpeggio_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arpeggioOctavesMeta = const VerificationMeta(
    'arpeggioOctaves',
  );
  @override
  late final GeneratedColumn<String> arpeggioOctaves = GeneratedColumn<String>(
    'arpeggio_octaves',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chordProgressionIdMeta =
      const VerificationMeta('chordProgressionId');
  @override
  late final GeneratedColumn<String> chordProgressionId =
      GeneratedColumn<String>(
        'chord_progression_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    completedAt,
    practiceMode,
    handSelection,
    musicalKey,
    scaleType,
    chordType,
    includeInversions,
    includeSeventhChords,
    musicalNote,
    arpeggioType,
    arpeggioOctaves,
    chordProgressionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('practice_mode')) {
      context.handle(
        _practiceModeMeta,
        practiceMode.isAcceptableOrUnknown(
          data['practice_mode']!,
          _practiceModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_practiceModeMeta);
    }
    if (data.containsKey('hand_selection')) {
      context.handle(
        _handSelectionMeta,
        handSelection.isAcceptableOrUnknown(
          data['hand_selection']!,
          _handSelectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_handSelectionMeta);
    }
    if (data.containsKey('musical_key')) {
      context.handle(
        _musicalKeyMeta,
        musicalKey.isAcceptableOrUnknown(data['musical_key']!, _musicalKeyMeta),
      );
    }
    if (data.containsKey('scale_type')) {
      context.handle(
        _scaleTypeMeta,
        scaleType.isAcceptableOrUnknown(data['scale_type']!, _scaleTypeMeta),
      );
    }
    if (data.containsKey('chord_type')) {
      context.handle(
        _chordTypeMeta,
        chordType.isAcceptableOrUnknown(data['chord_type']!, _chordTypeMeta),
      );
    }
    if (data.containsKey('include_inversions')) {
      context.handle(
        _includeInversionsMeta,
        includeInversions.isAcceptableOrUnknown(
          data['include_inversions']!,
          _includeInversionsMeta,
        ),
      );
    }
    if (data.containsKey('include_seventh_chords')) {
      context.handle(
        _includeSeventhChordsMeta,
        includeSeventhChords.isAcceptableOrUnknown(
          data['include_seventh_chords']!,
          _includeSeventhChordsMeta,
        ),
      );
    }
    if (data.containsKey('musical_note')) {
      context.handle(
        _musicalNoteMeta,
        musicalNote.isAcceptableOrUnknown(
          data['musical_note']!,
          _musicalNoteMeta,
        ),
      );
    }
    if (data.containsKey('arpeggio_type')) {
      context.handle(
        _arpeggioTypeMeta,
        arpeggioType.isAcceptableOrUnknown(
          data['arpeggio_type']!,
          _arpeggioTypeMeta,
        ),
      );
    }
    if (data.containsKey('arpeggio_octaves')) {
      context.handle(
        _arpeggioOctavesMeta,
        arpeggioOctaves.isAcceptableOrUnknown(
          data['arpeggio_octaves']!,
          _arpeggioOctavesMeta,
        ),
      );
    }
    if (data.containsKey('chord_progression_id')) {
      context.handle(
        _chordProgressionIdMeta,
        chordProgressionId.isAcceptableOrUnknown(
          data['chord_progression_id']!,
          _chordProgressionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      practiceMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_mode'],
      )!,
      handSelection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand_selection'],
      )!,
      musicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}musical_key'],
      ),
      scaleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scale_type'],
      ),
      chordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chord_type'],
      ),
      includeInversions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_inversions'],
      )!,
      includeSeventhChords: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_seventh_chords'],
      )!,
      musicalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}musical_note'],
      ),
      arpeggioType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arpeggio_type'],
      ),
      arpeggioOctaves: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arpeggio_octaves'],
      ),
      chordProgressionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chord_progression_id'],
      ),
    );
  }

  @override
  $ExerciseHistoryTableTable createAlias(String alias) {
    return $ExerciseHistoryTableTable(attachedDatabase, alias);
  }
}

class ExerciseHistoryTableData extends DataClass
    implements Insertable<ExerciseHistoryTableData> {
  /// Unique identifier for this history entry (UUID v4).
  final String id;

  /// Foreign-key reference to the [UserProfileTable] that owns this entry.
  ///
  /// `customConstraint` adds the REFERENCES clause while keeping drift's
  /// own NOT NULL constraint in place.
  final String profileId;

  /// Wall-clock timestamp when the exercise was completed.
  final DateTime completedAt;

  /// Practice mode name (e.g. "scales", "chordsByKey"). Never null.
  final String practiceMode;

  /// Hand selection name (e.g. "right", "left", "both"). Never null.
  final String handSelection;

  /// Musical key name (e.g. "c", "fSharp"). Null for modes without a key.
  final String? musicalKey;

  /// Scale type name (e.g. "major", "dorian"). Null for non-scale modes.
  final String? scaleType;

  /// Chord type name (e.g. "major", "dominant7"). Null for non-chord modes.
  final String? chordType;

  /// Whether inversions were included (chordsByType mode).
  final bool includeInversions;

  /// Whether seventh chords were included (chordsByKey mode).
  final bool includeSeventhChords;

  /// Root note name for arpeggios mode (e.g. "c", "fSharp"). Null otherwise.
  final String? musicalNote;

  /// Arpeggio type name (e.g. "major", "minor7"). Null for non-arpeggio modes.
  final String? arpeggioType;

  /// Arpeggio octave count name (e.g. "one", "two"). Null for non-arpeggio modes.
  final String? arpeggioOctaves;

  /// Chord progression identifier (chordProgressions mode). Null otherwise.
  final String? chordProgressionId;
  const ExerciseHistoryTableData({
    required this.id,
    required this.profileId,
    required this.completedAt,
    required this.practiceMode,
    required this.handSelection,
    this.musicalKey,
    this.scaleType,
    this.chordType,
    required this.includeInversions,
    required this.includeSeventhChords,
    this.musicalNote,
    this.arpeggioType,
    this.arpeggioOctaves,
    this.chordProgressionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['practice_mode'] = Variable<String>(practiceMode);
    map['hand_selection'] = Variable<String>(handSelection);
    if (!nullToAbsent || musicalKey != null) {
      map['musical_key'] = Variable<String>(musicalKey);
    }
    if (!nullToAbsent || scaleType != null) {
      map['scale_type'] = Variable<String>(scaleType);
    }
    if (!nullToAbsent || chordType != null) {
      map['chord_type'] = Variable<String>(chordType);
    }
    map['include_inversions'] = Variable<bool>(includeInversions);
    map['include_seventh_chords'] = Variable<bool>(includeSeventhChords);
    if (!nullToAbsent || musicalNote != null) {
      map['musical_note'] = Variable<String>(musicalNote);
    }
    if (!nullToAbsent || arpeggioType != null) {
      map['arpeggio_type'] = Variable<String>(arpeggioType);
    }
    if (!nullToAbsent || arpeggioOctaves != null) {
      map['arpeggio_octaves'] = Variable<String>(arpeggioOctaves);
    }
    if (!nullToAbsent || chordProgressionId != null) {
      map['chord_progression_id'] = Variable<String>(chordProgressionId);
    }
    return map;
  }

  ExerciseHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return ExerciseHistoryTableCompanion(
      id: Value(id),
      profileId: Value(profileId),
      completedAt: Value(completedAt),
      practiceMode: Value(practiceMode),
      handSelection: Value(handSelection),
      musicalKey: musicalKey == null && nullToAbsent
          ? const Value.absent()
          : Value(musicalKey),
      scaleType: scaleType == null && nullToAbsent
          ? const Value.absent()
          : Value(scaleType),
      chordType: chordType == null && nullToAbsent
          ? const Value.absent()
          : Value(chordType),
      includeInversions: Value(includeInversions),
      includeSeventhChords: Value(includeSeventhChords),
      musicalNote: musicalNote == null && nullToAbsent
          ? const Value.absent()
          : Value(musicalNote),
      arpeggioType: arpeggioType == null && nullToAbsent
          ? const Value.absent()
          : Value(arpeggioType),
      arpeggioOctaves: arpeggioOctaves == null && nullToAbsent
          ? const Value.absent()
          : Value(arpeggioOctaves),
      chordProgressionId: chordProgressionId == null && nullToAbsent
          ? const Value.absent()
          : Value(chordProgressionId),
    );
  }

  factory ExerciseHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      practiceMode: serializer.fromJson<String>(json['practiceMode']),
      handSelection: serializer.fromJson<String>(json['handSelection']),
      musicalKey: serializer.fromJson<String?>(json['musicalKey']),
      scaleType: serializer.fromJson<String?>(json['scaleType']),
      chordType: serializer.fromJson<String?>(json['chordType']),
      includeInversions: serializer.fromJson<bool>(json['includeInversions']),
      includeSeventhChords: serializer.fromJson<bool>(
        json['includeSeventhChords'],
      ),
      musicalNote: serializer.fromJson<String?>(json['musicalNote']),
      arpeggioType: serializer.fromJson<String?>(json['arpeggioType']),
      arpeggioOctaves: serializer.fromJson<String?>(json['arpeggioOctaves']),
      chordProgressionId: serializer.fromJson<String?>(
        json['chordProgressionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'practiceMode': serializer.toJson<String>(practiceMode),
      'handSelection': serializer.toJson<String>(handSelection),
      'musicalKey': serializer.toJson<String?>(musicalKey),
      'scaleType': serializer.toJson<String?>(scaleType),
      'chordType': serializer.toJson<String?>(chordType),
      'includeInversions': serializer.toJson<bool>(includeInversions),
      'includeSeventhChords': serializer.toJson<bool>(includeSeventhChords),
      'musicalNote': serializer.toJson<String?>(musicalNote),
      'arpeggioType': serializer.toJson<String?>(arpeggioType),
      'arpeggioOctaves': serializer.toJson<String?>(arpeggioOctaves),
      'chordProgressionId': serializer.toJson<String?>(chordProgressionId),
    };
  }

  ExerciseHistoryTableData copyWith({
    String? id,
    String? profileId,
    DateTime? completedAt,
    String? practiceMode,
    String? handSelection,
    Value<String?> musicalKey = const Value.absent(),
    Value<String?> scaleType = const Value.absent(),
    Value<String?> chordType = const Value.absent(),
    bool? includeInversions,
    bool? includeSeventhChords,
    Value<String?> musicalNote = const Value.absent(),
    Value<String?> arpeggioType = const Value.absent(),
    Value<String?> arpeggioOctaves = const Value.absent(),
    Value<String?> chordProgressionId = const Value.absent(),
  }) => ExerciseHistoryTableData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    completedAt: completedAt ?? this.completedAt,
    practiceMode: practiceMode ?? this.practiceMode,
    handSelection: handSelection ?? this.handSelection,
    musicalKey: musicalKey.present ? musicalKey.value : this.musicalKey,
    scaleType: scaleType.present ? scaleType.value : this.scaleType,
    chordType: chordType.present ? chordType.value : this.chordType,
    includeInversions: includeInversions ?? this.includeInversions,
    includeSeventhChords: includeSeventhChords ?? this.includeSeventhChords,
    musicalNote: musicalNote.present ? musicalNote.value : this.musicalNote,
    arpeggioType: arpeggioType.present ? arpeggioType.value : this.arpeggioType,
    arpeggioOctaves: arpeggioOctaves.present
        ? arpeggioOctaves.value
        : this.arpeggioOctaves,
    chordProgressionId: chordProgressionId.present
        ? chordProgressionId.value
        : this.chordProgressionId,
  );
  ExerciseHistoryTableData copyWithCompanion(
    ExerciseHistoryTableCompanion data,
  ) {
    return ExerciseHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      practiceMode: data.practiceMode.present
          ? data.practiceMode.value
          : this.practiceMode,
      handSelection: data.handSelection.present
          ? data.handSelection.value
          : this.handSelection,
      musicalKey: data.musicalKey.present
          ? data.musicalKey.value
          : this.musicalKey,
      scaleType: data.scaleType.present ? data.scaleType.value : this.scaleType,
      chordType: data.chordType.present ? data.chordType.value : this.chordType,
      includeInversions: data.includeInversions.present
          ? data.includeInversions.value
          : this.includeInversions,
      includeSeventhChords: data.includeSeventhChords.present
          ? data.includeSeventhChords.value
          : this.includeSeventhChords,
      musicalNote: data.musicalNote.present
          ? data.musicalNote.value
          : this.musicalNote,
      arpeggioType: data.arpeggioType.present
          ? data.arpeggioType.value
          : this.arpeggioType,
      arpeggioOctaves: data.arpeggioOctaves.present
          ? data.arpeggioOctaves.value
          : this.arpeggioOctaves,
      chordProgressionId: data.chordProgressionId.present
          ? data.chordProgressionId.value
          : this.chordProgressionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseHistoryTableData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('completedAt: $completedAt, ')
          ..write('practiceMode: $practiceMode, ')
          ..write('handSelection: $handSelection, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('scaleType: $scaleType, ')
          ..write('chordType: $chordType, ')
          ..write('includeInversions: $includeInversions, ')
          ..write('includeSeventhChords: $includeSeventhChords, ')
          ..write('musicalNote: $musicalNote, ')
          ..write('arpeggioType: $arpeggioType, ')
          ..write('arpeggioOctaves: $arpeggioOctaves, ')
          ..write('chordProgressionId: $chordProgressionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    completedAt,
    practiceMode,
    handSelection,
    musicalKey,
    scaleType,
    chordType,
    includeInversions,
    includeSeventhChords,
    musicalNote,
    arpeggioType,
    arpeggioOctaves,
    chordProgressionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseHistoryTableData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.completedAt == this.completedAt &&
          other.practiceMode == this.practiceMode &&
          other.handSelection == this.handSelection &&
          other.musicalKey == this.musicalKey &&
          other.scaleType == this.scaleType &&
          other.chordType == this.chordType &&
          other.includeInversions == this.includeInversions &&
          other.includeSeventhChords == this.includeSeventhChords &&
          other.musicalNote == this.musicalNote &&
          other.arpeggioType == this.arpeggioType &&
          other.arpeggioOctaves == this.arpeggioOctaves &&
          other.chordProgressionId == this.chordProgressionId);
}

class ExerciseHistoryTableCompanion
    extends UpdateCompanion<ExerciseHistoryTableData> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<DateTime> completedAt;
  final Value<String> practiceMode;
  final Value<String> handSelection;
  final Value<String?> musicalKey;
  final Value<String?> scaleType;
  final Value<String?> chordType;
  final Value<bool> includeInversions;
  final Value<bool> includeSeventhChords;
  final Value<String?> musicalNote;
  final Value<String?> arpeggioType;
  final Value<String?> arpeggioOctaves;
  final Value<String?> chordProgressionId;
  final Value<int> rowid;
  const ExerciseHistoryTableCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.practiceMode = const Value.absent(),
    this.handSelection = const Value.absent(),
    this.musicalKey = const Value.absent(),
    this.scaleType = const Value.absent(),
    this.chordType = const Value.absent(),
    this.includeInversions = const Value.absent(),
    this.includeSeventhChords = const Value.absent(),
    this.musicalNote = const Value.absent(),
    this.arpeggioType = const Value.absent(),
    this.arpeggioOctaves = const Value.absent(),
    this.chordProgressionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseHistoryTableCompanion.insert({
    required String id,
    required String profileId,
    required DateTime completedAt,
    required String practiceMode,
    required String handSelection,
    this.musicalKey = const Value.absent(),
    this.scaleType = const Value.absent(),
    this.chordType = const Value.absent(),
    this.includeInversions = const Value.absent(),
    this.includeSeventhChords = const Value.absent(),
    this.musicalNote = const Value.absent(),
    this.arpeggioType = const Value.absent(),
    this.arpeggioOctaves = const Value.absent(),
    this.chordProgressionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       completedAt = Value(completedAt),
       practiceMode = Value(practiceMode),
       handSelection = Value(handSelection);
  static Insertable<ExerciseHistoryTableData> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<DateTime>? completedAt,
    Expression<String>? practiceMode,
    Expression<String>? handSelection,
    Expression<String>? musicalKey,
    Expression<String>? scaleType,
    Expression<String>? chordType,
    Expression<bool>? includeInversions,
    Expression<bool>? includeSeventhChords,
    Expression<String>? musicalNote,
    Expression<String>? arpeggioType,
    Expression<String>? arpeggioOctaves,
    Expression<String>? chordProgressionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (completedAt != null) 'completed_at': completedAt,
      if (practiceMode != null) 'practice_mode': practiceMode,
      if (handSelection != null) 'hand_selection': handSelection,
      if (musicalKey != null) 'musical_key': musicalKey,
      if (scaleType != null) 'scale_type': scaleType,
      if (chordType != null) 'chord_type': chordType,
      if (includeInversions != null) 'include_inversions': includeInversions,
      if (includeSeventhChords != null)
        'include_seventh_chords': includeSeventhChords,
      if (musicalNote != null) 'musical_note': musicalNote,
      if (arpeggioType != null) 'arpeggio_type': arpeggioType,
      if (arpeggioOctaves != null) 'arpeggio_octaves': arpeggioOctaves,
      if (chordProgressionId != null)
        'chord_progression_id': chordProgressionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<DateTime>? completedAt,
    Value<String>? practiceMode,
    Value<String>? handSelection,
    Value<String?>? musicalKey,
    Value<String?>? scaleType,
    Value<String?>? chordType,
    Value<bool>? includeInversions,
    Value<bool>? includeSeventhChords,
    Value<String?>? musicalNote,
    Value<String?>? arpeggioType,
    Value<String?>? arpeggioOctaves,
    Value<String?>? chordProgressionId,
    Value<int>? rowid,
  }) {
    return ExerciseHistoryTableCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      completedAt: completedAt ?? this.completedAt,
      practiceMode: practiceMode ?? this.practiceMode,
      handSelection: handSelection ?? this.handSelection,
      musicalKey: musicalKey ?? this.musicalKey,
      scaleType: scaleType ?? this.scaleType,
      chordType: chordType ?? this.chordType,
      includeInversions: includeInversions ?? this.includeInversions,
      includeSeventhChords: includeSeventhChords ?? this.includeSeventhChords,
      musicalNote: musicalNote ?? this.musicalNote,
      arpeggioType: arpeggioType ?? this.arpeggioType,
      arpeggioOctaves: arpeggioOctaves ?? this.arpeggioOctaves,
      chordProgressionId: chordProgressionId ?? this.chordProgressionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (practiceMode.present) {
      map['practice_mode'] = Variable<String>(practiceMode.value);
    }
    if (handSelection.present) {
      map['hand_selection'] = Variable<String>(handSelection.value);
    }
    if (musicalKey.present) {
      map['musical_key'] = Variable<String>(musicalKey.value);
    }
    if (scaleType.present) {
      map['scale_type'] = Variable<String>(scaleType.value);
    }
    if (chordType.present) {
      map['chord_type'] = Variable<String>(chordType.value);
    }
    if (includeInversions.present) {
      map['include_inversions'] = Variable<bool>(includeInversions.value);
    }
    if (includeSeventhChords.present) {
      map['include_seventh_chords'] = Variable<bool>(
        includeSeventhChords.value,
      );
    }
    if (musicalNote.present) {
      map['musical_note'] = Variable<String>(musicalNote.value);
    }
    if (arpeggioType.present) {
      map['arpeggio_type'] = Variable<String>(arpeggioType.value);
    }
    if (arpeggioOctaves.present) {
      map['arpeggio_octaves'] = Variable<String>(arpeggioOctaves.value);
    }
    if (chordProgressionId.present) {
      map['chord_progression_id'] = Variable<String>(chordProgressionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('completedAt: $completedAt, ')
          ..write('practiceMode: $practiceMode, ')
          ..write('handSelection: $handSelection, ')
          ..write('musicalKey: $musicalKey, ')
          ..write('scaleType: $scaleType, ')
          ..write('chordType: $chordType, ')
          ..write('includeInversions: $includeInversions, ')
          ..write('includeSeventhChords: $includeSeventhChords, ')
          ..write('musicalNote: $musicalNote, ')
          ..write('arpeggioType: $arpeggioType, ')
          ..write('arpeggioOctaves: $arpeggioOctaves, ')
          ..write('chordProgressionId: $chordProgressionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfileTableTable userProfileTable = $UserProfileTableTable(
    this,
  );
  late final $ExerciseHistoryTableTable exerciseHistoryTable =
      $ExerciseHistoryTableTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final ExerciseHistoryDao exerciseHistoryDao = ExerciseHistoryDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfileTable,
    exerciseHistoryTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_profile_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_history_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UserProfileTableTableCreateCompanionBuilder =
    UserProfileTableCompanion Function({
      required String id,
      required String displayName,
      Value<DateTime?> lastPracticeDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserProfileTableTableUpdateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<DateTime?> lastPracticeDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$UserProfileTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserProfileTableTable,
          UserProfileTableData
        > {
  $$UserProfileTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ExerciseHistoryTableTable,
    List<ExerciseHistoryTableData>
  >
  _exerciseHistoryTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseHistoryTable,
        aliasName: $_aliasNameGenerator(
          db.userProfileTable.id,
          db.exerciseHistoryTable.profileId,
        ),
      );

  $$ExerciseHistoryTableTableProcessedTableManager
  get exerciseHistoryTableRefs {
    final manager = $$ExerciseHistoryTableTableTableManager(
      $_db,
      $_db.exerciseHistoryTable,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseHistoryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPracticeDate => $composableBuilder(
    column: $table.lastPracticeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseHistoryTableRefs(
    Expression<bool> Function($$ExerciseHistoryTableTableFilterComposer f) f,
  ) {
    final $$ExerciseHistoryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseHistoryTable,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseHistoryTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseHistoryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPracticeDate => $composableBuilder(
    column: $table.lastPracticeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPracticeDate => $composableBuilder(
    column: $table.lastPracticeDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> exerciseHistoryTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseHistoryTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseHistoryTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseHistoryTable,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseHistoryTableTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UserProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTableTable,
          UserProfileTableData,
          $$UserProfileTableTableFilterComposer,
          $$UserProfileTableTableOrderingComposer,
          $$UserProfileTableTableAnnotationComposer,
          $$UserProfileTableTableCreateCompanionBuilder,
          $$UserProfileTableTableUpdateCompanionBuilder,
          (UserProfileTableData, $$UserProfileTableTableReferences),
          UserProfileTableData,
          PrefetchHooks Function({bool exerciseHistoryTableRefs})
        > {
  $$UserProfileTableTableTableManager(
    _$AppDatabase db,
    $UserProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime?> lastPracticeDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileTableCompanion(
                id: id,
                displayName: displayName,
                lastPracticeDate: lastPracticeDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<DateTime?> lastPracticeDate = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfileTableCompanion.insert(
                id: id,
                displayName: displayName,
                lastPracticeDate: lastPracticeDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfileTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseHistoryTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseHistoryTableRefs) db.exerciseHistoryTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseHistoryTableRefs)
                    await $_getPrefetchedData<
                      UserProfileTableData,
                      $UserProfileTableTable,
                      ExerciseHistoryTableData
                    >(
                      currentTable: table,
                      referencedTable: $$UserProfileTableTableReferences
                          ._exerciseHistoryTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserProfileTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseHistoryTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTableTable,
      UserProfileTableData,
      $$UserProfileTableTableFilterComposer,
      $$UserProfileTableTableOrderingComposer,
      $$UserProfileTableTableAnnotationComposer,
      $$UserProfileTableTableCreateCompanionBuilder,
      $$UserProfileTableTableUpdateCompanionBuilder,
      (UserProfileTableData, $$UserProfileTableTableReferences),
      UserProfileTableData,
      PrefetchHooks Function({bool exerciseHistoryTableRefs})
    >;
typedef $$ExerciseHistoryTableTableCreateCompanionBuilder =
    ExerciseHistoryTableCompanion Function({
      required String id,
      required String profileId,
      required DateTime completedAt,
      required String practiceMode,
      required String handSelection,
      Value<String?> musicalKey,
      Value<String?> scaleType,
      Value<String?> chordType,
      Value<bool> includeInversions,
      Value<bool> includeSeventhChords,
      Value<String?> musicalNote,
      Value<String?> arpeggioType,
      Value<String?> arpeggioOctaves,
      Value<String?> chordProgressionId,
      Value<int> rowid,
    });
typedef $$ExerciseHistoryTableTableUpdateCompanionBuilder =
    ExerciseHistoryTableCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<DateTime> completedAt,
      Value<String> practiceMode,
      Value<String> handSelection,
      Value<String?> musicalKey,
      Value<String?> scaleType,
      Value<String?> chordType,
      Value<bool> includeInversions,
      Value<bool> includeSeventhChords,
      Value<String?> musicalNote,
      Value<String?> arpeggioType,
      Value<String?> arpeggioOctaves,
      Value<String?> chordProgressionId,
      Value<int> rowid,
    });

final class $$ExerciseHistoryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseHistoryTableTable,
          ExerciseHistoryTableData
        > {
  $$ExerciseHistoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfileTableTable _profileIdTable(_$AppDatabase db) =>
      db.userProfileTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseHistoryTable.profileId,
          db.userProfileTable.id,
        ),
      );

  $$UserProfileTableTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$UserProfileTableTableTableManager(
      $_db,
      $_db.userProfileTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseHistoryTableTable> {
  $$ExerciseHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practiceMode => $composableBuilder(
    column: $table.practiceMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handSelection => $composableBuilder(
    column: $table.handSelection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scaleType => $composableBuilder(
    column: $table.scaleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chordType => $composableBuilder(
    column: $table.chordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInversions => $composableBuilder(
    column: $table.includeInversions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeSeventhChords => $composableBuilder(
    column: $table.includeSeventhChords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musicalNote => $composableBuilder(
    column: $table.musicalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arpeggioType => $composableBuilder(
    column: $table.arpeggioType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arpeggioOctaves => $composableBuilder(
    column: $table.arpeggioOctaves,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chordProgressionId => $composableBuilder(
    column: $table.chordProgressionId,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfileTableTableFilterComposer get profileId {
    final $$UserProfileTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfileTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfileTableTableFilterComposer(
            $db: $db,
            $table: $db.userProfileTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseHistoryTableTable> {
  $$ExerciseHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practiceMode => $composableBuilder(
    column: $table.practiceMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handSelection => $composableBuilder(
    column: $table.handSelection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scaleType => $composableBuilder(
    column: $table.scaleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chordType => $composableBuilder(
    column: $table.chordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInversions => $composableBuilder(
    column: $table.includeInversions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeSeventhChords => $composableBuilder(
    column: $table.includeSeventhChords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musicalNote => $composableBuilder(
    column: $table.musicalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arpeggioType => $composableBuilder(
    column: $table.arpeggioType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arpeggioOctaves => $composableBuilder(
    column: $table.arpeggioOctaves,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chordProgressionId => $composableBuilder(
    column: $table.chordProgressionId,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfileTableTableOrderingComposer get profileId {
    final $$UserProfileTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfileTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfileTableTableOrderingComposer(
            $db: $db,
            $table: $db.userProfileTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseHistoryTableTable> {
  $$ExerciseHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get practiceMode => $composableBuilder(
    column: $table.practiceMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handSelection => $composableBuilder(
    column: $table.handSelection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicalKey => $composableBuilder(
    column: $table.musicalKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scaleType =>
      $composableBuilder(column: $table.scaleType, builder: (column) => column);

  GeneratedColumn<String> get chordType =>
      $composableBuilder(column: $table.chordType, builder: (column) => column);

  GeneratedColumn<bool> get includeInversions => $composableBuilder(
    column: $table.includeInversions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeSeventhChords => $composableBuilder(
    column: $table.includeSeventhChords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musicalNote => $composableBuilder(
    column: $table.musicalNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arpeggioType => $composableBuilder(
    column: $table.arpeggioType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arpeggioOctaves => $composableBuilder(
    column: $table.arpeggioOctaves,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chordProgressionId => $composableBuilder(
    column: $table.chordProgressionId,
    builder: (column) => column,
  );

  $$UserProfileTableTableAnnotationComposer get profileId {
    final $$UserProfileTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfileTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfileTableTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfileTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseHistoryTableTable,
          ExerciseHistoryTableData,
          $$ExerciseHistoryTableTableFilterComposer,
          $$ExerciseHistoryTableTableOrderingComposer,
          $$ExerciseHistoryTableTableAnnotationComposer,
          $$ExerciseHistoryTableTableCreateCompanionBuilder,
          $$ExerciseHistoryTableTableUpdateCompanionBuilder,
          (ExerciseHistoryTableData, $$ExerciseHistoryTableTableReferences),
          ExerciseHistoryTableData,
          PrefetchHooks Function({bool profileId})
        > {
  $$ExerciseHistoryTableTableTableManager(
    _$AppDatabase db,
    $ExerciseHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExerciseHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> practiceMode = const Value.absent(),
                Value<String> handSelection = const Value.absent(),
                Value<String?> musicalKey = const Value.absent(),
                Value<String?> scaleType = const Value.absent(),
                Value<String?> chordType = const Value.absent(),
                Value<bool> includeInversions = const Value.absent(),
                Value<bool> includeSeventhChords = const Value.absent(),
                Value<String?> musicalNote = const Value.absent(),
                Value<String?> arpeggioType = const Value.absent(),
                Value<String?> arpeggioOctaves = const Value.absent(),
                Value<String?> chordProgressionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseHistoryTableCompanion(
                id: id,
                profileId: profileId,
                completedAt: completedAt,
                practiceMode: practiceMode,
                handSelection: handSelection,
                musicalKey: musicalKey,
                scaleType: scaleType,
                chordType: chordType,
                includeInversions: includeInversions,
                includeSeventhChords: includeSeventhChords,
                musicalNote: musicalNote,
                arpeggioType: arpeggioType,
                arpeggioOctaves: arpeggioOctaves,
                chordProgressionId: chordProgressionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required DateTime completedAt,
                required String practiceMode,
                required String handSelection,
                Value<String?> musicalKey = const Value.absent(),
                Value<String?> scaleType = const Value.absent(),
                Value<String?> chordType = const Value.absent(),
                Value<bool> includeInversions = const Value.absent(),
                Value<bool> includeSeventhChords = const Value.absent(),
                Value<String?> musicalNote = const Value.absent(),
                Value<String?> arpeggioType = const Value.absent(),
                Value<String?> arpeggioOctaves = const Value.absent(),
                Value<String?> chordProgressionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseHistoryTableCompanion.insert(
                id: id,
                profileId: profileId,
                completedAt: completedAt,
                practiceMode: practiceMode,
                handSelection: handSelection,
                musicalKey: musicalKey,
                scaleType: scaleType,
                chordType: chordType,
                includeInversions: includeInversions,
                includeSeventhChords: includeSeventhChords,
                musicalNote: musicalNote,
                arpeggioType: arpeggioType,
                arpeggioOctaves: arpeggioOctaves,
                chordProgressionId: chordProgressionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseHistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable:
                                    $$ExerciseHistoryTableTableReferences
                                        ._profileIdTable(db),
                                referencedColumn:
                                    $$ExerciseHistoryTableTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseHistoryTableTable,
      ExerciseHistoryTableData,
      $$ExerciseHistoryTableTableFilterComposer,
      $$ExerciseHistoryTableTableOrderingComposer,
      $$ExerciseHistoryTableTableAnnotationComposer,
      $$ExerciseHistoryTableTableCreateCompanionBuilder,
      $$ExerciseHistoryTableTableUpdateCompanionBuilder,
      (ExerciseHistoryTableData, $$ExerciseHistoryTableTableReferences),
      ExerciseHistoryTableData,
      PrefetchHooks Function({bool profileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$ExerciseHistoryTableTableTableManager get exerciseHistoryTable =>
      $$ExerciseHistoryTableTableTableManager(_db, _db.exerciseHistoryTable);
}
