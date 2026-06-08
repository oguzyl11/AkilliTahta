import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/question_controller.dart';
import '../../../../core/constants/app_colors.dart';

/// Rubber-band bölge seçim overlay'i
///
/// Kullanıcı dokunarak/sürükleyerek bir bölge seçer (soru seçimi için).
/// Seçim tamamlandığında QuestionController'a bildirilir.
class SelectionOverlay extends StatelessWidget {
  /// Hangi PDF sayfasında seçim yapılıyor
  final int pageNumber;

  /// Sayfanın piksel boyutu
  final Size pageSize;

  const SelectionOverlay({
    super.key,
    required this.pageNumber,
    required this.pageSize,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestionController>();

    return GestureDetector(
      onPanStart: (details) {
        controller.startSelection(details.localPosition);
      },
      onPanUpdate: (details) {
        controller.updateSelection(details.localPosition);
      },
      onPanEnd: (_) {
        controller.endSelection(pageNumber, pageSize);
      },
      child: Stack(
        children: [
          // Yarı saydam arka plan — seçim modunu görsel olarak belirt
          Container(
            color: AppColors.primary.withValues(alpha: 0.05),
          ),

          // Seçim dikdörtgeni
          if (controller.isSelecting && controller.selectionRect != null)
            Positioned.fromRect(
              rect: controller.selectionRect!,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.zoom_in,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
