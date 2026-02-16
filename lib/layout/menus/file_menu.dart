import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/menu_service.dart';

void registerFileMenu(BuildContext context) {
  final menuService = MenuService();

  menuService.registerMenu("File", [
    MenuItemData(commandId: "file.new"),
    MenuItemData(commandId: "file.open"),
    MenuItemData(commandId: "file.openFolder"),
    MenuItemData.separator(),
    MenuItemData(commandId: "file.save"),
    MenuItemData(commandId: "file.saveAs"),
    MenuItemData(commandId: "file.saveAll"),
    MenuItemData.separator(),
    MenuItemData(commandId: "file.revert"),
    MenuItemData.separator(),
    MenuItemData(commandId: "file.close"),
    MenuItemData(commandId: "file.closeAll"),
    MenuItemData.separator(),
    MenuItemData(commandId: "file.exit"),
  ]);
}
