import 'dart:io';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/utils/file_utils.dart';
import '../models/pdf_document_model.dart';
import 'pdf_repository.dart';

/// PDF repository somut implementasyonu
///
/// SOLID-S (Single Responsibility):
/// Sadece PDF dosya seçme ve yükleme işlemlerinden sorumlu.
///
/// SOLID-L (Liskov Substitution):
/// IPdfRepository arayüzünü birebir uygular, her yerde yerine geçebilir.
class PdfRepositoryImpl implements IPdfRepository {
  PdfDocument? _currentDocument;

  @override
  Future<PdfDocumentModel?> pickAndLoadPdf() async {
    try {
      final filePath = await FileUtils.pickPdfFile();
      if (filePath == null) return null;

      return await loadPdfFromPath(filePath);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PdfDocumentModel?> loadPdfFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      // Önceki dokümanı temizle
      _currentDocument?.dispose();

      // pdfrx ile PDF dokümanını aç
      _currentDocument = await PdfDocument.openFile(filePath);

      return PdfDocumentModel.fromPath(
        filePath: filePath,
        totalPages: _currentDocument!.pages.length,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _currentDocument?.dispose();
    _currentDocument = null;
  }
}
