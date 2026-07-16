import '../../core/config/app_constants.dart';
import '../../core/utils/network_retry.dart';
import '../services/supabase_service.dart';

class GenderRepository {
  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<String?> fetch() async {
    final row = await withRetry(
      () => SupabaseService.client
          .from(AppConstants.profilesTable)
          .select('gender')
          .eq('id', _userId)
          .maybeSingle(),
    );
    return row?['gender'] as String?;
  }

  Future<void> save(String gender) async {
    await withRetry(
      () => SupabaseService.client.from(AppConstants.profilesTable).upsert({
        'id': _userId,
        'gender': gender,
      }),
    );
  }
}
