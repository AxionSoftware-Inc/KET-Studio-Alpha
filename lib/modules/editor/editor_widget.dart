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

  @override
  void initState() {
    super.initState();
    _editorService.addListener(_update);
    // Auto-opening removed to allow Welcome Screen to show when files are empty
  }

  @override
  void dispose() {
    _editorService.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

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
