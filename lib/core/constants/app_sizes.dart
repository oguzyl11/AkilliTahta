/// Uygulama boyut sabitleri — dokunmatik ekran optimizasyonlu
class AppSizes {
  AppSizes._();

  // Dokunmatik hedef boyutları (minimum 48px — Material Design)
  static const double touchTargetMin = 48.0;
  static const double touchTargetLarge = 56.0;
  static const double touchTargetXLarge = 64.0;

  // Araç çubuğu
  static const double toolbarWidth = 136.0;
  static const double toolbarIconSize = 28.0;
  static const double toolbarButtonSize = 52.0;

  // Üst başlık çubuğu
  static const double headerHeight = 56.0;

  // Padding ve margin
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 12.0;
  static const double paddingLG = 16.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  // Border radius
  static const double radiusSM = 6.0;
  static const double radiusMD = 10.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // Çizim araçları
  static const double brushSizeMin = 1.0;
  static const double brushSizeMax = 20.0;
  static const double brushSizeDefault = 3.0;
  static const double eraserSizeDefault = 20.0;
  static const double markerSizeDefault = 12.0;

  // Renk paleti
  static const double colorSwatchSize = 32.0;
  static const double colorSwatchSpacing = 6.0;

  // Animasyon süreleri (ms)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Modal
  static const double modalPadding = 24.0;
}
