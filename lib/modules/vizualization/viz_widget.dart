import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/viz_service.dart';
import '../../core/theme/ket_theme.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'inspector_widget.dart';

/// VIZUALIZATION PERFORMANCE & STABILITY DOCS:
/// 
/// 1. UI FREEZE GUARD (MATRIX): High-dimension matrices (e.g. 1024x1024) are NOT rendered as Widgets.
///    Instead, we use [CustomPainter] and strict dimension limits (128x128).
///    This prevents the UI thread from being overwhelmed by object allocations.
/// 
/// 2. LAZY DECODING: JSON data from Python is decoded in small batches (5 msgs/60ms) 
///    in [ExecutionService] to avoid blocking the main thread during execution.
/// 
/// 3. REPAINT BOUNDARY: Each Viz card is wrapped in a [RepaintBoundary] so that
///    scrolling doesn't trigger expensive rebuilds of complex charts/matrices.
/// 
class VizualizationWidget extends StatefulWidget {
  const VizualizationWidget({super.key});

  @override
  State<VizualizationWidget> createState() => _VizualizationWidgetState();
}

class _VizualizationWidgetState extends State<VizualizationWidget> {
  DateTime? _runStartTime;
  bool _showNoOutputHint = false;
  Timer? _hintTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    VizService().addListener(_refresh);
  }

  @override
  void dispose() {
    VizService().removeListener(_refresh);
    _hintTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    final service = VizService();
    
    if (service.status == VizStatus.running) {
      if (_runStartTime == null) {
        _runStartTime = DateTime.now();
        _showNoOutputHint = false;
        _hintTimer?.cancel();
        _hintTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && VizService().status == VizStatus.running && VizService().selectedEvent == null) {
            setState(() => _showNoOutputHint = true);
          }
        });
      }
    } else {
      _runStartTime = null;
      _showNoOutputHint = false;
      _hintTimer?.cancel();
    }

    // Auto-scroll logic safely - Only if at bottom or new session
    if (service.selectedEvent == null && _scrollController.hasClients) {
      if (!_isScrollingThrottled) {
        _isScrollingThrottled = true;
        Future.delayed(const Duration(milliseconds: 250), () {
          _isScrollingThrottled = false;
          if (mounted && _scrollController.hasClients) {
            final pos = _scrollController.position.maxScrollExtent;
            if ((_scrollController.offset - pos).abs() < 500) { // Only auto-scroll if close to bottom
               _scrollController.animateTo(
                pos,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          }
        });
      }
    }

    setState(() {});
  }

  bool _isScrollingThrottled = false;

  @override
  Widget build(BuildContext context) {
    final service = VizService();
    final status = service.status;

    return Expanded(
      child: _buildMainContent(service, status),
    );
  }

  Widget _buildMainContent(VizService service, VizStatus status) {
    if (service.selectedEvent != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: _buildVizCard(service.selectedEvent!, isSingle: true))),
            const SizedBox(height: 12),
            Button(
              child: const Text("Back to Stream"),
              onPressed: () => service.selectEvent(null),
            ),
          ],
        ),
      );
    }

    final currentSession = service.currentSession;
    if (currentSession == null || currentSession.events.isEmpty) {
      if (status == VizStatus.running) return _buildRunningState();
      return _buildIdleState();
    }

    final events = currentSession.events;
    
    // Tushuntirish: Hammasini bittada ko'rsatib "tizib" yubormaslik uchun,
    // har bir turdagi eng oxirgi eventni olamiz. 
    // Bu orqali VQE charti bitta joyda "o'ynaydi" (animatsiya bo'ladi).
    final Map<VizType, VizEvent> latestEvents = {};
    for (var e in events) {
      if (e.type != VizType.inspector && e.type != VizType.text && e.type != VizType.error) {
        latestEvents[e.type] = e;
      }
    }

    final displayList = latestEvents.values.toList();

    if (displayList.isEmpty) {
      return _buildIdleState(message: "No live visualizations in current session.");
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: displayList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _buildVizCard(displayList[i]),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child, double? height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: KetTheme.bgActivityBar,
          child: Row(
            children: [
              Icon(icon, size: 12, color: KetTheme.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: height,
          constraints: height == null ? const BoxConstraints(minHeight: 100) : null,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(VizEvent event) {
    return HoverButton(
      onPressed: () => VizService().selectEvent(event),
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: states.isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          child: Row(
            children: [
              Icon(_getIconForType(event.type), size: 12, color: KetTheme.accent),
              const SizedBox(width: 12),
              Text(event.type.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(event.timeStr, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVizCard(VizEvent event, {bool isSingle = false}) {
    return RepaintBoundary(
      key: ValueKey(event.timestamp.millisecondsSinceEpoch),
      child: Container(
        decoration: BoxDecoration(
          color: KetTheme.bgHeader.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(_getIconForType(event.type), size: 12, color: KetTheme.accent),
                  const SizedBox(width: 8),
                  Text(
                    event.type.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(event.timeStr, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildVizContent(event, isSingle: isSingle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVizContent(VizEvent event, {bool isSingle = false}) {
    final payload = event.payload;
    
    // PERFORMANCE WARNING: The following components (Inspector and Matrix) are high-load.
    // If UI freezes occur, verify the data size guards within these widgets.
    switch (event.type) {
      case VizType.inspector:
        /// PERFORMANCE GUARD:
        /// 'InspectorWidget' ichida 'Expanded' ishlatilgan. Agar u 'ListView' ichida 
        /// balandligi belgilanmasdan kelsa, Flutter UI'ni muzlatib qo'yadi (Layout freeze).
        /// Shuning uchun, ro'yxatda (isSingle=false) aniq balandlik beramiz.
        if (isSingle) {
          return InspectorWidget(payload: payload);
        } else {
          return SizedBox(height: 450, child: InspectorWidget(payload: payload));
        }
        
      case VizType.matrix:
      case VizType.heatmap:
        return _MatrixHeatmap(
          data: (payload is Map && payload.containsKey('data')) ? payload['data'] : payload,
          title: (payload is Map && payload.containsKey('title')) ? payload['title'].toString() : null,
        );

      case VizType.dashboard:
        return _QuantumDashboard(data: payload);

      case VizType.image:
      case VizType.circuit:
        return _ImageDisplay(
          path: payload is Map ? (payload['path'] ?? "").toString() : payload.toString(),
          title: payload is Map ? (payload['title'] ?? "").toString() : null,
          isSingle: isSingle,
        );

      case VizType.table:
        return _TableDisplay(data: payload);

      case VizType.text:
        return _TextDisplay(data: payload);
        
      case VizType.error:
        return _ErrorDisplay(error: payload.toString());

      case VizType.bloch:
        return SizedBox(height: 250, child: _BlochSpherePainter(data: payload));
        
      case VizType.chart:
        return SizedBox(height: 200, child: _SimpleChart(data: payload));

      default:
        return Text("Visualization: ${event.type}");
    }
  }

  Widget _buildHeader(VizService service) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: KetTheme.bgHeader,
      child: Row(
        children: [
          const Icon(FluentIcons.view_dashboard, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text("VISUALIZER", style: KetTheme.headerStyle),
          const Spacer(),
          IconButton(
            icon: const Icon(FluentIcons.delete, size: 12),
            onPressed: () => service.clear(),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(VizType type) {
    switch (type) {
      case VizType.bloch:
        return FluentIcons.product;
      case VizType.dashboard:
        return FluentIcons.iot;
      case VizType.matrix:
        return FluentIcons.table_group;
      case VizType.table:
        return FluentIcons.list;
      case VizType.inspector:
        return FluentIcons.processing_run;
      default:
        return FluentIcons.info;
    }
  }

  Widget _buildIdleState({String? message}) {
    return Center(
      child: Text(
        message ?? "Run a script to see results here.",
        style: TextStyle(color: KetTheme.textMuted),
      ),
    );
  }

  Widget _buildRunningState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProgressRing(),
          const SizedBox(height: 16),
          Text(
            _showNoOutputHint
                ? "Running... (no visual output yet)"
                : "Capturing quantum data...",
            style: TextStyle(color: KetTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return _ErrorDisplay(error: error);
  }
}

class _QuantumDashboard extends StatelessWidget {
  final dynamic data;
  const _QuantumDashboard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hist = data?['histogram'];
    final matrix = data?['matrix'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hist != null) ...[
          const _SubHeader(title: "HISTOGRAM"),
          const SizedBox(height: 8),
          SizedBox(height: 120, child: _HistogramChart(data: hist)),
          const SizedBox(height: 12),
        ],
        if (matrix != null) ...[
          const _SubHeader(title: "DENSITY MATRIX"),
          const SizedBox(height: 8),
          _MatrixHeatmap(data: matrix),
        ],
      ],
    );
  }
}

class _MatrixHeatmap extends StatelessWidget {
  final dynamic data;
  final String? title;
  const _MatrixHeatmap({required this.data, this.title});

  @override
  Widget build(BuildContext context) {
    int rows = 0;
    int cols = 0;

    if (data is List) {
      rows = (data as List).length;
      cols = rows > 0 ? (data[0] as List).length : 0;
    } else if (data is Map) {
      final map = data as Map;
      int maxIdx = -1;
      for (var k in map.keys) {
        final s = k.toString();
        final p = s.indexOf(',');
        if (p != -1) {
          final r = int.tryParse(s.substring(0, p)) ?? 0;
          final c = int.tryParse(s.substring(p + 1)) ?? 0;
          maxIdx = math.max(maxIdx, math.max(r, c));
        }
      }
      rows = cols = maxIdx + 1;
    }

    if (rows == 0) return const Text("No matrix data", style: TextStyle(fontSize: 10, color: Colors.grey));
    
    // Safety Guard: Don't render extremely large matrices inline
    if (rows > 128 || cols > 128) {
      return Text("Matrix too large for inline view (${rows}x${cols})", style: TextStyle(fontSize: 10, color: Colors.orange));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          _SubHeader(title: title!.toUpperCase()),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            double w = constraints.maxWidth;
            if (w > 400) w = 400; 
            return SizedBox(
              width: w,
              height: w * (rows / cols),
              child: CustomPaint(
                painter: _MatrixPainter(data: data, rows: rows, cols: cols, accentColor: KetTheme.accent),
              ),
            );
          }
        ),
      ],
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final dynamic data;
  final int rows;
  final int cols;
  final Color accentColor;

  _MatrixPainter({required this.data, required this.rows, required this.cols, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    double cellW = size.width / cols;
    double cellH = size.height / rows;
    final bgPaint = Paint()..color = const Color(0xFF1A1A1A);
    final paint = Paint();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        double val = 0;
        try {
          if (data is List) {
            val = (data[r][c] as num).toDouble();
          } else {
            val = (data["$r,$c"] ?? 0.0).toDouble();
          }
        } catch (_) {}
        
        Rect rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH).deflate(0.3);
        canvas.drawRect(rect, bgPaint);
        if (val > 0) {
          paint.color = accentColor.withValues(alpha: val.clamp(0.0, 1.0));
          canvas.drawRect(rect, paint);
        }
      }
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeatBox extends StatelessWidget {
  final double value;
  const _HeatBox({required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: Color.lerp(
          const Color(0xFF1A1A1A),
          KetTheme.accent,
          value.clamp(0.0, 1.0),
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          value > 0.05 ? value.toStringAsFixed(1) : "",
          style: const TextStyle(fontSize: 7, color: Colors.white),
        ),
      ),
    );
  }
}

class _TableDisplay extends StatelessWidget {
  final dynamic data;
  const _TableDisplay({required this.data});
  @override
  Widget build(BuildContext context) {
    final title = data?['title'] ?? "Table";
    final rowsList = data?['rows'] as List? ?? [];
    
    // Guard: Prevent massive table builds
    if (rowsList.length > 100) {
       return Text("Table too large to display (${rowsList.length} rows)", style: TextStyle(fontSize: 10, color: Colors.orange));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeader(title: title.toString().toUpperCase()),
        const SizedBox(height: 8),
        ...rowsList.map((row) {
          final cells = row as List;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
            child: Row(children: cells.map((c) => Expanded(child: Text(c.toString(), style: const TextStyle(fontSize: 11)))).toList()),
          );
        }),
      ],
    );
  }
}

class _BlochSpherePainter extends StatelessWidget {
  final dynamic data;
  const _BlochSpherePainter({required this.data});
  @override
  Widget build(BuildContext context) {
    double x = 0, y = 0, z = 0;
    if (data is Map) {
      if (data.containsKey('theta')) {
        double theta = (data['theta'] ?? 0.0).toDouble();
        double phi = (data['phi'] ?? 0.0).toDouble();
        x = math.sin(theta) * math.cos(phi);
        y = math.sin(theta) * math.sin(phi);
        z = math.cos(theta);
      } else {
        x = (data['x'] ?? 0.0).toDouble();
        y = (data['y'] ?? 0.0).toDouble();
        z = (data['z'] ?? 0.0).toDouble();
      }
    }
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: BlochPainter(x: x, y: y, z: z),
        ),
      ),
    );
  }
}

class _HistogramChart extends StatelessWidget {
  final dynamic data;
  const _HistogramChart({required this.data});
  @override
  Widget build(BuildContext context) {
    if (data is! Map) return const SizedBox();
    final map = data as Map;
    final keys = map.keys.toList();
    final values = map.values.map((v) => (v as num).toDouble()).toList();
    final maxVal = values.isEmpty ? 1.0 : values.reduce(math.max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(keys.length, (index) {
        final ratio = values[index] / (maxVal == 0 ? 1 : maxVal);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  values[index].toStringAsFixed(0),
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
                Container(
                  height: ratio * 80,
                  decoration: BoxDecoration(
                    color: KetTheme.accent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  keys[index].toString(),
                  style: const TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;
  const _SubHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      color: KetTheme.accent.withValues(alpha: 0.1),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: KetTheme.accent,
        ),
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String error;
  const _ErrorDisplay({required this.error});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D0000),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        error,
        style: const TextStyle(
          color: Color(0xFFFF9999),
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TextDisplay extends StatelessWidget {
  final dynamic data;
  const _TextDisplay({required this.data});
  @override
  Widget build(BuildContext context) {
    final t = data?['content'] ?? data.toString();
    return Text(
      t,
      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
    );
  }
}

class _ImageDisplay extends StatelessWidget {
  final String path;
  final String? title;
  final bool isSingle;
  const _ImageDisplay({required this.path, this.title, this.isSingle = false});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null)
          Text(title!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        SizedBox(
          height: isSingle ? null : 300,
          child: Image.file(
            File(path), 
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Text("Image not available"),
          ),
        ),
      ],
    );
  }
}

class _SimpleChart extends StatelessWidget {
  final dynamic data;
  const _SimpleChart({required this.data});
  @override
  Widget build(BuildContext context) {
    if (data is! List) return const SizedBox();
    if (data.length > 500) return const Text("Chart too large to display", style: TextStyle(fontSize: 10));
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: (data as List).map((p) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          height: (((p as num).toDouble()) * 180).clamp(2.0, 180.0),
          color: KetTheme.accent,
        ),
      )).toList(),
    );
  }
}

class BlochPainter extends CustomPainter {
  final double x, y, z;
  BlochPainter({required this.x, required this.y, required this.z});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(c.dx - r, c.dy),
      Offset(c.dx + r, c.dy),
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - r),
      Offset(c.dx, c.dy + r),
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );
    canvas.drawLine(
      c,
      Offset(c.dx + x * r * 0.8, c.dy - z * r * 0.8),
      Paint()
        ..color = KetTheme.accent
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(c.dx + x * r * 0.8, c.dy - z * r * 0.8),
      3,
      Paint()..color = KetTheme.accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onTap,
      builder: (context, states) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isActive ? KetTheme.accent : Colors.transparent, width: 2),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
