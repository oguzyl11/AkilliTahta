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
  late PageController _pageController;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pdfController = context.watch<PdfController>();
    
    // Eğer toolbar'dan sayfa değiştirildiyse PageView'i animasyonla kaydır
    if (pdfController.isLoaded && 
        pdfController.currentPage != _lastPage && 
        _pageController.hasClients) {
      _lastPage = pdfController.currentPage;
      // Mikro gecikme (rebuild çakışmasını önlemek için)
      Future.microtask(() {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _lastPage - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

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
          if (pdfController.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Text(
                pdfController.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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

  /// PDF görüntüleyici (PageView ile sayfa sayfa geçiş efekti)
  Widget _buildPdfView(PdfController pdfController) {
    final drawingController = context.read<DrawingController>();
    final questionController = context.read<QuestionController>();

    return PdfDocumentViewBuilder.file(
      pdfController.currentFilePath!,
      builder: (context, doc) {
        if (doc == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Eğer belge yeni yüklendiyse PageController initial sayfasını ayarla
        if (!_pageController.hasClients || _pageController.positions.isEmpty) {
          _pageController = PageController(initialPage: pdfController.currentPage - 1);
          _lastPage = pdfController.currentPage;
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: doc.pages.length,
          onPageChanged: (index) {
            final pageNum = index + 1;
            if (_lastPage != pageNum) {
              _lastPage = pageNum;
              pdfController.goToPage(pageNum);
              drawingController.setActivePageNumber(pageNum);
            }
          },
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final page = doc.pages[index];

            return Center(
              child: InteractiveViewer(
                maxScale: 5.0,
                minScale: 1.0,
                panEnabled: false, // 1 parmak çizim/seçim için kapalı, 2 parmakla kaydırma çalışır
                scaleEnabled: true, // 2 parmak yakınlaştırma açık
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: page.width / page.height,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Katman 1: PDF Sayfası
                          PdfPageView(
                            document: doc,
                            pageNumber: pageNum,
                            alignment: Alignment.center,
                          ),
                          
                          // Dinamik Katmanlar: Çizim veya Seçim
                          Positioned.fill(
                            child: Selector<DrawingController, bool>(
                              selector: (_, ctrl) => ctrl.currentTool.isSelect,
                              builder: (_, isSelectMode, __) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (!isSelectMode)
                                      ChangeNotifierProvider.value(
                                        value: drawingController,
                                        child: DrawingCanvas(pageNumber: pageNum),
                                      ),
                                    if (isSelectMode)
                                      ChangeNotifierProvider.value(
                                        value: questionController,
                                        child: question_widgets.SelectionOverlay(
                                          pageNumber: pageNum,
                                          pageSize: Size(page.width, page.height),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
