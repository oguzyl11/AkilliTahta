import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Dokunmatik uyumlu ikon buton — akıllı tahta için 48px+ boyut
///
/// Aktif/pasif state göstergesi, hover animasyonu ve tooltip içerir.
class AppIconButton extends StatelessWidget {
  /// Buton ikonu
  final IconData icon;

  /// Tooltip metni (Türkçe)
  final String tooltip;

  /// Tıklama callback'i
  final VoidCallback onPressed;

  /// Aktif mi (seçili araç gibi)
  final bool isActive;

  /// Buton boyutu
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
    this.size = AppSizes.toolbarButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppSizes.animationFast),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.buttonActive.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isActive ? AppColors.buttonActive : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            hoverColor: AppColors.buttonHover,
            splashColor: AppColors.buttonPressed,
            child: Center(
              child: Icon(
                icon,
                size: AppSizes.toolbarIconSize,
                color: isActive
                    ? AppColors.buttonActive
                    : AppColors.toolbarInactive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
