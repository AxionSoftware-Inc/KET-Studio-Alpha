import 'package:fluent_ui/fluent_ui.dart';
import 'package:multi_split_view/multi_split_view.dart';

// CONFIG & THEME
import '../config/menu_setup.dart';
import '../config/command_registry.dart';
import '../core/theme/ket_theme.dart';

// SERVICES
import '../core/plugin/plugin_system.dart';
import '../core/services/layout_service.dart';
import '../core/services/menu_service.dart';
import '../core/services/python_setup_service.dart';
import '../core/services/app_service.dart';

// MODULES
import '../modules/editor/editor_widget.dart';
import '../modules/terminal/terminal_widget.dart';

// WIDGETS
import 'widgets/layout_bars.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final LayoutService _layout = LayoutService();
  final MultiSplitViewController _hController = MultiSplitViewController();
  final MultiSplitViewController _vController = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupCommands(context);
      if (MenuService().menus.isEmpty) setupMenus(context);
      if (!_layout.isBottomPanelVisible) _layout.toggleBottomPanel();
      PythonSetupService().checkAndInstallDependencies();
      AppService().initialize();
    });
  }

  void _syncControllers(ISidePanel? left, ISidePanel? right) {
    final List<Area> hAreas = [
      if (left != null)
        Area(
          data: PanelHeader(panel: left, child: left.buildContent(context)),
          size: 250,
        ),
      Area(data: const EditorWidget(), flex: 1),
      if (right != null)
        Area(
          data: PanelHeader(panel: right, child: right.buildContent(context)),
          size: 300,
        ),
    ];

    if (_hController.areas.length != hAreas.length) {
      _hController.areas = hAreas;
    }

    if (_layout.isBottomPanelVisible) {
      final List<Area> vAreas = [
        Area(
          data: const SizedBox(),
          flex: 1,
        ), // Placeholder, MultiSplit handles nesting
        Area(data: TerminalWidget(layout: _layout), size: 180),
      ];
      if (_vController.areas.length != vAreas.length) {
        _vController.areas = vAreas;
      }
    }
  }

  @override
  void dispose() {
    _hController.dispose();
    _vController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _layout,
      builder: (context, _) {
        if (MenuService().menus.isEmpty) setupMenus(context);

        final activeLeft = _layout.activeLeftPanelId != null
            ? PluginRegistry().getPanel(_layout.activeLeftPanelId!)
            : null;
        final activeRight = _layout.activeRightPanelId != null
            ? PluginRegistry().getPanel(_layout.activeRightPanelId!)
            : null;

        // Sync without postFrame if possible, or use a safer trigger
        _syncControllers(activeLeft, activeRight);

        return Container(
          color: KetTheme.bgCanvas,
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: Row(
                  children: [
                    ActivityBar(isLeft: true, layout: _layout),
                    Expanded(
                      child: _buildCentralSplit(activeLeft, activeRight),
                    ),
                    ActivityBar(isLeft: false, layout: _layout),
                  ],
                ),
              ),
              StatusBar(layout: _layout),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCentralSplit(ISidePanel? left, ISidePanel? right) {
    Widget horizontalView;
    if (left == null && right == null) {
      horizontalView = const EditorWidget();
    } else {
      horizontalView = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerThickness: 1,
          dividerPainter: DividerPainters.background(color: Colors.black),
        ),
        child: MultiSplitView(
          controller: _hController,
          builder: (context, area) => area.data as Widget,
        ),
      );
    }

    if (!_layout.isBottomPanelVisible) return horizontalView;

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerThickness: 1,
        dividerPainter: DividerPainters.background(color: Colors.black),
      ),
      child: MultiSplitView(
        axis: Axis.vertical,
        controller: _vController,
        builder: (context, area) {
          if (area.index == 0) return horizontalView;
          return area.data as Widget;
        },
      ),
    );
  }
}
