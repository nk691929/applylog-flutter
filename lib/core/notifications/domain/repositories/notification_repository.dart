abstract interface class NotificationRepository {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleFollowUpReminder({
    required int id,
    required String companyName,
    required DateTime scheduledDate,
  });
  Future<void> cancelReminder(int id);
  Future<void> showTestNotification();
}
