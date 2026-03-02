import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/domain/models/user_profile.dart";

void main() {
  group("UserProfile", () {
    test("creates valid profile with required fields", () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: now,
      );

      expect(profile.id, "test-id");
      expect(profile.displayName, "John");
      expect(profile.createdAt, now);
      expect(profile.lastPracticeDate, isNull);
    });

    test("creates valid profile with all fields", () {
      final now = DateTime.now();
      final lastPractice = DateTime(2026, 3);
      final profile = UserProfile(
        id: "test-id",
        displayName: "Jane",
        lastPracticeDate: lastPractice,
        createdAt: now,
      );

      expect(profile.id, "test-id");
      expect(profile.displayName, "Jane");
      expect(profile.lastPracticeDate, lastPractice);
      expect(profile.createdAt, now);
    });

    test("trims whitespace from display name", () {
      final profile = UserProfile(
        id: "test-id",
        displayName: "  John  ",
        createdAt: DateTime.now(),
      );

      expect(profile.displayName, "John");
    });

    test("throws ArgumentError for empty display name", () {
      expect(
        () => UserProfile(
          id: "test-id",
          displayName: "",
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("throws ArgumentError for whitespace-only display name", () {
      expect(
        () => UserProfile(
          id: "test-id",
          displayName: "   ",
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("throws ArgumentError for display name > 30 characters", () {
      expect(
        () => UserProfile(
          id: "test-id",
          displayName: "a" * 31,
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("allows display name exactly 30 characters", () {
      final profile = UserProfile(
        id: "test-id",
        displayName: "a" * 30,
        createdAt: DateTime.now(),
      );

      expect(profile.displayName.length, 30);
    });

    test("copyWith creates new instance with updated fields", () {
      final original = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(displayName: "Jane");

      expect(updated.id, original.id);
      expect(updated.displayName, "Jane");
      expect(updated.createdAt, original.createdAt);
    });

    test("copyWith updates lastPracticeDate", () {
      final original = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: DateTime.now(),
      );

      final lastPractice = DateTime(2026, 3);
      final updated = original.copyWith(lastPracticeDate: lastPractice);

      expect(updated.lastPracticeDate, lastPractice);
    });

    test("equality works correctly", () {
      final now = DateTime.now();
      final profile1 = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: now,
      );
      final profile2 = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: now,
      );
      final profile3 = UserProfile(
        id: "different-id",
        displayName: "John",
        createdAt: now,
      );

      expect(profile1, equals(profile2));
      expect(profile1, isNot(equals(profile3)));
    });

    test("hashCode works correctly", () {
      final now = DateTime.now();
      final profile1 = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: now,
      );
      final profile2 = UserProfile(
        id: "test-id",
        displayName: "John",
        createdAt: now,
      );

      expect(profile1.hashCode, equals(profile2.hashCode));
    });

    test("toString includes all fields", () {
      final now = DateTime.now();
      final profile = UserProfile(
        id: "test-id",
        displayName: "John",
        lastPracticeDate: DateTime(2026, 3),
        createdAt: now,
      );

      final string = profile.toString();
      expect(string, contains("test-id"));
      expect(string, contains("John"));
      expect(string, contains("2026-03-01"));
    });
  });
}
