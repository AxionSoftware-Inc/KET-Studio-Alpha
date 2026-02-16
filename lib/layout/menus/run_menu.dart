import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/menu_service.dart';

void registerRunMenu(BuildContext context) {
  final menuService = MenuService();

  menuService.registerMenu("Run", [
    MenuItemData(commandId: "run.start"),
    MenuItemData(commandId: "run.stop"),
  ]);
}
