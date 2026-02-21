import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../core/theme/ket_theme.dart';
import '../../core/services/editor_service.dart';
import 'tutorial_model.dart';

class TutorialWidget extends StatefulWidget {
  const TutorialWidget({super.key});

  @override
  State<TutorialWidget> createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  Tutorial? _selectedTutorial;

  @override
  Widget build(BuildContext context) {
    if (_selectedTutorial != null) {
      return _buildTutorialDetail(_selectedTutorial!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "QUANUM KUTUBXONASI",
            style: KetTheme.headerStyle.copyWith(color: KetTheme.accent),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: quantumTutorials.length,
            itemBuilder: (context, index) {
              final tutorial = quantumTutorials[index];
              return ListTile(
                title: Text(
                  tutorial.title,
                  style: KetTheme.headerStyle.copyWith(fontSize: 13),
                ),
                subtitle: Text(
                  tutorial.description,
                  style: KetTheme.descriptionStyle,
                ),
                leading: Icon(
                  FluentIcons.reading_mode,
                  size: 20,
                  color: KetTheme.accent,
                ),
                onPressed: () {
                  setState(() {
                    _selectedTutorial = tutorial;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialDetail(Tutorial tutorial) {
    return Column(
      children: [
        // Header
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => setState(() => _selectedTutorial = null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tutorial.title,
                  style: KetTheme.headerStyle.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: tutorial.sections
                .map((section) => _buildSection(section))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(TutorialSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: KetTheme.headerStyle.copyWith(
            color: KetTheme.accent,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildRichContent(section.content),
        if (section.codeSnippet != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  section.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 11,
                    color: Color(0xFFDCDCAA),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    child: const Text(
                      "Namuna Kodni Muharrirda Ochish",
                      style: TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      EditorService().openFile(
                        "tutorial_${section.title.replaceAll(' ', '_').toLowerCase()}.py",
                        section.codeSnippet!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRichContent(String content) {
    // Odatiy matn va LaTeX qismlarini ajratish
    final parts = content.split('\$');
    List<Widget> inlineParts = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Matn
        if (parts[i].isNotEmpty) {
          inlineParts.add(
            Text(
              parts[i],
              style: KetTheme.descriptionStyle.copyWith(
                color: KetTheme.textMain,
              ),
            ),
          );
        }
      } else {
        // LaTeX
        if (parts[i].isNotEmpty) {
          inlineParts.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Math.tex(
                parts[i],
                mathStyle: MathStyle.text,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ),
          );
        }
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: inlineParts,
    );
  }
}
