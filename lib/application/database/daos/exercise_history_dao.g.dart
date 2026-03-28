// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_history_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfileTableTable get userProfileTable =>
      attachedDatabase.userProfileTable;
  $ExerciseHistoryTableTable get exerciseHistoryTable =>
      attachedDatabase.exerciseHistoryTable;
  ExerciseHistoryDaoManager get managers => ExerciseHistoryDaoManager(this);
}

class ExerciseHistoryDaoManager {
  final _$ExerciseHistoryDaoMixin _db;
  ExerciseHistoryDaoManager(this._db);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfileTable,
      );
  $$ExerciseHistoryTableTableTableManager get exerciseHistoryTable =>
      $$ExerciseHistoryTableTableTableManager(
        _db.attachedDatabase,
        _db.exerciseHistoryTable,
      );
}
