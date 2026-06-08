import 'package:file_picker/file_picker.dart';

/// Dosya işlemleri yardımcı fonksiyonları
class FileUtils {
  FileUtils._();

  /// PDF dosyası seçme dialog'u aç
  /// Başarılıysa dosya yolunu döndürür, iptal edilirse null döner.
  static Future<String?> pickPdfFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'PDF Dosyası Seçin',
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      // Dosya seçme hatası — null döndür, çağıran taraf handle eder
      return null;
    }
  }
}
