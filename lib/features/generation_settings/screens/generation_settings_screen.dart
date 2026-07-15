import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/error_translator.dart';
import '../../../data/models/generation_settings.dart';
import '../../../data/models/subscription.dart';
import '../../../routes/app_routes.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../controllers/generation_settings_controller.dart';

class GenerationSettingsScreen extends ConsumerWidget {
  const GenerationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);
    final settingsAsync = ref.watch(generationSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки генерации')),
      body: settingsAsync.when(
        data: (settings) {
          final isFree = subscriptionAsync.valueOrNull?.tier == SubscriptionTier.free;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (isFree)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _UpsellBanner(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.paywall),
                  ),
                ),
              _LevelSetting(
                label: 'Сила изменений',
                value: settings.changeIntensity,
                strongLocked: isFree,
                onChanged: (level) => ref
                    .read(generationSettingsControllerProvider.notifier)
                    .saveSettings(settings.copyWith(changeIntensity: level)),
              ),
              _LevelSetting(
                label: 'Сохранение лица',
                value: settings.facePreservation,
                onChanged: (level) => ref
                    .read(generationSettingsControllerProvider.notifier)
                    .saveSettings(settings.copyWith(facePreservation: level)),
              ),
              _LevelSetting(
                label: 'Реалистичность',
                value: settings.realism,
                onChanged: (level) => ref
                    .read(generationSettingsControllerProvider.notifier)
                    .saveSettings(settings.copyWith(realism: level)),
              ),
              _LevelSetting(
                label: 'Уровень детализации',
                value: settings.detailLevel,
                onChanged: (level) => ref
                    .read(generationSettingsControllerProvider.notifier)
                    .saveSettings(settings.copyWith(detailLevel: level)),
              ),
              _LevelSetting(
                label: 'Соответствие исходному фото',
                value: settings.similarityToOriginal,
                onChanged: (level) => ref
                    .read(generationSettingsControllerProvider.notifier)
                    .saveSettings(settings.copyWith(similarityToOriginal: level)),
              ),
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Параметры пока сохраняются, но не влияют на результат — '
                  'подключим при переходе на модель с их поддержкой.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(friendlyErrorMessage(error, context: 'generation_settings', stackTrace: stackTrace)),
        ),
      ),
    );
  }
}

class _UpsellBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _UpsellBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'На Free доступны не все уровни. Оформите Pro, чтобы снять ограничения.',
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelSetting extends StatelessWidget {
  final String label;
  final IntensityLevel value;
  final ValueChanged<IntensityLevel> onChanged;
  final bool strongLocked;

  const _LevelSetting({
    required this.label,
    required this.value,
    required this.onChanged,
    this.strongLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<IntensityLevel>(
            segments: [
              const ButtonSegment(value: IntensityLevel.weak, label: Text('Слабо')),
              const ButtonSegment(value: IntensityLevel.standard, label: Text('Стандарт')),
              ButtonSegment(
                value: IntensityLevel.strong,
                label: const Text('Сильно'),
                enabled: !strongLocked,
                icon: strongLocked ? const Icon(Icons.lock_outline, size: 14) : null,
              ),
            ],
            selected: {value},
            onSelectionChanged: (selection) {
              final selected = selection.first;
              if (selected == IntensityLevel.strong && strongLocked) return;
              onChanged(selected);
            },
          ),
        ],
      ),
    );
  }
}
