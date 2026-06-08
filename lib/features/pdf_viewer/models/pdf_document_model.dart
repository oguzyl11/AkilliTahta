/// PDF doküman veri modeli
///
/// Yüklenen bir PDF dosyasının temel bilgilerini tutar.
class PdfDocumentModel {
  /// Dosyanın disk üzerindeki tam yolu
  final String filePath;

  /// Dosya adı (uzantısız)
  final String fileName;

  /// Toplam sayfa sayısı
  final int totalPages;

  const PdfDocumentModel({
    required this.filePath,
    required this.fileName,
    required this.totalPages,
  });

  /// Dosya adından uzantıyı çıkararak model oluşturur
  factory PdfDocumentModel.fromPath({
    required String filePath,
    required int totalPages,
  }) {
    final fileName = filePath.split(RegExp(r'[\\/]')).last.replaceAll('.pdf', '');
    return PdfDocumentModel(
      filePath: filePath,
      fileName: fileName,
      totalPages: totalPages,
    );
  }

  @override
  String toString() => 'PdfDocumentModel(fileName: $fileName, totalPages: $totalPages)';
}
