import 'package:fluent_ui/fluent_ui.dart';
import '../../core/plugin/plugin_system.dart';
import 'tutorial_widget.dart';

class TutorialPlugin implements ISidePanel {
  @override
  String get id => 'tutorial';

  @override
  IconData get icon => FluentIcons.reading_mode;

  @override
  String get title => 'TUTORIALS';

  @override
  String get tooltip => 'Quantum Education & Tutorials';

  @override
  PanelPosition get position => PanelPosition.left;

  @override
  Widget buildContent(BuildContext context) {
    return const TutorialWidget();
  }
}
