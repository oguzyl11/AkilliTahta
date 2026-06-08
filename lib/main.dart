import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

/// Uygulama giriş noktası
///
/// 1. Flutter binding'leri başlat
/// 2. pdfrx için geçici klasörü ayarla
/// 3. Dependency Injection (get_it) kayıtlarını yap
/// 4. Uygulamayı çalıştır
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // pdfrx önbellek klasörünü (cache directory) ayarla
  Pdfrx.getCacheDirectory = () async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  };

  // Tüm bağımlılıkları kaydet (SOLID-D)
  setupServiceLocator();

  runApp(const AkilliTahtaApp());
}
