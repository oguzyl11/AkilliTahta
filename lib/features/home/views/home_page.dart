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

  /// Üst başlık çubuğu (Premium Tasarım)
  Widget _buildHeaderBar(BuildContext context) {
    final pdfController = context.watch<PdfController>();
    final toolbarController = context.read<ToolbarController>();
    final drawingController = context.read<DrawingController>();

    return Container(
      height: 64, // Biraz daha ince ve zarif
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Sol: Menü + Başlık
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              tooltip: 'Menü',
              onPressed: toolbarController.toggleExpanded,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            AppStrings.appTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(),

          // Orta: PDF bilgisi
          if (pdfController.isLoaded) ...[
            // Dosya adı göstergesi
            Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Çok açık gri/mavi
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _formatFileName(pdfController.document!.fileName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Sayfa bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.find_in_page_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${pdfController.currentPage} / ${pdfController.totalPages}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Sağ: Temizle + Kütüphaneye Dön
          if (pdfController.isLoaded) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                tooltip: 'Sayfadaki Çizimleri Temizle',
                onPressed: drawingController.clearCurrentPage,
              ),
            ),
            const SizedBox(width: 12),
          ],
          ElevatedButton.icon(
            onPressed: () {
              pdfController.closePdf();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            label: const Text(
              'Kütüphane',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Bozuk veya uzun dosya adlarını düzeltip kırpmak için yardımcı metot
  String _formatFileName(String rawName) {
    if (rawName.contains('appBooksDir.path')) {
      return 'Bilinmeyen Kitap (Bozuk Dosya)';
    }
    if (rawName.endsWith('.pdf')) {
      return rawName.substring(0, rawName.length - 4);
    }
    return rawName;
  }
}
