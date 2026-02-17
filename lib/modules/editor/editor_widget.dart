import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/editor_service.dart';
import '../../core/theme/ket_theme.dart';
import '../welcome/welcome_widget.dart';

class EditorWidget extends StatefulWidget {
  const EditorWidget({super.key});

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  final EditorService _editorService = EditorService();
  CodeController? _currentController;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _editorService.addListener(_update);
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    _currentController?.removeListener(_updateCursor);
    _editorService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final newActive = _editorService.activeFile;
    if (_currentController != newActive?.controller) {
      _currentController?.removeListener(_updateCursor);
      _currentController = newActive?.controller;
      _currentController?.addListener(_updateCursor);
    }
    if (mounted) setState(() {});
  }

  void _updateCursor() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer(const Duration(milliseconds: 50), () {
      final active = _editorService.activeFile;
      if (active == null) return;

      final sel = active.controller.selection;
      if (!sel.isValid || !sel.isCollapsed) return;

      final text = active.controller.text;
      final offset = sel.baseOffset.clamp(0, text.length);

      // Column: count characters after last newline
      final lastNl = text.lastIndexOf('\n', offset == 0 ? 0 : offset - 1);
      final col = offset - (lastNl + 1) + 1;

      // Line: count newlines without string split (allocation-free)
      int line = 1;
      for (int i = 0; i < offset; i++) {
        if (text.codeUnitAt(i) == 10) line++; // ASCII 10 = '\n'
      }

      _editorService.updateCursorPosition(line, col);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_editorService.files.isEmpty) {
      return const WelcomeWidget();
    }

    final activeFile = _editorService.activeFile!;

    return Column(
      children: [
        // A. TAB BAR
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: KetTheme.bgActivityBar,
            border: Border(
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _editorService.files.length,
            itemBuilder: (context, index) {
              final file = _editorService.files[index];
              final isActive = index == _editorService.activeFileIndex;

              return HoverButton(
                onPressed: () => _editorService.setActiveIndex(index),
                builder: (context, states) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? KetTheme.bgCanvas
                          : (states.isHovered
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.transparent),
                      border: isActive
                          ? Border(
                              top: BorderSide(color: KetTheme.accent, width: 2),
                            )
                          : Border(
                              bottom: BorderSide(
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          file.name.endsWith('.py')
                              ? FluentIcons.code
                              : FluentIcons.page_list,
                          size: 14,
                          color: isActive ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          file.name,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(FluentIcons.chrome_close, size: 10),
                          onPressed: () => _editorService.closeFile(index),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // B. KOD MAYDONI
        Expanded(
          child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: CodeField(
              controller: activeFile.controller,
              textStyle: GoogleFonts.jetBrainsMono(fontSize: 14),
              expands: true,
              wrap: false,
              background: KetTheme.bgCanvas,
            ),
          ),
        ),
      ],
    );
  }
}
