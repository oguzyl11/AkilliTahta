import 'dart:ui';

/// Tek bir çizim vuruşu (stroke) veri modeli
///
/// Kullanıcının çizdiği her çizgi bir StrokeModel olarak saklanır.
/// Undo/Redo sistemi bu modeller üzerinden çalışır.
class StrokeModel {
  /// Çizgi noktaları — null değer kalem kaldırıldığını gösterir
  final List<Offset?> points;

  /// Çizgi rengi
  final Color color;

  /// Çizgi kalınlığı
  final double strokeWidth;

  /// Çizgi türü
  final StrokeType type;

  /// Hangi PDF sayfasına ait (sayfa bazlı çizim)
  final int pageNumber;

  /// Opaklık (marker için 0.4, diğerleri 1.0)
  final double opacity;

  const StrokeModel({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.type,
    required this.pageNumber,
    this.opacity = 1.0,
  });

  /// Yeni bir nokta eklenmiş kopya oluştur
  StrokeModel addPoint(Offset? point) {
    return StrokeModel(
      points: [...points, point],
      color: color,
      strokeWidth: strokeWidth,
      type: type,
      pageNumber: pageNumber,
      opacity: opacity,
    );
  }

  /// Paint nesnesi oluştur — CustomPainter'da kullanılır
  Paint toPaint() {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (type == StrokeType.eraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = const Color(0x00000000);
    } else {
      paint.color = color.withValues(alpha: opacity);
    }

    return paint;
  }

  @override
  String toString() =>
      'StrokeModel(points: ${points.length}, type: $type, page: $pageNumber)';
}

/// Çizgi/vuruş türleri
enum StrokeType {
  pen,    // Kalem
  marker, // Marker (yarı saydam)
  eraser, // Silgi
}
