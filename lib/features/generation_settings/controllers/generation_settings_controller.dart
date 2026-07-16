import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/generation_settings.dart';
import '../../../data/models/subscription.dart';
import '../../../data/repositories/generation_settings_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

final generationSettingsRepositoryProvider =
    Provider<GenerationSettingsRepository>((ref) {
      return GenerationSettingsRepository();
    });

final generationSettingsControllerProvider =
    AsyncNotifierProvider<GenerationSettingsController, GenerationSettings>(
      GenerationSettingsController.new,
    );

class GenerationSettingsController extends AsyncNotifier<GenerationSettings> {
  GenerationSettingsRepository get _repo =>
      ref.read(generationSettingsRepositoryProvider);

  @override
  Future<GenerationSettings> build() async {
    ref.watch(currentUserIdProvider);
    final settings = await _repo.fetch();
    final subscription = await ref.watch(subscriptionControllerProvider.future);
    final isFree = subscription.tier == SubscriptionTier.free;

    var effective = settings;
    if (isFree && effective.qualityPreset == QualityPreset.maximum) {
      effective = effective.copyWith(qualityPreset: QualityPreset.balanced);
    }
    if (isFree && effective.realism == RealismLevel.photoreal) {
      effective = effective.copyWith(realism: RealismLevel.stylized);
    }
    if (isFree && effective.similarity == SimilarityLevel.strict) {
      effective = effective.copyWith(similarity: SimilarityLevel.relaxed);
    }
    if (effective != settings) {
      await _repo.save(effective);
    }
    return effective;
  }

  Future<void> saveSettings(GenerationSettings settings) async {
    state = AsyncData(settings);
    await _repo.save(settings);
  }
}
