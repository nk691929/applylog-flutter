import 'package:applylog/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: dashboardAsync.when(
        data: (stats) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: "Total Applications",
                        value: "${stats.total}",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _StatCard(
                        label: "Response Rate",
                        value: stats.responseRate.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "By Status",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...stats.byStatus.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(width: 100, child: Text(entry.key.name)),
                        Expanded(
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: stats.total == 0
                                ? 0
                                : entry.value / stats.total,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${entry.value}'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
        error: (error, _) => Center(child: Text("'Error: $error")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
