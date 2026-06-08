import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/library_controller.dart';
import 'widgets/book_item.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryController = context.watch<LibraryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, libraryController),
          if (libraryController.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildBody(context, libraryController),
        ],
      ),
      floatingActionButton: libraryController.isAdmin
          ? FloatingActionButton.extended(
              onPressed: libraryController.addBook,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Kitap Yükle', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context, LibraryController controller) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: const Text(
          'E-Kütüphane',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Color(0xFF1E3A8A)], // Darker blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.auto_stories,
                  size: 200,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                controller.isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Admin',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Switch(
                value: controller.isAdmin,
                onChanged: (_) => controller.toggleAdmin(),
                activeColor: Colors.white,
                activeTrackColor: Colors.greenAccent,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.black26,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, LibraryController controller) {
    if (controller.books.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'Kütüphaneniz şu an boş.',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yeni kitap eklemek için Admin modunu açabilirsiniz.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // Daha fazla kitap sığsın
          childAspectRatio: 0.7, // Kapak oranı
          crossAxisSpacing: 24,
          mainAxisSpacing: 32,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = controller.books[index];
            return BookItem(book: book);
          },
          childCount: controller.books.length,
        ),
      ),
    );
  }
}
