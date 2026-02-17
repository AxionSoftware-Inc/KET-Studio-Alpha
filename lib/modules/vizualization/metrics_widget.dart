import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/viz_service.dart';
import '../../core/theme/ket_theme.dart';

class MetricsSidebarWidget extends StatelessWidget {
  const MetricsSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VizService(),
      builder: (context, _) {
        final service = VizService();
        final currentSession = service.currentSession;
        
        VizEvent? metricsEvent;
        if (currentSession != null) {
          try {
            metricsEvent = currentSession.events.lastWhere(
              (e) => e.type == VizType.metrics,
            );
          } catch (_) {}
        }

        if (metricsEvent == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FluentIcons.analytics_report,
                  size: 40,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  "No metrics available",
                  style: TextStyle(color: KetTheme.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  "Run a job to see execution stats here.",
                  style: TextStyle(color: KetTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          );
        }

        final data = metricsEvent.payload;
        if (data is! Map) return const Center(child: Text("Invalid metrics data"));
        final map = data as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SESSION ${currentSession?.id.replaceFirst('v_', '')}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: KetTheme.accent,
                ),
              ),
              const SizedBox(height: 16),
              ...map.entries.map((e) => _buildMetricRow(e.key, e.value.toString())),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildModernSummary(map),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              color: KetTheme.textMuted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
        ],
      ),
    );
  }

  Widget _buildModernSummary(Map<String, dynamic> data) {
    // A nice visual summary for the bottom
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KetTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KetTheme.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.completed, color: KetTheme.accent, size: 16),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Job completed with high fidelity.",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
