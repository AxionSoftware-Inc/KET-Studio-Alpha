import 'package:fluent_ui/fluent_ui.dart';
import '../core/services/menu_service.dart';
import '../layout/menus/file_menu.dart';
import '../layout/menus/edit_menu.dart';
import '../layout/menus/view_menu.dart';
import '../layout/menus/run_menu.dart';
import '../layout/menus/help_menu.dart';

void setupMenus(BuildContext context) {
  final menuService = MenuService();
  menuService.clear();

  // Register each menu module
  registerFileMenu(context);
  registerEditMenu(context);
  registerViewMenu(context);
  registerRunMenu(context);
  registerHelpMenu(context);
}
