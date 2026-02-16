import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // <--- ValueNotifier uchun kerak
import 'terminal_service.dart';
import 'viz_service.dart';

class ExecutionService {
  static final ExecutionService _instance = ExecutionService._internal();
  factory ExecutionService() => _instance;
  ExecutionService._internal();

  Process? _process;

  // --- 1. BU YERDA XATO BERAYOTGAN "isRunning" BOR ---
  final ValueNotifier<bool> isRunning = ValueNotifier(false);

  Future<void> runPython(String filePath, {String? content}) async {
    final terminal = TerminalService();

    if (_process != null) stop();

    terminal.write("> Preparing execution environment...");

    try {
      isRunning.value = true;
      final sessionId = "v_${DateTime.now().millisecondsSinceEpoch}";
      VizService().startSession(sessionId);

      String actualFilePath = filePath;
      String projectDir;

      // Handle "Fake" or unsaved files by writing them to a real temp location
      if (filePath.startsWith('/fake')) {
        final tempSystemDir = Directory.systemTemp.createTempSync(
          'ket_studio_exec_',
        );
        projectDir = tempSystemDir.path.replaceAll(r'\', '/');
        actualFilePath = "$projectDir/temp_script.py";
        if (content != null) {
          await File(actualFilePath).writeAsString(content);
        } else {
          terminal.write("Error: Cannot run unsaved file without content.");
          isRunning.value = false;
          return;
        }
      } else {
        projectDir = Directory(
          File(filePath).parent.path,
        ).absolute.path.replaceAll(r'\', '/');
      }

      final ketBaseDir = "$projectDir/.ket";
      final outDir = "$ketBaseDir/out";
      final tempDir = "$ketBaseDir/temp";

      // Ensure directories exist
      await Directory(outDir).create(recursive: true);
      await Directory(tempDir).create(recursive: true);

      final launcherPath = "$tempDir/launcher.py";
      final helperPath1 = "$projectDir/ket_viz.py";
      final helperPath2 = "$projectDir/ketviz.py";

      // Update filePath for the launcher below
      final scriptToRun = actualFilePath.replaceAll(r'\', '/');

      const helperCode = """
import json, time, os

def viz(kind, payload):
    \"\"\"Standard KET VIZ protocol\"\"\"
    msg = {"kind": kind, "payload": payload, "ts": int(time.time()*1000)}
    print(f"KET_VIZ {json.dumps(msg, ensure_ascii=False)}", flush=True)

def heatmap(data, title="Heatmap"):
    viz("heatmap", {"data": data, "title": title})

def table(title, rows):
    viz("table", {"title": title, "rows": rows})

def text(content):
    viz("text", {"content": content})

def histogram(counts, title="Counts"):
    viz("quantum", {"histogram": counts, "title": title})

def plot(fig, name="plot.png", title=None):
    out_dir = os.environ.get("KET_OUT", ".")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    path = os.path.join(out_dir, name)
    fig.savefig(path, bbox_inches='tight')
    viz("image", {"path": path, "title": title or name})
    return path

def dashboard(histogram=None, matrix=None):
    \"\"\"Combine histogram and matrix in one view\"\"\"
    viz("quantum", {"histogram": histogram, "matrix": matrix})
""";

      final launcherCode = """
import sys
import os
import json

# --- KET IDE INTERCEPTOR ---
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    
    def ket_show(*args, **kwargs):
        import time
        vdir = os.environ.get("KET_OUT", ".")
        if not os.path.exists(vdir):
            os.makedirs(vdir)
        path = os.path.join(vdir, f"viz_{int(time.time()*1000)}.png")
        plt.savefig(path, bbox_inches='tight')
        print(f"IMAGE:{path}")
        plt.close()
    
    import matplotlib.figure
    def ket_fig_show(self, *args, **kwargs):
        import time
        vdir = os.environ.get("KET_OUT", ".")
        if not os.path.exists(vdir):
            os.makedirs(vdir)
        path = os.path.join(vdir, f"viz_{int(time.time()*1000)}.png")
        self.savefig(path, bbox_inches='tight')
        print(f"IMAGE:{path}")
    
    plt.show = ket_show
    matplotlib.figure.Figure.show = ket_fig_show
except Exception:
    pass

# Run user script
import runpy
try:
    target_script = sys.argv[1]
    sys.argv = sys.argv[1:]
    runpy.run_path(target_script, run_name="__main__")
except Exception as e:
    import traceback
    traceback.print_exc()
""";

      await File(helperPath1).writeAsString(helperCode);
      await File(helperPath2).writeAsString(helperCode);
      await File(launcherPath).writeAsString(launcherCode);

      // Try python then python3
      String executable = 'python';
      try {
        final check = await Process.run(executable, ['--version']);
        if (check.exitCode != 0) throw 'fail';
      } catch (e) {
        executable = 'python3';
        try {
          final check = await Process.run(executable, ['--version']);
          if (check.exitCode != 0) throw 'fail';
        } catch (e) {
          terminal.write(
            "❌ Error: Python not found. Please install Python and add it to PATH.",
          );
          VizService().endSession(
            exitCode: 1,
            error: "Python not found. Please check your system PATH.",
          );
          isRunning.value = false;
          return;
        }
      }

      terminal.write("> Executing: $executable $scriptToRun");
      terminal.write("----------------------------------------");

      _process = await Process.start(
        executable,
        ['-u', launcherPath, scriptToRun],
        workingDirectory: projectDir,
        environment: {"KET_OUT": outDir, "PYTHONUNBUFFERED": "1"},
      );
      if (_process == null) {
        terminal.write("❌ Error: Python start failed.");
        isRunning.value = false;
        return;
      }

      _process!.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (var line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          // --- KET_VIZ PROTOCOL ---
          final upperTrimmed = trimmed.toUpperCase();
          if (upperTrimmed.startsWith("KET_VIZ")) {
            try {
              // Extract everything after the first colon or after the "KET_VIZ" tag
              String jsonPart;
              if (upperTrimmed.contains(':')) {
                jsonPart = trimmed.substring(trimmed.indexOf(':') + 1).trim();
              } else {
                jsonPart = trimmed.substring(7).trim(); // Skip "KET_VIZ"
              }

              final msg = jsonDecode(jsonPart);
              String kind = (msg['kind'] ?? msg['type'] ?? "")
                  .toString()
                  .toLowerCase();
              final payload = msg['payload'] ?? msg['data'];

              // Map 'quantum' kind to our internal 'dashboard' type for consistency
              if (kind == "quantum") kind = "dashboard";

              final type = VizType.values.firstWhere(
                (e) => e.toString().split('.').last == kind,
                orElse: () => VizType.none,
              );

              if (type != VizType.none) {
                // Image path resolution
                if (type == VizType.image || type == VizType.circuit) {
                  String? path = payload is Map
                      ? payload['path']
                      : payload.toString();
                  if (path != null && !File(path).isAbsolute) {
                    if (payload is Map) payload['path'] = "$projectDir/$path";
                  }
                }
                VizService().updateData(type, payload);
              }
            } catch (e) {
              debugPrint("KET_VIZ Parse Error: $e in line: $trimmed");
            }
          }
          // 1. VIZ: explicitly (Legacy support)
          else if (trimmed.startsWith("VIZ:")) {
            try {
              final jsonStr = trimmed.substring(4).trim();
              final map = jsonDecode(jsonStr);
              final typeStr = map['type'] as String;
              final vizData = map['data'];

              final type = VizType.values.firstWhere(
                (e) => e.toString().split('.').last == typeStr,
                orElse: () => VizType.none,
              );

              if (type != VizType.none) {
                VizService().updateData(type, vizData);
              }
            } catch (e) {
              debugPrint("Viz Parse Error: $e");
            }
          }
          // 2. __DATA__: pattern
          else if (trimmed.startsWith("__DATA__:")) {
            try {
              final jsonStr = trimmed.substring(9).trim();
              final data = jsonDecode(jsonStr);
              VizService().updateData(VizType.dashboard, data);
            } catch (e) {
              debugPrint("__DATA__ Parse Error: $e");
            }
          }
          // 3. BLOCH:theta,phi OR BLOCH:x,y,z
          else if (trimmed.toUpperCase().startsWith("BLOCH:")) {
            final coords = trimmed.substring(6).split(',');
            if (coords.length == 2) {
              // Assume Sphere (theta, phi)
              final theta = double.tryParse(coords[0]) ?? 0;
              final phi = double.tryParse(coords[1]) ?? 0;
              VizService().updateData(VizType.bloch, {
                "theta": theta,
                "phi": phi,
              });
            } else if (coords.length == 3) {
              final x = double.tryParse(coords[0]) ?? 0;
              final y = double.tryParse(coords[1]) ?? 0;
              final z = double.tryParse(coords[2]) ?? 0;
              VizService().updateData(VizType.bloch, {"x": x, "y": y, "z": z});
            }
          }
          // 4. IMAGE:path
          else if (trimmed.toUpperCase().startsWith("IMAGE:") ||
              trimmed.toUpperCase().startsWith("CIRCUIT:")) {
            final type = trimmed.toUpperCase().startsWith("CIRCUIT:")
                ? VizType.circuit
                : VizType.image;
            var path = trimmed.substring(trimmed.indexOf(":") + 1).trim();

            // Resolve relative path
            if (!File(path).isAbsolute) {
              path = "$projectDir/$path";
            }

            VizService().updateData(type, path);
          }
          // 5. GENERIC JSON (e.g. Qiskit events)
          else if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
            try {
              final map = jsonDecode(trimmed);

              // Prioritize images/charts
              String? imgPath =
                  map['path'] ??
                  map['hist_path'] ??
                  map['image_path'] ??
                  map['circuit_path'];

              if (imgPath != null) {
                if (!File(imgPath).isAbsolute) {
                  imgPath = "$projectDir/$imgPath";
                }
                VizService().updateData(VizType.image, imgPath);
              } else if (map.containsKey('final_counts') ||
                  map.containsKey('counts')) {
                final counts = map['final_counts'] ?? map['counts'];
                VizService().updateData(VizType.dashboard, {
                  "histogram": counts,
                });
              } else {
                // If it's a generic JSON we don't know, just print it as text
                terminal.write(trimmed);
              }
            } catch (e) {
              terminal.write(trimmed);
            }
          }
          // Default: Terminal
          else {
            terminal.write(trimmed);
          }
        }
      });

      String stderrBuffer = "";
      _process?.stderr.transform(utf8.decoder).listen((data) {
        terminal.write("❌ Error: $data");
        stderrBuffer += data;
      });

      final exitCode = await _process!.exitCode;
      if (exitCode != 0 && stderrBuffer.isNotEmpty) {
        VizService().endSession(exitCode: exitCode, error: stderrBuffer);
      } else {
        VizService().endSession(exitCode: exitCode);
      }
      terminal.write("----------------------------------------");
      terminal.write("Process finished with exit code $exitCode");

      _process = null;
      isRunning.value = false;
    } catch (e) {
      terminal.write("⚠️ System Error: $e");
      VizService().endSession(exitCode: 1, error: e.toString());
      isRunning.value = false;
    }
  }

  // --- 2. BU YERDA XATO BERAYOTGAN "writeToStdin" BOR ---
  void writeToStdin(String text) {
    if (_process != null) {
      try {
        _process!.stdin.writeln(text);
      } catch (e) {
        TerminalService().write("⚠️ Input Error: $e");
      }
    } else {
      TerminalService().write("⚠️ Hozir hech qanday dastur ishlamayapti.");
    }
  }

  void stop() {
    if (_process != null) {
      _process!.kill();
      TerminalService().write("\n🛑 Dastur majburan to'xtatildi.");
      _process = null;
      isRunning.value = false;
    }
  }
}
