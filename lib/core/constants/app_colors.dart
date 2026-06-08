import 'package:flutter/material.dart';

/// Uygulama renk paleti — koyu tema odaklı akıllı tahta tasarımı
class AppColors {
  AppColors._();

  // Ana arka plan renkleri
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);
  static const Color surfaceCard = Color(0xFF1E2A45);

  // Vurgu renkleri
  static const Color primary = Color(0xFF4A9EFF);
  static const Color primaryDark = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color accentSoft = Color(0xFFFF6B8A);

  // Metin renkleri
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textHint = Color(0xFF6C6C80);

  // Kenar ve ayırıcı
  static const Color border = Color(0xFF2A2A40);
  static const Color divider = Color(0xFF252540);

  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE94560);
  static const Color info = Color(0xFF4A9EFF);

  // Araç çubuğu
  static const Color toolbarBackground = Color(0xFF12122A);
  static const Color toolbarActive = Color(0xFF4A9EFF);
  static const Color toolbarInactive = Color(0xFF6C6C80);

  // Çizim renkleri — öğretmen paleti
  static const List<Color> drawingPalette = [
    Color(0xFFFFFFFF), // Beyaz
    Color(0xFF000000), // Siyah
    Color(0xFFE94560), // Kırmızı
    Color(0xFF4A9EFF), // Mavi
    Color(0xFF4CAF50), // Yeşil
    Color(0xFFFFEB3B), // Sarı
    Color(0xFFFF9800), // Turuncu
    Color(0xFF9C27B0), // Mor
  ];

  // Buton hover/aktif efektleri
  static const Color buttonHover = Color(0x1AFFFFFF);
  static const Color buttonPressed = Color(0x33FFFFFF);
  static const Color buttonActive = Color(0xFF4A9EFF);
}
