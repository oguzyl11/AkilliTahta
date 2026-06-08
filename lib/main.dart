import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

/// Uygulama giriş noktası
///
/// 1. Flutter binding'leri başlat
/// 2. Dependency Injection (get_it) kayıtlarını yap
/// 3. Uygulamayı çalıştır
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Tüm bağımlılıkları kaydet (SOLID-D)
  setupServiceLocator();

  runApp(const AkilliTahtaApp());
}
