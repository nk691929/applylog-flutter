import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApplicationStats {
  final int total;
  final Map<ApplicationStatus, dynamic> byStatus;
  final double responseRate;
  const ApplicationStats({
    required this.total,
    required this.byStatus,
    required this.responseRate,
  });
}

final dashboardProvider = Provider<AsyncValue<ApplicationStats>>((ref) {
  final applicationAsync = ref.watch(applicationStreamProvider);
  return applicationAsync.whenData((result) {
    switch (result) {
      case Success(data: final applications):
        final byStatus = <ApplicationStatus, int>{
          for (final status in ApplicationStatus.values) status: 0,
        };
        for (final app in applications) {
          byStatus[app.status] = (byStatus[app.status] ?? 0) + 1;
        }
        final responded = applications
            .where((a) => a.status != ApplicationStatus.applied)
            .length;
        final responseRate = applications.isEmpty
            ? 0.0
            : (responded / applications.length) * 100;
        return ApplicationStats(
          total: applications.length,
          byStatus: byStatus,
          responseRate: responseRate,
        );
      case Error():
        return const ApplicationStats(total: 0, byStatus: {}, responseRate: 0);
    }
  });
});
