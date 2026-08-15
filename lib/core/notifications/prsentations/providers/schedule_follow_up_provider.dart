import 'package:applylog/core/notifications/domain/usecases/schedule_follow_up_reminder.dart';
import 'package:applylog/core/notifications/prsentations/providers/notification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleFollowUpProvider = Provider<ScheduleFollowUpReminder>((ref) {
  return ScheduleFollowUpReminder(ref.read(notificationRepositoryProvider));
});
