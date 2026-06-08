import 'package:get_it/get_it.dart';
import '../../features/pdf_viewer/repositories/pdf_repository.dart';
import '../../features/pdf_viewer/repositories/pdf_repository_impl.dart';
import '../../features/pdf_viewer/controllers/pdf_controller.dart';
import '../../features/drawing/controllers/drawing_controller.dart';
import '../../features/toolbar/controllers/toolbar_controller.dart';
import '../../features/question/controllers/question_controller.dart';
import '../../features/library/repositories/library_repository.dart';
import '../../features/library/controllers/library_controller.dart';

/// Dependency Injection kurulumu — get_it service locator
///
/// SOLID-D (Dependency Inversion) prensibi:
/// Controller'lar somut sınıflara değil, soyut arayüzlere bağımlıdır.
/// Bu sayede test sırasında mock implementasyonlar kolayca enjekte edilebilir.
final GetIt getIt = GetIt.instance;

/// Tüm bağımlılıkları kaydet
void setupServiceLocator() {
  // ─── Repositories (Singleton) ───
  // Soyutlama (abstract) üzerinden kayıt — SOLID-D
  getIt.registerLazySingleton<IPdfRepository>(
    () => PdfRepositoryImpl(),
  );

  getIt.registerLazySingleton<LibraryRepository>(
    () => LibraryRepository(),
  );

  // ─── Controllers (Factory — her erişimde yeni instance) ───
  getIt.registerLazySingleton<PdfController>(
    () => PdfController(pdfRepository: getIt<IPdfRepository>()),
  );

  getIt.registerLazySingleton<LibraryController>(
    () => LibraryController(getIt<LibraryRepository>()),
  );

  getIt.registerLazySingleton<DrawingController>(
    () => DrawingController(),
  );

  getIt.registerLazySingleton<ToolbarController>(
    () => ToolbarController(drawingController: getIt<DrawingController>()),
  );

  getIt.registerLazySingleton<QuestionController>(
    () => QuestionController(),
  );
}
