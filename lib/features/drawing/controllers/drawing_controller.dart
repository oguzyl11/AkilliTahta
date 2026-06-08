import 'package:flutter/material.dart';
import '../models/stroke_model.dart';
import '../models/drawing_tool_model.dart';

/// Çizim controller'ı — undo/redo ve sayfa bazlı çizim yönetimi
///
/// SOLID-S: Sadece çizim state ve geçmişi yönetiminden sorumlu.
class DrawingController extends ChangeNotifier {
  // ─── State ───

  /// Sayfa bazlı çizim geçmişi: {sayfaNo: [stroke listesi]}
  final Map<int, List<StrokeModel>> _pageStrokes = {};

  /// Sayfa bazlı redo yığını: {sayfaNo: [geri alınan stroke listesi]}
  final Map<int, List<StrokeModel>> _pageRedoStack = {};

  /// Şu an çizilmekte olan vuruş (null = çizim yok)
  StrokeModel? _currentStroke;

  /// Aktif çizim aracı
  DrawingToolModel _currentTool = DrawingToolModel.defaultPen();

  /// Aktif sayfa numarası
  int _activePageNumber = 1;

  // ─── Getters ───
  DrawingToolModel get currentTool => _currentTool;
  StrokeModel? get currentStroke => _currentStroke;
  int get activePageNumber => _activePageNumber;

  /// Aktif sayfanın çizim geçmişi
  List<StrokeModel> get currentPageStrokes =>
      _pageStrokes[_activePageNumber] ?? [];

  /// Geri alma yapılabilir mi
  bool get canUndo => currentPageStrokes.isNotEmpty;

  /// İleri alma yapılabilir mi
  bool get canRedo =>
      (_pageRedoStack[_activePageNumber] ?? []).isNotEmpty;

  // ─── Araç Yönetimi ───

  /// Aktif aracı değiştir
  void setTool(DrawingToolModel tool) {
    _currentTool = tool;
    notifyListeners();
  }

  /// Sadece araç türünü değiştir (renk ve boyut koru)
  void setToolType(ToolType type) {
    _currentTool = _currentTool.copyWith(type: type);
    notifyListeners();
  }

  /// Sadece rengi değiştir
  void setColor(Color color) {
    _currentTool = _currentTool.copyWith(color: color);
    notifyListeners();
  }

  /// Sadece boyutu değiştir
  void setSize(double size) {
    _currentTool = _currentTool.copyWith(size: size);
    notifyListeners();
  }

  // ─── Sayfa Yönetimi ───

  /// Aktif sayfa numarasını güncelle
  void setActivePageNumber(int pageNumber) {
    _activePageNumber = pageNumber;
    notifyListeners();
  }

  // ─── Çizim İşlemleri ───

  /// Yeni çizim vuruşu başlat
  void startStroke(Offset point) {
    if (_currentTool.isSelect) return; // Seçim modunda çizim yapma

    final strokeType = _toolTypeToStrokeType(_currentTool.type);

    _currentStroke = StrokeModel(
      points: [point],
      color: _currentTool.color,
      strokeWidth: _currentTool.size,
      type: strokeType,
      pageNumber: _activePageNumber,
      opacity: _currentTool.opacity,
    );

    notifyListeners();
  }

  /// Çizim vuruşuna nokta ekle
  void updateStroke(Offset point) {
    if (_currentStroke == null) return;

    _currentStroke = _currentStroke!.addPoint(point);
    notifyListeners();
  }

  /// Çizim vuruşunu tamamla
  void endStroke() {
    if (_currentStroke == null) return;

    // Çok kısa çizgileri filtrele (tek nokta = tıklama)
    if (_currentStroke!.points.length >= 2) {
      // Geçmişe ekle
      _pageStrokes.putIfAbsent(_activePageNumber, () => []);
      _pageStrokes[_activePageNumber]!.add(_currentStroke!);

      // Yeni çizim yapılınca redo yığınını temizle
      _pageRedoStack[_activePageNumber]?.clear();
    }

    _currentStroke = null;
    notifyListeners();
  }

  // ─── Undo / Redo ───

  /// Son çizimi geri al
  void undo() {
    final strokes = _pageStrokes[_activePageNumber];
    if (strokes == null || strokes.isEmpty) return;

    final removed = strokes.removeLast();
    _pageRedoStack.putIfAbsent(_activePageNumber, () => []);
    _pageRedoStack[_activePageNumber]!.add(removed);

    notifyListeners();
  }

  /// Geri alınan çizimi yeniden uygula
  void redo() {
    final redoStack = _pageRedoStack[_activePageNumber];
    if (redoStack == null || redoStack.isEmpty) return;

    final restored = redoStack.removeLast();
    _pageStrokes.putIfAbsent(_activePageNumber, () => []);
    _pageStrokes[_activePageNumber]!.add(restored);

    notifyListeners();
  }

  /// Aktif sayfadaki tüm çizimleri temizle
  void clearCurrentPage() {
    _pageStrokes[_activePageNumber]?.clear();
    _pageRedoStack[_activePageNumber]?.clear();
    _currentStroke = null;
    notifyListeners();
  }

  /// Tüm sayfalardaki tüm çizimleri temizle
  void clearAll() {
    _pageStrokes.clear();
    _pageRedoStack.clear();
    _currentStroke = null;
    notifyListeners();
  }

  // ─── Yardımcı ───

  /// ToolType → StrokeType dönüşümü
  StrokeType _toolTypeToStrokeType(ToolType toolType) {
    switch (toolType) {
      case ToolType.pen:
        return StrokeType.pen;
      case ToolType.marker:
        return StrokeType.marker;
      case ToolType.eraser:
        return StrokeType.eraser;
      case ToolType.select:
        return StrokeType.pen; // Seçim modunda çizim yok, fallback
    }
  }
}
