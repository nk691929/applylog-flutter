import 'package:applylog/core/notifications/data/services/local_notification_service.dart';
import 'package:applylog/core/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return LocalNotificationService();
});
