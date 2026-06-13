import 'package:flutter/material.dart';

/// Central color constants for the QuickCV Pro app.
/// All SOP and other feature screens reference these instead of hardcoding hex values.
abstract class AppColors {
  // ── Brand Primary ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF024D87);
  static const Color primaryLight = Color(0xFF0369B7);
  static const Color primaryDark = Color(0xFF013A65);

  // ── Neutral / Surface ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color divider = Color(0xFFE1E3E4);
  static const Color border = Color(0xFFD8DDD8);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF3E4A3C);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF51B1E1);

  // ── Premium / Gold ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDark = Color(0xFFA07800);

  // ── Template Accent Colors ─────────────────────────────────────────────────
  static const Color templateNavy = Color(0xFF0D1B2A);
  static const Color templateCharcoal = Color(0xFF2C2C2C);
  static const Color templateSlate = Color(0xFF3A506B);
  static const Color templateTeal = Color(0xFF0D9488);
  static const Color templatePurple = Color(0xFF6B21A8);
  static const Color templateGreen = Color(0xFF166534);
  static const Color templateCrimson = Color(0xFF7F1D1D);
  static const Color templateIndigo = Color(0xFF1E3A8A);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF013A65), Color(0xFF024D87), Color(0xFF0369B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
