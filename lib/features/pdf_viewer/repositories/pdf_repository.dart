import '../models/pdf_document_model.dart';

/// PDF repository soyut arayüzü
///
/// SOLID-D (Dependency Inversion) prensibi:
/// Controller'lar bu arayüze bağımlıdır, somut implementasyona değil.
/// Test sırasında mock implementasyon enjekte edilebilir.
///
/// SOLID-I (Interface Segregation) prensibi:
/// Sadece PDF ile ilgili operasyonları içerir.
abstract class IPdfRepository {
  /// Kullanıcıdan PDF dosyası seçmesini ister ve yükler.
  /// Başarılıysa [PdfDocumentModel] döndürür, iptal edilirse null.
  Future<PdfDocumentModel?> pickAndLoadPdf();

  /// Belirli bir yoldaki PDF dosyasını yükler.
  Future<PdfDocumentModel?> loadPdfFromPath(String filePath);

  /// Kaynakları serbest bırakır
  void dispose();
}
