import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/menu_service.dart';

void registerViewMenu(BuildContext context) {
  final menuService = MenuService();

  menuService.registerMenu("View", [
    MenuItemData(commandId: "view.toggleExplorer"),
    MenuItemData(commandId: "view.toggleViz"),
    MenuItemData(commandId: "view.toggleTerminal"),
  ]);
}
