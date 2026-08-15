import 'package:applylog/core/errors/result.dart';
import 'package:applylog/core/notifications/prsentations/providers/notification_provider.dart';
import 'package:applylog/core/notifications/prsentations/providers/schedule_follow_up_provider.dart';
import 'package:applylog/core/notifications/utils/notification_id.dart';
import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/providers/application_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddApplicationScreen extends ConsumerStatefulWidget {
  const AddApplicationScreen({super.key});

  @override
  ConsumerState<AddApplicationScreen> createState() =>
      _AddApplicationScreenState();
}

class _AddApplicationScreenState extends ConsumerState<AddApplicationScreen> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  ApplicationStatus _state = ApplicationStatus.applied;
  DateTime? _followUpDate;
  TimeOfDay? _followUpTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final followUpDateTime = _buildFollowUpDateTime();
    if ((_followUpDate != null && _followUpTime == null) ||
        (_followUpDate == null && _followUpTime != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both follow-up date and time.'),
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final application = Application(
      id: '',
      companyName: _companyController.text.trim(),
      roleTitle: _roleController.text.trim(),
      status: _state,
      dateApplied: DateTime.now(),
      followUpDate: followUpDateTime,
    );

    final result = await ref
        .read(applicationRepositoryProvider)
        .addApplication(application);
    switch (result) {
      case Success(data: final applicationId):
        if (application.followUpDate != null) {
          try {
            final granted = await ref
                .read(notificationRepositoryProvider)
                .requestPermission();
            if (granted) {
              await ref.read(scheduleFollowUpProvider)(
                companyName: application.companyName,
                id: notificationIdFromApplicationId(applicationId),
                scheduledDate: application.followUpDate!,
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notification permission denied — reminder not set.',
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Application saved, but the reminder could not be scheduled.',
                  ),
                ),
              );
            }
          }
        }
        if (!mounted) return;
        context.pop();
      case Error(failure: final failure):
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Application')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _companyController,
              decoration: InputDecoration(labelText: "Company"),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: "Role"),
            ),
            DropdownButton<ApplicationStatus>(
              value: _state,
              items: ApplicationStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (val) => setState(() {
                _state = val!;
              }),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFollowUpDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _followUpDate == null
                          ? 'Pick date'
                          : '${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFollowUpTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _followUpTime == null
                          ? 'Pick time'
                          : _followUpTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            if (_followUpDate != null && _followUpTime != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _followUpDate = null;
                    _followUpTime = null;
                  }),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Remove reminder'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _isSaving
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _save, child: const Text('Add')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: now,
      initialDate: _followUpDate ?? now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (!mounted || selectedDate == null) return;
    setState(() => _followUpDate = selectedDate);
  }

  Future<void> _pickFollowUpTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _followUpTime ?? TimeOfDay.now(),
    );

    if (!mounted || selectedTime == null) return;
    setState(() => _followUpTime = selectedTime);
  }

  DateTime? _buildFollowUpDateTime() {
    if (_followUpDate == null || _followUpTime == null) {
      return null;
    }
    return DateTime(
      _followUpDate!.year,
      _followUpDate!.month,
      _followUpDate!.day,
      _followUpTime!.hour,
      _followUpTime!.minute,
    );
  }
}
