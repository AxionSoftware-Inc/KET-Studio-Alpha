import 'package:flutter/material.dart';
import 'command_service.dart';

// 1. Menyu Elementi Modeli
class MenuItemData {
  final String? commandId; // null bo'lsa separator
  final String? customLabel; // Agar command title'dan boshqa nom kerak bo'lsa
  final bool isSeparator;

  MenuItemData({this.commandId, this.customLabel, this.isSeparator = false});

  static MenuItemData separator() => MenuItemData(isSeparator: true);

  // Helper getters to get data from command registry
  Command? get command =>
      commandId != null ? CommandService().getCommand(commandId!) : null;
  String get label => customLabel ?? command?.title ?? "";
}

// 2. Menyu Guruhi (File, Edit, View...)
class MenuGroup {
  final String title;
  final List<MenuItemData> items;

  MenuGroup({required this.title, required this.items});
}

// 3. Xizmat (Service)
class MenuService extends ChangeNotifier {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  final List<MenuGroup> _menus = [];
  List<MenuGroup> get menus => _menus;

  void registerMenu(String title, List<MenuItemData> items) {
    final existingIndex = _menus.indexWhere((m) => m.title == title);
    if (existingIndex != -1) {
      _menus[existingIndex].items.addAll(items);
    } else {
      _menus.add(MenuGroup(title: title, items: items));
    }
    notifyListeners();
  }

  void clear() {
    _menus.clear();
    notifyListeners();
  }
}
