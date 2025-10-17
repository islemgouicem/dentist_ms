import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF1976D2);
  static const Color sidebar = Color(0xFF0E1A2B);
  static const Color background = Color(0xFFF5F7FA); // page background
  static const Color white = Colors.white;

  // Accent cards
  static const Color cardBlue = Color(0xFF1F6DB2); // Total Patients
  static const Color cardGreen = Color(0xFF43A047); // TBU
  static const Color cardPurple = Color(0xFF6A1B9A); // Total doctors
  static const Color cardOrange = Color(0xFFE65100); // Appointments
  static const Color cardPink = Color(0xFFCC25B0); // transactions

  // Text
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFFCAD5E2);
  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black;

  // Status colors
  static const Color statusCompleted = Color(0xFF43A047);
  static const Color statusScheduled = Color(0xFF1E88E5);
  static const Color statusCancelled = Color(0xFFE53935);
  static const Color statusNoShow = Color(0xFFFFB300);

  // Borders & dividers
  static const Color border = Color(0xFFE0E6ED);
  static const Color shadow = Color(0x1A000000); // subtle shadow

  static final BoxDecoration selectedPage = BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(43, 127, 255, 0.3), // rgba(43,127,255,0.3)
        offset: Offset(0, 10), // x, y
        blurRadius: 15, // blur
        spreadRadius: -3, // spread
      ),
      BoxShadow(
        color: Color.fromRGBO(43, 127, 255, 0.3),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -4,
      ),
    ],
  );
  static const BoxDecoration navBarBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F172B), Color(0xFF1D293D), Color(0xFF0F172B)],
      stops: [0.0, 0.5, 1.0],
    ),
  );
}
