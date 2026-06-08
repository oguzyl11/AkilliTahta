import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pdf_viewer/views/pdf_viewer_panel.dart';
import '../../toolbar/views/toolbar_panel.dart';
import '../../question/views/question_modal.dart';
import '../../pdf_viewer/controllers/pdf_controller.dart';
import '../../toolbar/controllers/toolbar_controller.dart';
import '../../drawing/controllers/drawing_controller.dart';
import '../../question/controllers/question_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_icon_button.dart';

/// Ana sayfa — uygulama layout orchestrator
///
/// Tüm ana bileşenleri bir araya getirir:
/// - Header bar (üst bilgi çubuğu)
/// - Toolbar (sol araç çubuğu)
/// - PDF Viewer (merkez alan)
/// - Question Modal (tam ekran overlay)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Toolbar başlangıç pozisyonu
  Offset _toolbarPosition = const Offset(16, 16);

  @override
  Widget build(BuildContext context) {
    final questionController = context.watch<QuestionController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ana layout
          Column(
            children: [
              // ─── Üst Başlık Çubuğu ───
              _buildHeaderBar(context),

              // ─── Gövde: Yüzen Toolbar + PDF Viewer ───
              Expanded(
                child: Stack(
                  children: [
                    // Merkez PDF görüntüleyici (Arka planda tüm alanı kaplar)
                    const Positioned.fill(
                      child: PdfViewerPanel(),
                    ),

                    // Soru Büyütme Ekranı (Tüm ekranı kaplar, pdf'in üstünde ama araçların altında)
                    if (questionController.isModalOpen)
                      const Positioned.fill(
                        child: QuestionModal(),
                      ),

                    // Yüzen, sürüklenebilir araç çubuğu (Kutu)
                    Positioned(
                      left: _toolbarPosition.dx,
                      top: _toolbarPosition.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _toolbarPosition += details.delta;
                          });
                        },
                        child: const ToolbarPanel(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Üst başlık çubuğu
  Widget _buildHeaderBar(BuildContext context) {
    final pdfController = context.watch<PdfController>();
    final toolbarController = context.read<ToolbarController>();
    final drawingController = context.read<DrawingController>();

    return Container(
      height: AppSizes.headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
      child: Row(
        children: [
          // Sol: Menü + Başlık
          AppIconButton(
            icon: Icons.menu,
            tooltip: 'Menü',
            onPressed: toolbarController.toggleExpanded,
          ),
          const SizedBox(width: AppSizes.paddingSM),
          const Text(
            AppStrings.appTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSM,
              vertical: AppSizes.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Spacer(),

          // Orta: PDF bilgisi
          if (pdfController.isLoaded) ...[
            // Dosya adı
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMD,
                vertical: AppSizes.paddingSM,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Text(
                    pdfController.document!.fileName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingMD),

            // Sayfa bilgisi
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMD,
                vertical: AppSizes.paddingSM,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                '${AppStrings.sayfaBilgisi}: ${pdfController.currentPage} / ${pdfController.totalPages}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMD),
          ],

          // Sağ: Temizle + PDF Yükle
          if (pdfController.isLoaded)
            AppIconButton(
              icon: Icons.delete_outline,
              tooltip: AppStrings.temizle,
              onPressed: drawingController.clearCurrentPage,
            ),
          const SizedBox(width: AppSizes.paddingSM),
          ElevatedButton.icon(
            onPressed:
                pdfController.isLoading ? null : pdfController.pickAndLoadPdf,
            icon: const Icon(Icons.upload_file, size: 18),
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
}
