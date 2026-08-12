import 'package:applylog/core/errors/result.dart';
import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.watch(authRepositoryProvider);
    final result = _isSignUp
        ? await repo.signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          )
        : await repo.signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

    switch (result) {
      case Success():
        if (!mounted) return;
        context.go('/');
        break;
      case Error(failure: final failure):
        setState(() {
          _errorMessage = failure.message;
        });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'SignUp' : 'SignIn')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hint: Text("email")),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isSignUp ? 'SignUp' : 'SignIn'),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Login'
                    : 'New here? SignUp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
