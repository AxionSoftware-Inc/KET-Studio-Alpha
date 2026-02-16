import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class KetTheme {
  // --- PROFESSIONAL PALITRA (VS CODE STYLE) ---
  static const Color bgCanvas = Color(0xFF1B1B1C);
  static const Color bgSidebar = Color(0xFF202021);
  static const Color bgActivityBar = Color(0xFF181818);
  static const Color bgHeader = Color(0xFF252526);
  static const Color bgHover = Color(0xFF333334);
  static const Color bgSelected = Color(0xFF37373D);

  static const Color border = Color(0xFF2B2B2C);
  static const Color textMain = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF8B8B8B);
  static const Color accent = Color(0xFF9C27B0);

  // --- TEXT STYLES ---
  static TextStyle get globalFont => GoogleFonts.inter();

  static TextStyle menuStyle = GoogleFonts.inter(
    fontSize: 12.5,
    color: textMain,
    fontWeight: FontWeight.w500,
  );

  static TextStyle headerStyle = GoogleFonts.inter(
    fontSize: 10,
    color: textMain,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w600,
  );

  static TextStyle statusStyle = GoogleFonts.inter(
    fontSize: 11,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  // --- WIDGET STYLES ---
  static const EdgeInsets panelPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  static Decoration sidebarDecoration = const BoxDecoration(
    color: bgSidebar,
    border: Border(right: BorderSide(color: Colors.black, width: 0.5)),
  );
}
