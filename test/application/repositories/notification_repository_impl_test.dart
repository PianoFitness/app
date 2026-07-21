import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/notification_repository_impl.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("NotificationRepositoryImpl Unit Tests", () {
    test("create initializes repository instance", () async {
      final repo = await NotificationRepositoryImpl.create();
      expect(repo, isNotNull);
      expect(repo.dailyReminderNotificationId, equals(1001));
    });

    test("getPendingNotifications returns empty list by default", () async {
      final repo = await NotificationRepositoryImpl.create();
      final pending = await repo.getPendingNotifications();
      expect(pending, isEmpty);
    });

    test(
      "permissions check handles uninitialized environment gracefully",
      () async {
        final repo = await NotificationRepositoryImpl.create();
        final granted = await repo.arePermissionsGranted();
        expect(granted, isFalse);
      },
    );

    test(
      "requestPermissions handles uninitialized environment gracefully",
      () async {
        final repo = await NotificationRepositoryImpl.create();
        final granted = await repo.requestPermissions();
        expect(granted, isFalse);
      },
    );
  });
}
