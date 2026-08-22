import 'dart:async';

import 'package:applylog/core/errors/result.dart';
import 'package:applylog/core/utils/status_color.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:applylog/features/applications/presentation/providers/filtered_application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApplicationListScreen extends ConsumerStatefulWidget {
  const ApplicationListScreen({super.key});

  @override
  ConsumerState<ApplicationListScreen> createState() =>
      _ApplicationListScreenState();
}

class _ApplicationListScreenState
    extends ConsumerState<ApplicationListScreen> {
  Timer? _searchDebounce;
  final _searchController = TextEditingController();

  void _onSearchedChange(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        ref.read(searchQueryProvider.notifier).state =
            value.trim().toLowerCase();
      },
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();

    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(fiteredApplicationProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              'Track your career journey',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),       
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Application'),
      ),
      body: applicationsAsync.when(
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(
          message: error.toString(),
        ),
        data: (applications) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(fiteredApplicationProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    applications.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSearchField(
                    context,
                    query,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildStatusFilters(
                    context,
                    selectedStatus,
                  ),
                ),
                if (applications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      hasSearch: query.isNotEmpty,
                      selectedStatus: selectedStatus,
                      onClearFilters: _clearFilters,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      100,
                    ),
                    sliver: SliverList.builder(
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final application = applications[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ApplicationCard(
                            application: application,
                            onTap: () {
                              context.push(
                                '/detail/${application.id}',
                                extra: application,
                              );
                            },
                            onDelete: () {
                              _confirmDelete(application);
                            },
                            onStatusChanged: (status) {
                              _updateStatus(
                                application.id,
                                status,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int applicationCount,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$applicationCount '
                  '${applicationCount == 1 ? 'application' : 'applications'}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay organized and keep moving forward.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    String query,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchedChange,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search company or role...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(
    BuildContext context,
    ApplicationStatus? selectedStatus,
  ) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatusFilterChip(
            label: 'All',
            icon: Icons.apps_outlined,
            selected: selectedStatus == null,
            onSelected: () {
              ref.read(selectedStatusProvider.notifier).state = null;
            },
          ),
          ...ApplicationStatus.values.map(
            (status) {
              return _StatusFilterChip(
                label: _statusLabel(status),
                selected: selectedStatus == status,
                color: statusColor(status),
                onSelected: () {
                  ref.read(selectedStatusProvider.notifier).state = status;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _clearSearch();
    ref.read(selectedStatusProvider.notifier).state = null;
  }

  Future<void> _updateStatus(
    String id,
    ApplicationStatus status,
  ) async {
    final result = await ref
        .read(applicationRepositoryProvider)
        .updateStatus(id, status);

    if (!mounted) return;

    if (result case Error(failure: final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    Application application,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          icon: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.error,
          ),
          title: const Text('Delete application?'),
          content: Text(
            'This will permanently remove the application '
            'to ${application.companyName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => dialogContext.pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final result = await ref
        .read(applicationRepositoryProvider)
        .deleteApplication(application.id);

    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      case Error(failure: final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete application: ${failure.message}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Screening';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offer:
        return 'Offer';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<ApplicationStatus> onStatusChanged;

  const _ApplicationCard({
    required this.application,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = application.status;
    final statusColorValue = statusColor(status);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompanyAvatar(
                    companyName: application.companyName,
                    color: statusColorValue,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.roleTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ApplicationMenu(
                    application: application,
                    onDelete: onDelete,
                    onStatusChanged: onStatusChanged,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(application.dateApplied),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _StatusBadge(
                    status: status,
                    color: statusColorValue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String companyName;
  final Color color;

  const _CompanyAvatar({
    required this.companyName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final initial = companyName.trim().isEmpty
        ? '?'
        : companyName.trim()[0].toUpperCase();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _statusLabel(status),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Screening';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offer:
        return 'Offer';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final IconData? icon;
  final VoidCallback onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onSelected(),
        avatar: icon != null
            ? Icon(
                icon,
                size: 17,
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              )
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
        label: Text(label),
        showCheckmark: false,
      ),
    );
  }
}

class _ApplicationMenu extends StatelessWidget {
  final Application application;
  final VoidCallback onDelete;
  final ValueChanged<ApplicationStatus> onStatusChanged;

  const _ApplicationMenu({
    required this.application,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Object>(
      tooltip: 'More options',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value is ApplicationStatus) {
          onStatusChanged(value);
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<Object>(
            enabled: false,
            child: Text(
              'Change status',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ...ApplicationStatus.values.map(
            (status) {
              return PopupMenuItem<Object>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_statusLabel(status)),
                  ],
                ),
              );
            },
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<Object>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 12),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Screening';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offer:
        return 'Offer';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final ApplicationStatus? selectedStatus;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasSearch,
    required this.selectedStatus,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasFilter = hasSearch || selectedStatus != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter
                    ? Icons.search_off_outlined
                    : Icons.work_outline,
                size: 36,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter
                  ? 'No applications found'
                  : 'No applications yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try another search or change your filters.'
                  : 'Start tracking your job applications today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}