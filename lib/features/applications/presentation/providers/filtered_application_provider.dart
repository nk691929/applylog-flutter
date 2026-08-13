import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fiteredApplicationProvider = Provider<AsyncValue<List<Application>>>((
  ref,
) {
  final applicationAsync = ref.watch(applicationStreamProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);
  final searchQuary = ref.watch(searchQueryProvider);

  return applicationAsync.whenData((result) {
    switch (result) {
      case Success(data: final applications):
        return applications.where((app) {
          final matchStatus =
              selectedStatus == null || selectedStatus == app.status;
          final matchedSearch =
              searchQuary.isEmpty ||
              app.companyName.toLowerCase().contains(searchQuary) ||
              app.roleTitle.toLowerCase().contains(searchQuary);
          return matchStatus && matchedSearch;
        }).toList();
      case Error():
        return <Application>[];
    }
  });
});
