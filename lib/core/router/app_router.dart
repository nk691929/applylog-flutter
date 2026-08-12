import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/screens/add_application_screen.dart';
import 'package:applylog/features/applications/presentation/screens/application_list_screen.dart';
import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:applylog/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value ?? false;
      final isOnAuthScreen = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isOnAuthScreen) return '/auth';
      if (isLoggedIn && isOnAuthScreen) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const ApplicationListScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddApplicationScreen(),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final app = state.extra as Application;
          return Scaffold(
            appBar: AppBar(title: Text(app.companyName)),
            body: Center(child: Text('${app.roleTitle} — ${app.status.name}')),
          );
        },
      ),
    ],
  );
});
