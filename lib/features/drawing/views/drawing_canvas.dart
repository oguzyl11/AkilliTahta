import 'package:flutter/material.dart';
import '../models/stroke_model.dart';
import '../controllers/drawing_controller.dart';
import 'package:provider/provider.dart';

/// Çizim canvas'ı — CustomPainter ile çizim katmanı
///
/// PDF görüntüleyicinin üzerine Stack ile bindirilir.
/// GestureDetector ile dokunma/mouse olaylarını yakalar.
class DrawingCanvas extends StatelessWidget {
  final int pageNumber;
  const DrawingCanvas({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingController>(
      builder: (context, controller, child) {
        // Seçim modunda çizim canvas'ı devre dışı
        if (controller.currentTool.isSelect) {
          return const SizedBox.expand();
        }

        return GestureDetector(
          onPanStart: (details) {
            // Çizim başlarken aktif sayfayı ayarla (güvence amaçlı)
            controller.setActivePageNumber(pageNumber);
            controller.startStroke(details.localPosition);
          },
          onPanUpdate: (details) {
            controller.updateStroke(details.localPosition);
          },
          onPanEnd: (_) {
            controller.endStroke();
          },
          child: ClipRect(
            child: CustomPaint(
              painter: _StrokePainter(
                strokes: controller.getStrokesForPage(pageNumber),
                currentStroke: controller.activePageNumber == pageNumber 
                    ? controller.currentStroke 
                    : null,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

/// Çizim painter'ı — tüm stroke'ları canvas üzerine çizer
///
/// SaveLayer/restore ile eraser blend mode'u destekler.
class _StrokePainter extends CustomPainter {
  final List<StrokeModel> strokes;
  final StrokeModel? currentStroke;

  _StrokePainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Eraser için saveLayer gerekli (BlendMode.clear düzgün çalışsın)
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Tamamlanmış stroke'ları çiz
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Aktif stroke'u çiz (çizim devam ederken)
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    canvas.restore();
  }

  /// Tek bir stroke'u çiz
  void _drawStroke(Canvas canvas, StrokeModel stroke) {
    final paint = stroke.toPaint();
    final points = stroke.points;

    if (points.isEmpty) return;

    // Tek nokta — daire çiz
    if (points.length == 1 && points[0] != null) {
      canvas.drawCircle(points[0]!, paint.strokeWidth / 2, paint);
      return;
    }

    // Çoklu nokta — çizgi çiz
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}
