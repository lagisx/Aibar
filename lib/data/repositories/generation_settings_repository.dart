import '../../core/config/app_constants.dart';
import '../models/generation_settings.dart';
import '../services/supabase_service.dart';

class GenerationSettingsRepository {
  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<GenerationSettings> fetch() async {
    final row = await SupabaseService.client
        .from(AppConstants.generationSettingsTable)
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    if (row == null) return const GenerationSettings();
    return GenerationSettings.fromMap(row);
  }

  Future<void> save(GenerationSettings settings) async {
    await SupabaseService.client
        .from(AppConstants.generationSettingsTable)
        .upsert({'user_id': _userId, ...settings.toMap()});
  }
}
