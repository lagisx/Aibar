import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/style_presets_data.dart';
import '../models/style_preset.dart';

const int maxSelectedStyles = 3;

Future<void> showStylePresetsSheet(
  BuildContext context, {
  required Set<String> selectedIds,
  required void Function(StylePreset preset) onToggle,
  required int variantCount,
  required ValueChanged<int> onVariantCountChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      var localVariantCount = variantCount;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          void handleToggle(StylePreset preset) {
            final alreadySelected = selectedIds.contains(preset.id);
            if (!alreadySelected) {
              if (selectedIds.length >= maxSelectedStyles) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Можно выбрать не больше $maxSelectedStyles стилей',
                    ),
                  ),
                );
                return;
              }
              final conflicting = preset.conflictGroup == null
                  ? const <StylePreset>[]
                  : stylePresets
                        .where(
                          (p) =>
                              selectedIds.contains(p.id) &&
                              p.conflictGroup == preset.conflictGroup,
                        )
                        .toList();
              final conflict = conflicting.isEmpty ? null : conflicting.first;
              if (conflict != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Нельзя сочетать «${conflict.title}» и «${preset.title}»',
                    ),
                  ),
                );
                return;
              }
            }
            onToggle(preset);
            setSheetState(() {});
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Готовые стили',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Готово'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    'Выберите до $maxSelectedStyles сочетаемых стилей — они добавятся к вашему запросу',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ImageCountSelector(
                  value: localVariantCount,
                  onChanged: (count) {
                    setSheetState(() => localVariantCount = count);
                    onVariantCountChanged(count);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: stylePresets.length,
                    itemBuilder: (context, index) {
                      final preset = stylePresets[index];
                      return _StylePresetCard(
                        preset: preset,
                        selected: selectedIds.contains(preset.id),
                        onTap: () => handleToggle(preset),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ImageCountSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ImageCountSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Количество изображений',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                  ],
                  selected: {value},
                  onSelectionChanged: (selection) => onChanged(selection.first),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StylePresetCard extends StatelessWidget {
  final StylePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _StylePresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: preset.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: selected ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(preset.icon, color: Colors.white, size: 32),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      preset.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Icon(Icons.check_circle, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
