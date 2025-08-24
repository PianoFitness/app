import "package:flutter/material.dart";

/// Placeholder page for notification settings.
///
/// This will be implemented in Phase 2 with full UI and ViewModel integration.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Notification Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Coming in Phase 2",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
