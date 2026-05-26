import 'package:flutter/material.dart';

class AppColors {
  // Studio Palette
  static const Color studioIndigo = Color(0xFF6366F1);
  static const Color royalViolet = Color(0xFF8B5CF6);
  static const Color vibrantEmerald = Color(0xFF10B981);
  static const Color deepRose = Color(0xFFF43F5E);
  static const Color energyOrange = Color(0xFFFB923C);

  // Backgrounds & Neutrals (Studio Dark)
  static const Color deepSlate = Color(0xFF0F172A);
  static const Color slateCard = Color(0xFF1E293B);
  static const Color slateText = Color(0xFFF8FAFC);
  static const Color slateMuted = Color(0xFF94A3B8);

  // Backgrounds & Neutrals (Studio Light)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E1B4B);
  static const Color lightMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient paintGradient = LinearGradient(
    colors: [studioIndigo, royalViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
