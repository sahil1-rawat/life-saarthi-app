import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─────────────────────────────────────────────
  // Brand Colors
  // ─────────────────────────────────────────────

  static const Color primary = Color(0xFF263A7A);
  static const Color primaryDark = Color(0xFF111A36);
  static const Color primaryLight = Color(0xFF5267AD);

  static const Color secondary = Color(0xFF3F56A3);
  static const Color secondaryLight = Color(0xFF7184C4);

  // ─────────────────────────────────────────────
  // Accent
  // ─────────────────────────────────────────────

  static const Color gold = Color(0xFFC9A45C);
  static const Color goldLight = Color(0xFFE2CB96);
  static const Color goldDark = Color(0xFF9F7A36);

  // ─────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────

  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF1F8);

  // ─────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────

  static const Color darkBackground = Color(0xFF0D1328);
  static const Color darkSurface = Color(0xFF151D38);
  static const Color darkSurfaceVariant = Color(0xFF202A49);

  // ─────────────────────────────────────────────
  // Text - Light Theme
  // ─────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF182033);
  static const Color textSecondary = Color(0xFF596174);
  static const Color textTertiary = Color(0xFF858DA0);
  static const Color textDisabled = Color(0xFFB5BAC5);

  // ─────────────────────────────────────────────
  // Text - Dark Theme
  // ─────────────────────────────────────────────

  static const Color darkTextPrimary = Color(0xFFF4F6FA);
  static const Color darkTextSecondary = Color(0xFFB7BED0);
  static const Color darkTextTertiary = Color(0xFF858EA5);
  static const Color darkTextDisabled = Color(0xFF596174);

  // ─────────────────────────────────────────────
  // Semantic Colors
  // ─────────────────────────────────────────────

  static const Color success = Color(0xFF4F8A68);
  static const Color successLight = Color(0xFFDCEDE3);
  static const Color successDark = Color(0xFF2F6449);

  static const Color warning = Color(0xFFC58A3A);
  static const Color warningLight = Color(0xFFF8EBD5);
  static const Color warningDark = Color(0xFF8E5F20);

  static const Color error = Color(0xFFB95757);
  static const Color errorLight = Color(0xFFF5DDDD);
  static const Color errorDark = Color(0xFF873A3A);

  static const Color info = Color(0xFF4C73B8);
  static const Color infoLight = Color(0xFFDDE7F7);
  static const Color infoDark = Color(0xFF34558E);

  // ─────────────────────────────────────────────
  // Borders & Dividers
  // ─────────────────────────────────────────────

  static const Color border = Color(0xFFDDE1EA);
  static const Color borderLight = Color(0xFFE9EBF1);
  static const Color borderDark = Color(0xFF303A55);

  static const Color divider = Color(0xFFE4E7EE);

  // ─────────────────────────────────────────────
  // Icons
  // ─────────────────────────────────────────────

  static const Color iconPrimary = Color(0xFF263A7A);
  static const Color iconSecondary = Color(0xFF69738A);
  static const Color iconDisabled = Color(0xFFB5BAC5);
  static const Color iconOnPrimary = Color(0xFFFFFFFF);
  static const Color iconOnDark = Color(0xFFF4F6FA);

  // ─────────────────────────────────────────────
  // Special / Feature Colors
  // ─────────────────────────────────────────────

  static const Color task = Color(0xFF5267AD);
  static const Color expense = Color(0xFF4F8A68);
  static const Color note = Color(0xFFC58A3A);
  static const Color ai = Color(0xFFC9A45C);
  static const Color calendar = Color(0xFF6674A8);

  // ─────────────────────────────────────────────
  // Overlay
  // ─────────────────────────────────────────────

  static const Color overlay = Color(0x66000000);
  static const Color lightOverlay = Color(0x14000000);
  static const Color darkOverlay = Color(0x66000000);

  // ─────────────────────────────────────────────
  // Common
  // ─────────────────────────────────────────────

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
}
