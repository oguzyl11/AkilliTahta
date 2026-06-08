import 'package:flutter/material.dart';
import '../../drawing/controllers/drawing_controller.dart';
import '../../drawing/models/drawing_tool_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Araç çubuğu controller'ı
///
/// SOLID-S: Araç çubuğu UI state'inden sorumlu.
/// DrawingController ile senkronize çalışır.
class ToolbarController extends ChangeNotifier {
  final DrawingController _drawingController;

  ToolbarController({required DrawingController drawingController})
      : _drawingController = drawingController;

  // ─── State ───
  ToolType _activeToolType = ToolType.pen;
  Color _activeColor = AppColors.drawingPalette[0]; // Beyaz
  double _brushSize = AppSizes.brushSizeDefault;
  bool _isExpanded = true;

  // ─── Getters ───
  ToolType get activeToolType => _activeToolType;
  Color get activeColor => _activeColor;
  double get brushSize => _brushSize;
  bool get isExpanded => _isExpanded;

  /// Araç türünü değiştir
  void selectTool(ToolType type) {
    _activeToolType = type;

    // Silgi seçildiğinde boyutu otomatik artır
    double size = _brushSize;
    if (type == ToolType.eraser) {
      size = AppSizes.eraserSizeDefault;
    } else if (type == ToolType.marker) {
      size = AppSizes.markerSizeDefault;
    }

    _drawingController.setTool(DrawingToolModel(
      type: type,
      color: _activeColor,
      size: size,
    ));

    notifyListeners();
  }

  /// Renk değiştir
  void selectColor(Color color) {
    _activeColor = color;
    _drawingController.setColor(color);
    notifyListeners();
  }

  /// Fırça boyutu değiştir
  void changeBrushSize(double size) {
    _brushSize = size;
    _drawingController.setSize(size);
    notifyListeners();
  }

  /// Araç çubuğunu aç/kapat (daralt/genişlet)
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}
