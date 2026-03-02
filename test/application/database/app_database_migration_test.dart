// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import "package:drift/drift.dart";
import "package:drift_dev/api/migrations_native.dart";
import "package:piano_fitness/application/database/app_database.dart";
import "package:flutter_test/flutter_test.dart";
import "../../app_database/generated/schema.dart";

import "../../app_database/generated/schema_v1.dart" as v1;
import "../../app_database/generated/schema_v2.dart" as v2;

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
            try {
              await verifier.migrateAndValidate(db, toVersion);
            } finally {
              await db.close();
            }
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity

  // Note: This test is currently skipped because our v1→v2 migration only adds
  // the user_profiles table without modifying existing tables. If future
  // migrations modify existing columns or need data integrity validation,
  // implement createItems and validateItems with representative test data.
  test(
    "migration from v1 to v2 does not corrupt data",
    () async {
      // Add data to insert into the old database, and the expected rows after the
      // migration.

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          // No items to create - v1 had no tables, v2 adds user_profiles table
        },
        validateItems: (newDb) async {
          // No validation needed - migration only adds tables
        },
      );
    },
    skip: "Migration only adds tables, no data integrity testing needed",
  );
}
