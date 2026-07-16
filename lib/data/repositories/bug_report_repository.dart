import '../../core/config/app_constants.dart';
import '../../core/utils/network_retry.dart';
import '../services/supabase_service.dart';

class BugReportRepository {
  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<void> submit(String message) async {
    await withRetry(
      () => SupabaseService.client.from(AppConstants.bugReportsTable).insert({
        'user_id': _userId,
        'message': message,
      }),
    );
  }
}
