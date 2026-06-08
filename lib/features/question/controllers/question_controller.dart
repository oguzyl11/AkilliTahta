import 'package:flutter/material.dart';
import '../models/question_model.dart';

/// Soru seçimi ve büyütme controller'ı
///
/// SOLID-S: Sadece soru seçim state'i ve modal kontrolünden sorumlu.
class QuestionController extends ChangeNotifier {
  // ─── State ───

  /// Seçili soru (null = seçim yok)
  QuestionModel? _selectedQuestion;

  /// Modal açık mı
  bool _isModalOpen = false;

  /// Seçim yapılıyor mu (rubber-band aktif)
  bool _isSelecting = false;

  /// Seçim başlangıç noktası
  Offset? _selectionStart;

  /// Seçim bitiş noktası
  Offset? _selectionEnd;

  // ─── Getters ───
  QuestionModel? get selectedQuestion => _selectedQuestion;
  bool get isModalOpen => _isModalOpen;
  bool get isSelecting => _isSelecting;
  Offset? get selectionStart => _selectionStart;
  Offset? get selectionEnd => _selectionEnd;

  /// Aktif seçim bölgesi (Rect)
  Rect? get selectionRect {
    if (_selectionStart == null || _selectionEnd == null) return null;
    return Rect.fromPoints(_selectionStart!, _selectionEnd!);
  }

  // ─── Seçim İşlemleri ───

  /// Rubber-band seçimi başlat
  void startSelection(Offset point) {
    _isSelecting = true;
    _selectionStart = point;
    _selectionEnd = point;
    notifyListeners();
  }

  /// Seçim bölgesini güncelle
  void updateSelection(Offset point) {
    if (!_isSelecting) return;
    _selectionEnd = point;
    notifyListeners();
  }

  /// Seçimi tamamla ve soruyu oluştur
  void endSelection(int pageNumber, Size pageSize) {
    if (!_isSelecting || _selectionStart == null || _selectionEnd == null) {
      cancelSelection();
      return;
    }

    // Minimum boyut kontrolü — çok küçük seçimleri reddet
    final rect = selectionRect!;
    if (rect.width < 20 || rect.height < 20) {
      cancelSelection();
      return;
    }

    // Koordinatları normalize et (0.0-1.0 aralığı)
    final normalizedBounds = Rect.fromLTWH(
      rect.left / pageSize.width,
      rect.top / pageSize.height,
      rect.width / pageSize.width,
      rect.height / pageSize.height,
    );

    _selectedQuestion = QuestionModel.create(
      pageNumber: pageNumber,
      bounds: normalizedBounds,
    );

    _isSelecting = false;
    _selectionStart = null;
    _selectionEnd = null;
    _isModalOpen = true;

    notifyListeners();
  }

  /// Seçimi iptal et
  void cancelSelection() {
    _isSelecting = false;
    _selectionStart = null;
    _selectionEnd = null;
    notifyListeners();
  }

  /// Modalı kapat
  void closeModal() {
    _isModalOpen = false;
    _selectedQuestion = null;
    notifyListeners();
  }

  /// Soruyu seç ve modalı aç
  void openQuestion(QuestionModel question) {
    _selectedQuestion = question;
    _isModalOpen = true;
    notifyListeners();
  }
}
