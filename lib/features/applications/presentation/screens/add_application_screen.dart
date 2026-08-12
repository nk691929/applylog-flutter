import 'package:applylog/core/errors/result.dart';
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
  bool _isSaving = false;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    final application = Application(
      id: '',
      companyName: _companyController.text.trim(),
      roleTitle: _roleController.text.trim(),
      status: _state,
      dateApplied: DateTime.now(),
    );

    final result = await ref
        .read(applicationRepositoryProvider)
        .addApplication(application);

    if (!mounted) return;
    switch (result) {
      case Success():
        context.pop();
      case Error(failure: final failure):
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
              decoration: InputDecoration(hintText: "Company"),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(hintText: "Role"),
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
            const SizedBox(height: 20),
            _isSaving
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _save, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
