import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApplicationListScreen extends ConsumerStatefulWidget {
  const ApplicationListScreen({super.key});

  @override
  ConsumerState<ApplicationListScreen> createState() =>
      _ApplicationListScreenState();
}

class _ApplicationListScreenState extends ConsumerState<ApplicationListScreen> {
  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Colors.blue;
      case ApplicationStatus.screening:
        return Colors.orange;
      case ApplicationStatus.interview:
        return Colors.purple;
      case ApplicationStatus.offer:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationAsync = ref.watch(applicationStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authRepositoryProvider).signout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      body: applicationAsync.when(
        data: (result) {
          switch (result) {
            case Success(data: final applications):
              if (applications.isEmpty) {
                return const Center(
                  child: Text('No applications yet. Tap + to add one.'),
                );
              }
              return ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(app.status),
                      child: Text(
                        app.companyName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(app.companyName),
                    subtitle: Text(
                      '${app.roleTitle} · ${app.daysSinceApplied} days ago',
                    ),
                    trailing: Chip(label: Text(app.status.name)),
                    onTap: () {
                      context.push('detail${app.id}', extra: app);
                    },
                  );
                },
              );
            case Error(failure: final failure):
              return Center(child: Text('Error: ${failure.message}'));
          }
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
