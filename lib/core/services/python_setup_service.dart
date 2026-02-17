import 'package:flutter/foundation.dart';
import 'package:process_run/shell.dart';
import 'terminal_service.dart';

class PythonSetupService {
  static final PythonSetupService _instance = PythonSetupService._internal();

  factory PythonSetupService() {
    return _instance;
  }

  PythonSetupService._internal();

  bool _isSetupComplete = false;
  bool get isSetupComplete => _isSetupComplete;

  final ValueNotifier<String?> currentTask = ValueNotifier<String?>(null);
  final ValueNotifier<double> progress = ValueNotifier<double>(0.0);

  Future<void> checkAndInstallDependencies() async {
    if (_isSetupComplete) return;

    final terminal = TerminalService();
    terminal.write("Checking Python environment...");

    var shell = Shell();

    try {
      // 1. Check Python version
      var result = await shell.run('python --version').timeout(const Duration(seconds: 5));
      final versionOutput = result.first.stdout.toString().trim();
      terminal.write("Python found: $versionOutput");

      // 2. Comprehensive library list
      final libraries = [
        'qiskit',
        'qiskit-aer',
        'matplotlib',
        'pylatexenc',
        'numpy',
        'pandas',
      ];

      for (var i = 0; i < libraries.length; i++) {
        final lib = libraries[i];
        currentTask.value = "Installing $lib...";
        progress.value = (i + 1) / libraries.length;

        terminal.write("Checking $lib...");
        try {
          // Use --no-cache-dir and --progress-bar off for reliability in IDEs
          await shell.run('pip show $lib').timeout(const Duration(seconds: 10));
          terminal.write("$lib is already installed.");
        } catch (e) {
          terminal.write("$lib not found. Installing...");
          try {
            await shell.run('pip install $lib --progress-bar off --no-input').timeout(const Duration(minutes: 5));
            terminal.write("$lib installation completed.");
          } catch (err) {
            terminal.write("⚠️ Could not install $lib. Some features may not work.");
          }
        }
      }

      currentTask.value = "Cleaning up...";
      await Future.delayed(const Duration(seconds: 1));

      _isSetupComplete = true;
      currentTask.value = null;
      terminal.write("Environment setup complete. Ready for Quantum tasks.");
    } catch (e) {
      terminal.write("Error during setup: $e");
      terminal.write("Please ensure Python is installed and added to PATH.");
    }
  }
}
