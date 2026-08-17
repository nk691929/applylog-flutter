import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:applylog/features/applications/presentation/screens/add_application_screen.dart';
import 'package:applylog/features/applications/presentation/screens/application_detail_screen.dart';
import 'package:applylog/features/applications/presentation/screens/application_list_screen.dart';
import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:applylog/features/auth/presentation/screens/auth_screen.dart';
import 'package:applylog/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:applylog/features/settings/presentation/screens/settings_screen.dart';
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
        path: '/add',
        builder: (context, state) => const AddApplicationScreen(),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final app = state.extra as Application;
          return ApplicationDetailScreen(application: app);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (value) => navigationShell.goBranch(value),
              items: const [
                BottomNavigationBarItem(
                  label: "Dashboard",
                  icon: Icon(Icons.dashboard),
                ),
                BottomNavigationBarItem(
                  label: "Applications",
                  icon: Icon(Icons.settings_applications),
                ),
                BottomNavigationBarItem(
                  label: "Settings",
                  icon: Icon(Icons.settings),
                ),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/",
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/applications",
                builder: (context, state) => const ApplicationListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/settings",
                builder: ((context, state) => const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
