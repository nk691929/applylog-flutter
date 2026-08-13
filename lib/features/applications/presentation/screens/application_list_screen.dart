import 'dart:async';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:applylog/features/applications/presentation/providers/filtered_application_provider.dart';

import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:applylog/core/errors/result.dart';
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
  Timer? _searchDebounce;
  final _searchController = TextEditingController();

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

  void _onSearchedChange(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).state = value.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(fiteredApplicationProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);
    final query = ref.watch(searchQueryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: _onSearchedChange,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search applications...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchDebounce?.cancel();
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        icon: Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
          _buildStatusFilter(),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (applications) {
                if (applications.isEmpty) {
                  return Center(
                    child: Text(
                      selectedStatus != null
                          ? 'No applications in ${selectedStatus.name} status.'
                          : 'No applications yet. Tap + to add one.',
                    ),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Deltete Application',
                            onPressed: () => _confirmDelete(app),
                            icon: Icon(Icons.delete),
                          ),
                          PopupMenuButton<ApplicationStatus>(
                            initialValue: app.status,
                            onSelected: (newStatus) async {
                              final result = await ref
                                  .read(applicationRepositoryProvider)
                                  .updateApplicationStatus(app.id, newStatus);
                              if (!mounted) return;
                              if (result case Error(failure: final failure)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(failure.message)),
                                );
                              }
                            },
                            itemBuilder: (context) => ApplicationStatus.values
                                .map(
                                  (s) => PopupMenuItem(
                                    value: s,
                                    child: Chip(label: Text(s.name)),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      onTap: () =>
                          context.push('/detail/${app.id}', extra: app),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Application application) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Application'),
          content: Text(
            "Do you want to delete your application to ${application.companyName} fro ${application.roleTitle}",
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true && !mounted) return;
    await _deleteApplication(application.id);
  }

  Future<void> _deleteApplication(String id) async {
    final result = await ref
        .read(applicationRepositoryProvider)
        .deleteApplication(id);
    if (!mounted) return;
    switch (result) {
      case Success():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Application deleted.')));
      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete application: ${failure.message}'),
          ),
        );
    }
  }

  //Filter Status Widget
  Widget _buildStatusFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: 'All',
            selected: ref.watch(selectedStatusProvider) == null,
            onSelected: () => {
              ref.read(selectedStatusProvider.notifier).state = null,
            },
          ),
          ...ApplicationStatus.values.map(
            (s) => _buildFilterChip(
              label: s.name,
              selected: ref.watch(selectedStatusProvider) == s,
              onSelected: () {
                ref.read(selectedStatusProvider.notifier).state = s;
              },
            ),
          ),
        ],
      ),
    );
  }

  //Filter Chips for status
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
