import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/question_controller.dart';
import '../../drawing/views/drawing_canvas.dart';
import '../../drawing/controllers/drawing_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_icon_button.dart';

/// Soru büyütme modalı — tam ekran overlay
///
/// Seçili soru bölgesini büyütüp gösterir.
/// Üzerine çizim yapılabilir (DrawingCanvas embed).
/// ESC ile kapatılabilir.
class QuestionModal extends StatelessWidget {
  const QuestionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionController>(
      builder: (context, controller, child) {
        if (!controller.isModalOpen || controller.selectedQuestion == null) {
          return const SizedBox.shrink();
        }

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            // ESC ile kapat
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              controller.closeModal();
            }
          },
          child: Material(
            color: Colors.black87,
            child: Stack(
              children: [
                // Ana içerik — büyütülmüş soru bölgesi + çizim canvas
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.modalPadding),
                    child: Column(
                      children: [
                        // Üst bar
                        _buildTopBar(context, controller),
                        const SizedBox(height: AppSizes.paddingMD),

                        // Büyütülmüş alan — çizim yapılabilir
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLG),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLG),
                              child: Stack(
                                children: [
                                  // Arka plan — soru bölgesinin büyütülmüş hali
                                  // TODO: PDF sayfasının seçili bölgesini render et
                                  const Center(
                                    child: Text(
                                      'Soru bölgesi burada gösterilecek',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                  // Çizim katmanı
                                  Positioned.fill(
                                    child: ChangeNotifierProvider.value(
                                      value: context.read<DrawingController>(),
                                      child: const DrawingCanvas(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Üst kontrol çubuğu
  Widget _buildTopBar(BuildContext context, QuestionController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Başlık
        const Row(
          children: [
            Icon(Icons.zoom_in, color: AppColors.primary, size: 24),
            SizedBox(width: AppSizes.paddingSM),
            Text(
              AppStrings.soruBuyut,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Kapat butonu
        AppIconButton(
          icon: Icons.close,
          tooltip: AppStrings.kapat,
          onPressed: controller.closeModal,
        ),
      ],
    );
  }
}
