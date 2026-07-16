import '../../core/config/app_constants.dart';
import '../../core/utils/network_retry.dart';
import '../services/supabase_service.dart';

class AppTourRepository {
  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<bool> fetch() async {
    final row = await withRetry(
      () => SupabaseService.client
          .from(AppConstants.profilesTable)
          .select('tour_completed')
          .eq('id', _userId)
          .maybeSingle(),
    );
    return row?['tour_completed'] as bool? ?? false;
  }

  Future<void> markCompleted() async {
    await withRetry(
      () => SupabaseService.client.from(AppConstants.profilesTable).upsert({
        'id': _userId,
        'tour_completed': true,
      }),
    );
  }
}
