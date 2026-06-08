import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pdf_viewer/controllers/pdf_controller.dart';
import 'features/library/views/library_screen.dart';
import 'features/home/views/home_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final isPdfLoaded = context.watch<PdfController>().isLoaded;

    if (isPdfLoaded) {
      // PDF açıksa okuma/çizim ekranına geç
      return const HomePage();
    }

    // Aksi halde kütüphane ekranı
    return const LibraryScreen();
  }
}
