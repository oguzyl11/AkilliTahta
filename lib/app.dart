import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'features/home/views/home_page.dart';
import 'features/pdf_viewer/controllers/pdf_controller.dart';
import 'features/drawing/controllers/drawing_controller.dart';
import 'features/toolbar/controllers/toolbar_controller.dart';
import 'features/question/controllers/question_controller.dart';

/// Ana uygulama widget'ı
///
/// MultiProvider ile tüm controller'ları widget ağacına sağlar.
/// Koyu tema ve Türkçe arayüz ayarlarını içerir.
class AkilliTahtaApp extends StatelessWidget {
  const AkilliTahtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // PDF controller — PDF yükleme ve sayfa navigasyonu
        ChangeNotifierProvider<PdfController>.value(
          value: getIt<PdfController>(),
        ),
        // Çizim controller — çizim state ve undo/redo
        ChangeNotifierProvider<DrawingController>.value(
          value: getIt<DrawingController>(),
        ),
        // Araç çubuğu controller — araç seçimi state
        ChangeNotifierProvider<ToolbarController>.value(
          value: getIt<ToolbarController>(),
        ),
        // Soru controller — soru seçim ve modal state
        ChangeNotifierProvider<QuestionController>.value(
          value: getIt<QuestionController>(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
