import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Fırça boyutu slider widget'ı
///
/// Dikey slider ile fırça kalınlığını ayarlar.
/// Mevcut kalınlık görsel önizleme ile gösterilir.
class BrushSizeSlider extends StatelessWidget {
  /// Mevcut boyut değeri
  final double value;

  /// Değer değiştiğinde callback
  final ValueChanged<double> onChanged;

  const BrushSizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Boyut önizleme — mevcut kalınlıkta daire
        Container(
          width: AppSizes.toolbarButtonSize,
          height: AppSizes.toolbarButtonSize,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.animationFast),
            width: value.clamp(4.0, 24.0),
            height: value.clamp(4.0, 24.0),
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Slider
        SizedBox(
          width: AppSizes.toolbarWidth - AppSizes.paddingSM * 2,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value,
              min: AppSizes.brushSizeMin,
              max: AppSizes.brushSizeMax,
              onChanged: onChanged,
            ),
          ),
        ),

        // Sayısal gösterge
        Text(
          '${value.toStringAsFixed(0)}px',
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
