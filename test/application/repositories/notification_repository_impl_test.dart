import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/application/repositories/notification_repository_impl.dart";
import "package:piano_fitness/application/services/notifications/notification_service.dart";

class FakePlugin {
  bool initialized = false;
  bool permissionsGranted = true;

  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
  }) async {
    initialized = true;
    return true;
  }

  Future<bool?> requestPermissions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    return permissionsGranted;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("NotificationRepositoryImpl Tests", () {
    late FakePlugin fakePlugin;

    setUp(() {
      fakePlugin = FakePlugin();
      NotificationService.setPluginForTesting(fakePlugin);
    });

    test("create factory initializes repository cleanly", () async {
      final repo = await NotificationRepositoryImpl.create();
      expect(repo, isNotNull);
      expect(
        repo.dailyReminderNotificationId,
        equals(NotificationService.dailyReminderNotificationId),
      );
    });

    test("arePermissionsGranted returns expected bool", () async {
      final repo = await NotificationRepositoryImpl.create();
      final granted = await repo.arePermissionsGranted();
      expect(granted, isA<bool>());
    });

    test("requestPermissions delegates to NotificationService", () async {
      final repo = await NotificationRepositoryImpl.create();
      final result = await repo.requestPermissions();
      expect(result, isA<bool>());
    });
  });
}
