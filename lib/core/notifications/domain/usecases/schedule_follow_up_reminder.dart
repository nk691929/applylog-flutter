import 'package:applylog/core/notifications/domain/repositories/notification_repository.dart';

class ScheduleFollowUpReminder {
  final NotificationRepository _repository;
  const ScheduleFollowUpReminder(this._repository);

  Future<void> call({
    required int id,
    required String companyName,
    required DateTime scheduledDate,
  }) async {
    await _repository.scheduleFollowUpReminder(
      id: id,
      companyName: companyName,
      scheduledDate: scheduledDate,
    );
  }
}
