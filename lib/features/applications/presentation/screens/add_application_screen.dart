import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:applylog/core/utils/date_formatter.dart';

class AddApplicationScreen extends ConsumerStatefulWidget {
  final Application? application;
  const AddApplicationScreen({super.key, this.application});

  bool get isEditMode => application != null;
  @override
  ConsumerState<AddApplicationScreen> createState() =>
      _AddApplicationScreenState();
}

class _AddApplicationScreenState extends ConsumerState<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();

  ApplicationStatus _status = ApplicationStatus.applied;
  DateTime _dateApplied = DateTime.now();
  DateTime? _followUpDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final application = widget.application;

    if (application == null) return;

    _companyController.text = application.companyName;
    _roleController.text = application.roleTitle;
    _sourceController.text = application.source ?? '';
    _notesController.text = application.notes ?? '';

    _status = application.status;
    _dateApplied = application.dateApplied;
    _followUpDate = application.followUpDate;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateApplied() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateApplied,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _dateApplied = selectedDate;

      if (_followUpDate != null && _followUpDate!.isBefore(_dateApplied)) {
        _followUpDate = null;
      }
    });
  }

  Future<void> _selectFollowUpDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: _dateApplied,
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _followUpDate = selectedDate;
    });
  }

  void _clearFollowUpDate() {
    setState(() {
      _followUpDate = null;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final existingApplication = widget.application;

    final application = Application(
      id: existingApplication?.id ?? '',
      companyName: _companyController.text.trim(),
      roleTitle: _roleController.text.trim(),
      status: _status,
      dateApplied: _dateApplied,
      source: _sourceController.text.trim().isEmpty
          ? null
          : _sourceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      followUpDate: _followUpDate,
    );

    final repository = ref.read(applicationRepositoryProvider);

    final Result<void> result;

    if (widget.isEditMode) {
      result = await repository.updateApplication(application);
    } else {
      result = await repository.addApplication(application);
    }

    if (!mounted) return;

    switch (result) {
      case Success():
        context.pop();

      case Error(failure: final failure):
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(failure.message),
          ),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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

  IconData _statusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Icons.send_outlined;
      case ApplicationStatus.screening:
        return Icons.visibility_outlined;
      case ApplicationStatus.interview:
        return Icons.groups_outlined;
      case ApplicationStatus.offer:
        return Icons.celebration_outlined;
      case ApplicationStatus.rejected:
        return Icons.close_outlined;
      case ApplicationStatus.withdrawn:
        return Icons.undo_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Application' : 'Add Application',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  context,
                  'Application details',
                  'Tell us where you applied.',
                ),

                const SizedBox(height: 16),

                _buildCompanyField(context),

                const SizedBox(height: 16),

                _buildRoleField(context),

                const SizedBox(height: 16),

                _buildStatusField(context),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  context,
                  'Application timeline',
                  'Keep track of important dates.',
                ),

                const SizedBox(height: 16),

                _buildDateField(
                  context: context,
                  label: 'Date Applied',
                  value: _dateApplied.toReadableDateTime(),
                  icon: Icons.calendar_today,
                  onTap: _selectDateApplied,
                ),

                const SizedBox(height: 12),

                _buildFollowUpField(context),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  context,
                  'Additional information',
                  'Optional details that help you stay organized.',
                ),

                const SizedBox(height: 16),

                _buildSourceField(context),

                const SizedBox(height: 16),

                _buildNotesField(context),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : widget.isEditMode
                          ? 'Save Changes'
                          : 'Add Application',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    widget.isEditMode
                        ? 'Your changes will be saved to this application.'
                        : 'You can update the application later.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.isEditMode
                  ? Icons.edit_outlined
                  : Icons.work_outline_rounded,
              color: colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode
                      ? 'Update your opportunity'
                      : 'Track a new opportunity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEditMode
                      ? 'Keep your application information up to date.'
                      : 'Keep your job search organized.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyField(BuildContext context) {
    return TextFormField(
      controller: _companyController,
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
      decoration: _inputDecoration(
        context,
        label: 'Company',
        hint: 'e.g. Google',
        icon: Icons.business_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the company name';
        }

        if (value.trim().length < 2) {
          return 'Company name is too short';
        }

        return null;
      },
    );
  }

  Widget _buildRoleField(BuildContext context) {
    return TextFormField(
      controller: _roleController,
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
      decoration: _inputDecoration(
        context,
        label: 'Role',
        hint: 'e.g. Flutter Developer',
        icon: Icons.work_outline,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the role title';
        }

        if (value.trim().length < 2) {
          return 'Role title is too short';
        }

        return null;
      },
    );
  }

  Widget _buildStatusField(BuildContext context) {
    return DropdownButtonFormField<ApplicationStatus>(
      initialValue: _status,
      decoration: _inputDecoration(
        context,
        label: 'Application status',
        icon: Icons.flag_outlined,
      ),
      items: ApplicationStatus.values.map((status) {
        return DropdownMenuItem<ApplicationStatus>(
          value: status,
          child: Row(
            children: [
              Icon(_statusIcon(status), size: 20),
              const SizedBox(width: 12),
              Text(_statusLabel(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _status = value;
        });
      },
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: _inputDecoration(context, label: label, icon: icon),
        child: Row(
          children: [
            Expanded(
              child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpField(BuildContext context) {
    final theme = Theme.of(context);

    if (_followUpDate == null) {
      return _buildDateField(
        context: context,
        label: 'Follow-up date',
        value: 'Set a reminder',
        icon: Icons.notifications_none_outlined,
        onTap: _selectFollowUpDate,
      );
    }

    return InputDecorator(
      decoration: _inputDecoration(
        context,
        label: 'Follow-up date',
        icon: Icons.notifications_active_outlined,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDate(_followUpDate!),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            tooltip: 'Remove follow-up date',
            onPressed: _clearFollowUpDate,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceField(BuildContext context) {
    return TextFormField(
      controller: _sourceController,
      textCapitalization: TextCapitalization.words,
      maxLength: 50,
      decoration: _inputDecoration(
        context,
        label: 'Source',
        hint: 'e.g. LinkedIn, Indeed, Referral',
        icon: Icons.link_outlined,
      ),
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return TextFormField(
      controller: _notesController,
      textCapitalization: TextCapitalization.sentences,
      maxLength: 1000,
      maxLines: 5,
      minLines: 4,
      decoration: _inputDecoration(
        context,
        label: 'Notes',
        hint: 'Add interview details, recruiter information, etc.',
        icon: Icons.notes_outlined,
        alignLabelWithHint: true,
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }
}
