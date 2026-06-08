import 'dart:ui';

/// Soru bölgesi veri modeli
///
/// Kullanıcının PDF sayfasından rubber-band ile seçtiği bölgeyi temsil eder.
class QuestionModel {
  /// Benzersiz kimlik
  final String id;

  /// Hangi PDF sayfasında
  final int pageNumber;

  /// Seçili bölge (normalize edilmiş koordinatlar: 0.0-1.0)
  final Rect bounds;

  /// Oluşturulma zamanı
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.pageNumber,
    required this.bounds,
    required this.createdAt,
  });

  /// Yeni soru oluştur
  factory QuestionModel.create({
    required int pageNumber,
    required Rect bounds,
  }) {
    return QuestionModel(
      id: '${pageNumber}_${DateTime.now().millisecondsSinceEpoch}',
      pageNumber: pageNumber,
      bounds: bounds,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'QuestionModel(id: $id, page: $pageNumber, bounds: $bounds)';
}
