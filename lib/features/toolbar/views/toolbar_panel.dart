import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/toolbar_controller.dart';
import '../../drawing/models/drawing_tool_model.dart';
import '../../drawing/controllers/drawing_controller.dart';
import '../../pdf_viewer/controllers/pdf_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_icon_button.dart';
import 'widgets/color_palette.dart';
import 'widgets/brush_size_slider.dart';

/// Sol araç çubuğu paneli
///
/// Çizim araçları, renk paleti, fırça boyutu ve sayfa navigasyonunu içerir.
/// Dokunmatik ekran için optimize edilmiş büyük butonlar.
class ToolbarPanel extends StatelessWidget {
  const ToolbarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolbarController>(
      builder: (context, toolbar, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.animationNormal),
          width: toolbar.isExpanded ? AppSizes.toolbarWidth : 0,
          decoration: const BoxDecoration(
            color: AppColors.toolbarBackground,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: toolbar.isExpanded
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMD,
                    horizontal: AppSizes.paddingSM,
                  ),
                  child: Column(
                    children: [
                      // ─── Çizim Araçları ───
                      _buildSectionLabel('ARAÇLAR'),
                      const SizedBox(height: AppSizes.paddingSM),
                      _buildToolButtons(toolbar),

                      const SizedBox(height: AppSizes.paddingLG),
                      const Divider(),
                      const SizedBox(height: AppSizes.paddingLG),

                      // ─── Renk Paleti ───
                      _buildSectionLabel(AppStrings.renkler),
                      const SizedBox(height: AppSizes.paddingSM),
                      ColorPalette(
                        activeColor: toolbar.activeColor,
                        onColorSelected: toolbar.selectColor,
                      ),

                      const SizedBox(height: AppSizes.paddingLG),
                      const Divider(),
                      const SizedBox(height: AppSizes.paddingLG),

                      // ─── Fırça Boyutu ───
                      _buildSectionLabel(AppStrings.kalinlik),
                      const SizedBox(height: AppSizes.paddingSM),
                      BrushSizeSlider(
                        value: toolbar.brushSize,
                        onChanged: toolbar.changeBrushSize,
                      ),

                      const SizedBox(height: AppSizes.paddingLG),
                      const Divider(),
                      const SizedBox(height: AppSizes.paddingLG),

                      // ─── Undo / Redo ───
                      _buildUndoRedoButtons(context),

                      const SizedBox(height: AppSizes.paddingLG),
                      const Divider(),
                      const SizedBox(height: AppSizes.paddingLG),

                      // ─── Sayfa Navigasyonu ───
                      _buildPageNavigation(context),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textHint,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildToolButtons(ToolbarController toolbar) {
    return Wrap(
      spacing: AppSizes.paddingXS,
      runSpacing: AppSizes.paddingXS,
      children: [
        AppIconButton(
          icon: Icons.edit,
          tooltip: AppStrings.kalem,
          isActive: toolbar.activeToolType == ToolType.pen,
          onPressed: () => toolbar.selectTool(ToolType.pen),
        ),
        AppIconButton(
          icon: Icons.brush,
          tooltip: AppStrings.marker,
          isActive: toolbar.activeToolType == ToolType.marker,
          onPressed: () => toolbar.selectTool(ToolType.marker),
        ),
        AppIconButton(
          icon: Icons.auto_fix_high,
          tooltip: AppStrings.silgi,
          isActive: toolbar.activeToolType == ToolType.eraser,
          onPressed: () => toolbar.selectTool(ToolType.eraser),
        ),
        AppIconButton(
          icon: Icons.crop_free,
          tooltip: AppStrings.sec,
          isActive: toolbar.activeToolType == ToolType.select,
          onPressed: () => toolbar.selectTool(ToolType.select),
        ),
      ],
    );
  }

  Widget _buildUndoRedoButtons(BuildContext context) {
    final drawing = context.watch<DrawingController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconButton(
          icon: Icons.undo,
          tooltip: AppStrings.geriAl,
          onPressed: drawing.canUndo ? drawing.undo : () {},
        ),
        const SizedBox(width: AppSizes.paddingXS),
        AppIconButton(
          icon: Icons.redo,
          tooltip: AppStrings.ileriAl,
          onPressed: drawing.canRedo ? drawing.redo : () {},
        ),
      ],
    );
  }

  Widget _buildPageNavigation(BuildContext context) {
    final pdf = context.watch<PdfController>();
    if (!pdf.isLoaded) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSectionLabel(AppStrings.sayfaBilgisi),
        const SizedBox(height: AppSizes.paddingSM),
        Text(
          '${pdf.currentPage} / ${pdf.totalPages}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSM),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconButton(
              icon: Icons.chevron_left,
              tooltip: AppStrings.oncekiSayfa,
              onPressed: pdf.canGoPrevious ? pdf.previousPage : () {},
            ),
            const SizedBox(width: AppSizes.paddingXS),
            AppIconButton(
              icon: Icons.chevron_right,
              tooltip: AppStrings.sonrakiSayfa,
              onPressed: pdf.canGoNext ? pdf.nextPage : () {},
            ),
          ],
        ),
      ],
    );
  }
}
