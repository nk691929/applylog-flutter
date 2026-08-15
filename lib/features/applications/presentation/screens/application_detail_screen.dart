import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final Application application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    return Scaffold(
      appBar: AppBar(
        title: Text(app.companyName),
        actions: [
          IconButton(
            tooltip: "Delete Application",
            onPressed: () {
              final result = ref
                  .read(applicationRepositoryProvider)
                  .deleteApplication(app.id);
              if (!mounted) return;
              if (result case Success()) context.pop();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.roleTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Chip(label: Text(app.status.name)),
            const SizedBox(height: 16),
            Text('Applied: ${app.dateApplied.toLocal()}'.split('.').first),
            Text('${app.daysSinceApplied} days ago'),
            if (app.source != null) ...[
              const SizedBox(height: 8),
              Text('Source: ${app.source}'),
            ],
            if (app.followUpDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Follow-up: ${app.followUpDate!.toLocal()}'.split('.').first,
              ),
            ],
            if (app.notes != null && app.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(app.notes!),
            ],
          ],
        ),
      ),
    );
  }
}
