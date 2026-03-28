// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import "package:drift/drift.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:flutter_test/flutter_test.dart";
import "generated/schema.dart";

import "generated/schema_v2.dart" as v2;
import "generated/schema_v3.dart" as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group("simple database migrations", () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group("from $fromVersion", () {
        for (final toVersion in versions.skip(i + 1)) {
          test("to $toVersion", () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test("migration from v2 to v3 preserves existing user profiles", () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        // Insert a profile row into the v2 database before migration.
        batch.insert(
          oldDb.userProfileTable,
          RawValuesInsertable<v2.UserProfileTableData>({
            "id": const Constant("test-profile-id"),
            "display_name": const Constant("Test User"),
            "created_at": Constant(DateTime(2025).millisecondsSinceEpoch),
          }),
        );
      },
      validateItems: (newDb) async {
        // The v2→v3 migration is additive (new table only); existing rows
        // in user_profile_table must survive unchanged.
        final profiles = await newDb.select(newDb.userProfileTable).get();
        expect(profiles.length, equals(1));
        expect(profiles.first.id, equals("test-profile-id"));
        expect(profiles.first.displayName, equals("Test User"));
      },
    );
  });
}
