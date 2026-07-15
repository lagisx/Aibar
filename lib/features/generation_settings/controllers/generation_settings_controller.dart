import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/generation_settings.dart';
import '../../../data/repositories/generation_settings_repository.dart';

final generationSettingsRepositoryProvider =
    Provider<GenerationSettingsRepository>((ref) {
  return GenerationSettingsRepository();
});

final generationSettingsControllerProvider =
    AsyncNotifierProvider<GenerationSettingsController, GenerationSettings>(
        GenerationSettingsController.new);

class GenerationSettingsController extends AsyncNotifier<GenerationSettings> {
  GenerationSettingsRepository get _repo =>
      ref.read(generationSettingsRepositoryProvider);

  @override
  Future<GenerationSettings> build() => _repo.fetch();

  Future<void> saveSettings(GenerationSettings settings) async {
    state = AsyncData(settings);
    await _repo.save(settings);
  }
}
