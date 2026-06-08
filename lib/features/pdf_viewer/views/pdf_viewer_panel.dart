import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';
import '../controllers/pdf_controller.dart';
import '../../drawing/views/drawing_canvas.dart';
import '../../drawing/controllers/drawing_controller.dart';
import '../../question/controllers/question_controller.dart';
import '../../question/views/widgets/selection_overlay.dart' as question_widgets;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// PDF görüntüleyici paneli
///
/// pdfrx ile PDF sayfalarını render eder.
/// Üzerine DrawingCanvas ve SelectionOverlay bindirme katmanları ekler.
/// Tek sayfa modunda çalışır (slide), sayfalar arası geçiş butonlarla yapılır.
class PdfViewerPanel extends StatefulWidget {
  const PdfViewerPanel({super.key});

  @override
  State<PdfViewerPanel> createState() => _PdfViewerPanelState();
}

class _PdfViewerPanelState extends State<PdfViewerPanel> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfController>(
      builder: (context, pdfController, child) {
        // PDF yüklenmemişse boş ekran göster
        if (!pdfController.isLoaded || pdfController.currentFilePath == null) {
          return _buildEmptyState(pdfController);
        }

        return _buildPdfView(pdfController);
      },
    );
  }

  /// PDF yüklenmemişken gösterilen boş ekran
  Widget _buildEmptyState(PdfController pdfController) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // İkon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 56,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.bosluk,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: pdfController.isLoading
                ? null
                : pdfController.pickAndLoadPdf,
            icon: const Icon(Icons.upload_file),
            label: Text(
              pdfController.isLoading
                  ? AppStrings.pdfYukleniyor
                  : AppStrings.pdfYukle,
            ),
          ),
        ],
      ),
    );
  }

  /// PDF görüntüleyici
  Widget _buildPdfView(PdfController pdfController) {
    final drawingController = context.read<DrawingController>();
    final questionController = context.read<QuestionController>();
    final isSelectMode = context.watch<DrawingController>().currentTool.isSelect;

    return PdfViewer.file(
      pdfController.currentFilePath!,
      controller: _pdfViewerController,
      params: PdfViewerParams(
        pageOverlaysBuilder: (context, pageRect, page) {
          // Her PDF sayfası üzerine çizim ve seçim katmanı ekle
          return [
            // Katman 2: Çizim canvas'ı
            if (!isSelectMode)
              Positioned.fill(
                child: ChangeNotifierProvider.value(
                  value: drawingController,
                  child: const DrawingCanvas(),
                ),
              ),

            // Katman 3: Seçim overlay'i (sadece seçim modunda)
            if (isSelectMode)
              Positioned.fill(
                child: ChangeNotifierProvider.value(
                  value: questionController,
                  child: question_widgets.SelectionOverlay(
                    pageNumber: page.pageNumber,
                    pageSize: Size(pageRect.width, pageRect.height),
                  ),
                ),
              ),
          ];
        },
        onPageChanged: (pageNumber) {
          if (pageNumber != null) {
            pdfController.goToPage(pageNumber);
            drawingController.setActivePageNumber(pageNumber);
          }
        },
      ),
    );
  }
}
