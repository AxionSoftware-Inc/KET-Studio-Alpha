import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/menu_service.dart';

void registerEditMenu(BuildContext context) {
  final menuService = MenuService();

  menuService.registerMenu("Edit", [
    MenuItemData(commandId: "edit.undo"),
    MenuItemData(commandId: "edit.redo"),
    MenuItemData.separator(),
    MenuItemData(commandId: "edit.copyAll"),
  ]);
}
