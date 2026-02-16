import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'editor_service.dart';
import '../../config/demo_content.dart';

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  bool _isFirstRun = false;
  bool get isFirstRun => _isFirstRun;

  Future<void> initialize() async {
    final docDir = await getApplicationDocumentsDirectory();
    final markerFile = File("${docDir.path}/.ket_studio_initialized");

    if (!markerFile.existsSync()) {
      _isFirstRun = true;
      // Mark as initialized for next time
      await markerFile.create();

      // Auto-open demo on first run ever
      EditorService().openFile("welcome_demo.py", DemoContent.demoScript);
    }
  }
}
