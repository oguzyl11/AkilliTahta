import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Renk paleti widget'ı — öğretmen çizim renkleri
class ColorPalette extends StatelessWidget {
  /// Aktif renk
  final Color activeColor;

  /// Renk seçildiğinde callback
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({
    super.key,
    required this.activeColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSizes.colorSwatchSpacing,
      runSpacing: AppSizes.colorSwatchSpacing,
      children: AppColors.drawingPalette.map((color) {
        final isActive = color.toARGB32() == activeColor.toARGB32();
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.animationFast),
            width: AppSizes.colorSwatchSize,
            height: AppSizes.colorSwatchSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 2.5 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            // Siyah renk için iç kenarlık ekle (görünürlük)
            child: color == Colors.black
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textHint,
                        width: 0.5,
                      ),
                    ),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
