import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../pdf_viewer/controllers/pdf_controller.dart';
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
            color: Colors.white,
            child: Column(
              children: [
                // Üst bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLG,
                    vertical: AppSizes.paddingMD,
                  ),
                  child: _buildTopBar(context, controller),
                ),

                // Büyütülmüş alan — çizim yapılabilir (arka planda)
                Expanded(
                  child: _buildCroppedPdfRegion(context, controller),
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

  /// PDF sayfasının sadece seçilen "Soru" (bounds) bölgesini kırparak (crop) gösterir
  Widget _buildCroppedPdfRegion(BuildContext context, QuestionController controller) {
    final pdfController = context.read<PdfController>();
    final documentModel = pdfController.document;
    final question = controller.selectedQuestion;

    if (documentModel == null || question == null) {
      return const Center(child: Text('PDF veya Soru yüklenemedi.'));
    }

    final bounds = question.bounds;
    
    return PdfDocumentViewBuilder.file(
      pdfController.currentFilePath!,
      builder: (context, doc) {
        if (doc == null) return const Center(child: CircularProgressIndicator());
        
        final page = doc.pages[question.pageNumber - 1];
        
        // Gerçek PDF sayfasının boyutları
        final pageWidth = page.width;
        final pageHeight = page.height;

        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = constraints.maxWidth;
            final canvasHeight = constraints.maxHeight;

            // Seçilen bölgenin orijinaldeki piksel boyutu ve en-boy oranı
            final croppedWidth = pageWidth * bounds.width;
            final croppedHeight = pageHeight * bounds.height;
            final cropAspectRatio = croppedWidth / croppedHeight;

            // Ekrana ne kadar büyük çizeceğiz? (Tuvalin %85'ine sığdıralım)
            final maxWidth = canvasWidth * 0.85;
            final maxHeight = canvasHeight * 0.85;

            double displayWidth = maxWidth;
            double displayHeight = displayWidth / cropAspectRatio;
            if (displayHeight > maxHeight) {
              displayHeight = maxHeight;
              displayWidth = displayHeight * cropAspectRatio;
            }

            // Büyütülmüş resim "displayWidth" boyutunda olacak.
            // Orijinal PDF'in tamamının boyutu bu büyütme oranında ne olmalı?
            final fullPageWidth = displayWidth / bounds.width;
            final fullPageHeight = displayHeight / bounds.height;

            return Stack(
              children: [
                // Tüm modalı kaplayan BEYAZ tahta
                Container(color: Colors.white),

                // Ortaya yerleştirilen Kırpılmış Soru Görseli
                Center(
                  child: Container(
                    width: displayWidth,
                    height: displayHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Positioned(
                            left: -bounds.left * fullPageWidth,
                            top: -bounds.top * fullPageHeight,
                            width: fullPageWidth,
                            height: fullPageHeight,
                            child: PdfPageView(
                              document: doc,
                              pageNumber: question.pageNumber,
                              alignment: Alignment.topLeft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Çizim katmanı (En üstte, tüm beyaz ekranı kaplar)
                Positioned.fill(
                  child: ChangeNotifierProvider.value(
                    value: context.read<DrawingController>(),
                    child: const DrawingCanvas(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
