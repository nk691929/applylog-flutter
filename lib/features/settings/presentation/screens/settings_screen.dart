import 'package:applylog/core/theme/theme_provider.dart';
import 'package:applylog/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SettingsHeader(
            icon: Icons.settings_outlined,
            title: 'Preferences',
            subtitle: 'Customize your ApplyLog experience',
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: 'Appearance'),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: _IconContainer(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isDarkMode ? 'Dark theme is enabled' : 'Light theme is enabled',
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (_) {
                  ref.read(themeProvider.notifier).toggle();
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: 'Session'),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: _IconContainer(
                icon: Icons.logout_outlined,
                backgroundColor: colorScheme.errorContainer,
                iconColor: colorScheme.onErrorContainer,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Sign out of your ApplyLog account'),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),

          //This section will be removed after working notification
          // const SizedBox(height: 24),
          // _SectionTitle(title: 'Test Notification'),

          // const SizedBox(height: 8),

          // Card(
          //   child: ListTile(
          //     leading: const Icon(Icons.notifications_active),
          //     title: const Text('Test Notification (10 Seconds)'),
          //     onTap: () async {
          //       final granted = await ref
          //           .read(notificationRepositoryProvider)
          //           .requestPermission();
          //       if (!granted) {
          //         if (context.mounted) {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             const SnackBar(content: Text('Permission not granted')),
          //           );
          //         }
          //         return;
          //       }
          //       final time = DateTime.now().add(const Duration(seconds: 10));
          //       await ref.read(scheduleFollowUpProvider)(
          //         id: 999999,
          //         companyName: 'Test Company',
          //         scheduledDate: time,
          //       );
          //       if (context.mounted) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text(
          //               'Test notification scheduled for 10 seconds from now ${time.minute}:${time.second}',
          //             ),
          //           ),
          //         );
          //       }
          //     },
          //   ),
          // ),

          //Ending
          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Text(
                  'ApplyLog',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your application tracking companion',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    await ref.read(authRepositoryProvider).signOut();
  }
}

class _SettingsHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingsHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const _IconContainer({
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor ?? colorScheme.onSurfaceVariant),
    );
  }
}
