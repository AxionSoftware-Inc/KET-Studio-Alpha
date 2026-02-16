import 'dart:io'; // <--- BU ENG MUHIM IMPORT (Disk bilan ishlash uchun)
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/dart.dart';
import '../models/editor_file.dart';

class EditorService extends ChangeNotifier {
  // Singleton
  static final EditorService _instance = EditorService._internal();
  factory EditorService() => _instance;
  EditorService._internal();

  // STATE
  final List<EditorFile> _files = [];
  int _activeFileIndex = -1;
  final ValueNotifier<bool> hasActiveFile = ValueNotifier(false);
  int cursorLine = 1;
  int cursorColumn = 1;

  void updateCursorPosition(int line, int col) {
    cursorLine = line;
    cursorColumn = col;
    notifyListeners();
  }

  // GETTERS
  List<EditorFile> get files => _files;
  int get activeFileIndex => _activeFileIndex;

  EditorFile? get activeFile {
    if (_activeFileIndex >= 0 && _activeFileIndex < _files.length) {
      return _files[_activeFileIndex];
    }
    return null;
  }

  // --- ACTIONS ---

  // 1. Yangi fayl ochish
  void openFile(String fileName, String content, {String? realPath}) {
    // Agar fayl allaqachon ochiq bo'lsa, o'shanga o'tamiz
    int existingIndex = _files.indexWhere((f) => f.name == fileName);
    if (existingIndex != -1) {
      _activeFileIndex = existingIndex;
      notifyListeners();
      return;
    }

    // CodeController yaratamiz
    final controller = CodeController(
      text: content,
      language: fileName.endsWith('.dart') ? dart : python,
    );

    // Faylni ro'yxatga qo'shamiz
    final newFile = EditorFile(
      // Agar realPath bo'lsa o'shani, bo'lmasa soxta yo'lni olamiz
      path: realPath ?? "/fake/path/$fileName",
      name: fileName,
      extension: fileName.split('.').last,
      controller: controller,
    );

    _files.add(newFile);
    _activeFileIndex = _files.length - 1;
    hasActiveFile.value = true;
    notifyListeners();
  }

  // 2. Tabni yopish
  void closeFile(int index) {
    _files.removeAt(index);
    if (_files.isEmpty) {
      _activeFileIndex = -1;
      hasActiveFile.value = false;
    } else if (index <= _activeFileIndex) {
      _activeFileIndex = (_activeFileIndex - 1).clamp(0, _files.length - 1);
    }
    notifyListeners();
  }

  // 3. Tabga o'tish
  void setActiveIndex(int index) {
    _activeFileIndex = index;
    notifyListeners();
  }

  // 4. FAYLNI SAQLASH (YANGI QO'SHILGAN KOD) ✅
  Future<void> saveActiveFile() async {
    final file = activeFile;
    if (file == null) return;

    // Agar bu haqiqiy fayl bo'lsa (soxta /fake/... bo'lmasa)
    if (!file.path.startsWith('/fake')) {
      try {
        final diskFile = File(file.path);
        await diskFile.writeAsString(file.controller.text);
        debugPrint("Muvaffaqiyatli saqlandi: ${file.path}");
      } catch (e) {
        debugPrint("Saqlashda xato: $e");
      }
    } else {
      debugPrint(
        "Bu yangi fayl, uni hali diskka saqlab bo'lmaydi (Save As kerak).",
      );
    }
  }

  // 5. RENAME FILE (Tab nomini yangilash uchun)
  void renameFile(String oldPath, String newPath) {
    final index = _files.indexWhere((f) => f.path == oldPath);
    if (index != -1) {
      final newName = newPath.split(Platform.pathSeparator).last;
      _files[index] = EditorFile(
        path: newPath,
        name: newName,
        extension: newName.split('.').last,
        controller: _files[index].controller,
      );
      notifyListeners();
    }
  }

  // 6. SAVE ALL
  Future<void> saveAll() async {
    for (var file in _files) {
      if (!file.path.startsWith('/fake')) {
        try {
          await File(file.path).writeAsString(file.controller.text);
        } catch (e) {
          debugPrint("Save error: $e");
        }
      }
    }
  }

  // 7. REVERT (Yangilash)
  Future<void> revertFile() async {
    final file = activeFile;
    if (file == null || file.path.startsWith('/fake')) return;
    try {
      final content = await File(file.path).readAsString();
      file.controller.text = content;
      notifyListeners();
    } catch (e) {
      debugPrint("Revert error: $e");
    }
  }

  // 8. CLOSE ACTIVE
  void closeActiveFile() {
    if (_activeFileIndex != -1) {
      closeFile(_activeFileIndex);
    }
  }

  // 9. CLOSE ALL
  void closeAll() {
    _files.clear();
    _activeFileIndex = -1;
    hasActiveFile.value = false;
    notifyListeners();
  }
}
