import 'package:flutter/material.dart';

/// Çizim aracı türleri
enum ToolType {
  pen,     // Kalem — ince, opak çizgi
  marker,  // Marker — kalın, yarı saydam çizgi
  eraser,  // Silgi — çizgileri siler
  select,  // Seç — bölge seçimi (soru seçme)
}

/// Çizim aracı veri modeli
///
/// Araç çubuğundaki aktif aracın durumunu temsil eder.
class DrawingToolModel {
  /// Araç türü
  final ToolType type;

  /// Çizim rengi (silgi hariç)
  final Color color;

  /// Fırça/çizgi kalınlığı
  final double size;

  const DrawingToolModel({
    required this.type,
    required this.color,
    required this.size,
  });

  /// Varsayılan kalem aracı
  factory DrawingToolModel.defaultPen() {
    return const DrawingToolModel(
      type: ToolType.pen,
      color: Colors.white,
      size: 3.0,
    );
  }

  /// Değiştirilmiş kopya oluştur (immutable pattern)
  DrawingToolModel copyWith({
    ToolType? type,
    Color? color,
    double? size,
  }) {
    return DrawingToolModel(
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  /// Araç silgi mi kontrol et
  bool get isEraser => type == ToolType.eraser;

  /// Araç seçim modu mu kontrol et
  bool get isSelect => type == ToolType.select;

  /// Araç çizim yapabilir mi kontrol et (kalem veya marker)
  bool get isDrawing => type == ToolType.pen || type == ToolType.marker;

  /// Marker için opaklık değeri
  double get opacity => type == ToolType.marker ? 0.4 : 1.0;

  @override
  String toString() => 'DrawingToolModel(type: $type, color: $color, size: $size)';
}
