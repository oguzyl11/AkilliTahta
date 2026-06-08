import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../models/book_model.dart';
import '../../../pdf_viewer/controllers/pdf_controller.dart';
import '../../controllers/library_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class BookItem extends StatelessWidget {
  final BookModel book;

  const BookItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<LibraryController>().isAdmin;
    
    return GestureDetector(
      onTap: () async {
        // Kitaba tıklandığında PDF'i aç
        final pdfController = context.read<PdfController>();
        await pdfController.loadPdf(book.filePath);
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kitap Kapağı (PDF'in 1. Sayfası)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMD)),
                        child: _buildCover(),
                      ),
                    ),
                    // Kitap Başlığı
                    Container(
                      height: 56, // Sabit yükseklik
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusMD)),
                      ),
                      child: Center(
                        child: Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Kitap cilt efekti (sol gölge)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusMD),
                        bottomLeft: Radius.circular(AppSizes.radiusMD),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Cilt çizgisi
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  width: 1,
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ],
            ),
          ),
          
          // Silme Butonu (Sadece Admin)
          if (isAdmin)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  // Onay iste ve sil
                  _showDeleteConfirm(context);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    return PdfDocumentViewBuilder.file(
      book.filePath,
      builder: (context, document) {
        if (document == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return PdfPageView(
          document: document,
          pageNumber: 1,
          alignment: Alignment.center,
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kitabı Sil'),
        content: Text('"${book.title}" silinecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<LibraryController>().deleteBook(book.id);
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
