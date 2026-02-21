import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';

class KetTheme {
  // --- PROFESSIONAL PALITRA (VS CODE STYLE) ---
  static Color get bgCanvas => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF1B1B1C)
      : const Color(0xFFF3F3F3);

  static Color get bgSidebar => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF202021)
      : const Color(0xFFF8F8F8);

  static Color get bgActivityBar =>
      SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF181818)
      : const Color(0xFF2C2C2C);

  static Color get bgHeader => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF252526)
      : const Color(0xFFE5E5E5);

  static Color get bgHover => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF333334)
      : const Color(0xFFE0E0E0);

  static Color get bgSelected => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF37373D)
      : const Color(0xFFD0D0D0);

  static Color get border => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF2B2B2C)
      : const Color(0xFFCCCCCC);

  static Color get textMain => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFFE0E0E0)
      : const Color(0xFF333333);

  static Color get textMuted => SettingsService().themeMode == ThemeMode.dark
      ? const Color(0xFF8B8B8B)
      : const Color(0xFF666666);

  static Color get accent => SettingsService().accentColor;

  // --- TEXT STYLES ---
  static TextStyle get globalFont => GoogleFonts.inter();

  static TextStyle get menuStyle => GoogleFonts.inter(
    fontSize: 12.5,
    color: textMain,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get headerStyle => GoogleFonts.inter(
    fontSize: 10,
    color: textMain,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get descriptionStyle =>
      GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.4);

  static TextStyle get statusStyle => GoogleFonts.inter(
    fontSize: 11,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  // --- WIDGET STYLES ---
  static const EdgeInsets panelPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  static Decoration get sidebarDecoration => BoxDecoration(
    color: bgSidebar,
    border: Border(right: BorderSide(color: border, width: 0.5)),
  );
}
