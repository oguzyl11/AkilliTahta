import 'package:flutter/material.dart';
import '../repositories/pdf_repository.dart';
import '../models/pdf_document_model.dart';

/// PDF görüntüleme controller'ı
///
/// SOLID-S: Sadece PDF yükleme ve sayfa navigasyonundan sorumlu.
/// SOLID-D: IPdfRepository arayüzüne bağımlı, somut sınıfa değil.
class PdfController extends ChangeNotifier {
  final IPdfRepository _pdfRepository;

  PdfController({required IPdfRepository pdfRepository})
      : _pdfRepository = pdfRepository;

  // ─── State ───
  PdfDocumentModel? _document;
  int _currentPage = 1;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFilePath;

  // ─── Getters ───
  PdfDocumentModel? get document => _document;
  int get currentPage => _currentPage;
  int get totalPages => _document?.totalPages ?? 0;
  bool get isLoaded => _document != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentFilePath => _currentFilePath;
  bool get canGoNext => _currentPage < totalPages;
  bool get canGoPrevious => _currentPage > 1;

  /// PDF dosyası seç ve yükle
  Future<void> pickAndLoadPdf() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _pdfRepository.pickAndLoadPdf();
      if (doc != null) {
        _document = doc;
        _currentPage = 1;
        _currentFilePath = doc.filePath;
      }
    } catch (e) {
      _errorMessage = 'PDF yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Belirli bir sayfaya git
  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  /// Sonraki sayfa
  void nextPage() {
    if (canGoNext) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Önceki sayfa
  void previousPage() {
    if (canGoPrevious) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// İlk sayfa
  void firstPage() {
    _currentPage = 1;
    notifyListeners();
  }

  /// Son sayfa
  void lastPage() {
    if (totalPages > 0) {
      _currentPage = totalPages;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pdfRepository.dispose();
    super.dispose();
  }
}
