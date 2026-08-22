import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final Application application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  Application get app => widget.application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Application',
            onPressed: () {
              context.push(
                '/edit/${app.id}',
                extra: app,
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete Application',
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 24),
              _buildApplicationOverview(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 16),
              _buildAdditionalInformation(
                context,
                theme,
                colorScheme,
              ),
              if (app.notes != null && app.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNotes(
                  context,
                  theme,
                  colorScheme,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanyAvatar(
                companyName: app.companyName,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.companyName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.roleTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _StatusBadge(
            status: app.status,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationOverview(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return _SectionCard(
      title: 'Application Overview',
      icon: Icons.work_outline,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Applied',
            value: _formatDateTime(app.dateApplied),
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.timelapse_outlined,
            label: 'Time since applied',
            value: _daysSinceAppliedText(),
          ),
          if (app.followUpDate != null) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.notifications_none_outlined,
              label: 'Follow-up',
              value: _formatDateTime(app.followUpDate!),
              valueColor: _isFollowUpOverdue()
                  ? colorScheme.error
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalInformation(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (app.source == null || app.source!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: 'Additional Information',
      icon: Icons.info_outline,
      child: _InfoRow(
        icon: Icons.source_outlined,
        label: 'Source',
        value: app.source!,
      ),
    );
  }

  Widget _buildNotes(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return _SectionCard(
      title: 'Notes',
      icon: Icons.notes_outlined,
      child: Text(
        app.notes!,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete application?'),
          content: Text(
            'This will permanently remove your application '
            'to ${app.companyName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
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

    // Keep your existing delete repository logic here.
    final result = await ref
        .read(applicationRepositoryProvider)
        .deleteApplication(app.id);

    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();

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

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;

    final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final minute = localDate.minute.toString().padLeft(2, '0');
    final period = localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  String _daysSinceAppliedText() {
    final days = app.daysSinceApplied;

    if (days == 0) {
      return 'Today';
    }

    if (days == 1) {
      return '1 day ago';
    }

    return '$days days ago';
  }

  bool _isFollowUpOverdue() {
    final followUpDate = app.followUpDate;

    if (followUpDate == null) {
      return false;
    }

    return followUpDate.isBefore(DateTime.now());
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String companyName;
  final ColorScheme colorScheme;

  const _CompanyAvatar({
    required this.companyName,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final initial = companyName.trim().isEmpty
        ? '?'
        : companyName.trim()[0].toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final ColorScheme colorScheme;

  const _StatusBadge({
    required this.status,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _statusLabel(status),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Colors.blue;
      case ApplicationStatus.screening:
        return Colors.orange;
      case ApplicationStatus.interview:
        return Colors.deepPurple;
      case ApplicationStatus.offer:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
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