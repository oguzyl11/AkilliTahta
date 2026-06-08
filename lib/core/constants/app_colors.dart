import 'package:flutter/material.dart';

/// Uygulama renk paleti — açık tema odaklı akıllı tahta tasarımı
class AppColors {
  AppColors._();

  // Ana arka plan renkleri
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF0F2F5);

  // Vurgu renkleri
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Metin renkleri
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);

  // Kenar ve ayırıcı
  static const Color border = Color(0xFFE2E8F0);

  // Durum renkleri
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Araç çubuğu
  static const Color toolbarBackground = Color(0xFFFFFFFF);
  static const Color toolbarActive = Color(0xFF2563EB);
  static const Color toolbarInactive = Color(0xFF64748B);

  static const Color divider = Color(0xFFE2E8F0);

  // Çizim renkleri — öğretmen paleti
  static const List<Color> drawingPalette = [
    Color(0xFF000000), // Siyah
    Color(0xFFEF4444), // Kırmızı
    Color(0xFF2563EB), // Mavi
    Color(0xFF10B981), // Yeşil
    Color(0xFFF59E0B), // Sarı/Turuncu
    Color(0xFF8B5CF6), // Mor
  ];

  // Buton hover/aktif efektleri
  static const Color buttonHover = Color(0xFFF1F5F9);
  static const Color buttonPressed = Color(0xFFE2E8F0);
  static const Color buttonActive = Color(0xFF2563EB);
}
