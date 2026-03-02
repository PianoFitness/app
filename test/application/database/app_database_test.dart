// Unit tests for AppDatabase.
//
// Uses an in-memory SQLite executor so tests are fast, deterministic, and
// never touch the filesystem. The in-memory path is the same one repositories
// should use in their own unit tests (see test/shared/test_helpers/).

import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

import "package:piano_fitness/application/database/app_database.dart";

void main() {
  group("AppDatabase", () {
    late AppDatabase db;

    setUp(() {
      // Pass an in-memory executor so no file I/O occurs during tests.
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test("can be instantiated with a custom in-memory executor", () {
      // If the constructor signature or super-call regresses, this will fail
      // at construction time rather than producing a cryptic runtime error.
      expect(db, isA<AppDatabase>());
    });

    test("schemaVersion is 1", () {
      // Prevents accidental schema version bumps before migrations are wired.
      expect(db.schemaVersion, 1);
    });

    test("opens and closes without error", () async {
      // Executes a trivial query to confirm the connection is live, then
      // verifies close() completes without throwing.
      await expectLater(db.customSelect("SELECT 1").get(), completes);
      await expectLater(db.close(), completes);

      // Prevent tearDown from calling close() a second time.
      db = AppDatabase(NativeDatabase.memory());
    });
  });
}
