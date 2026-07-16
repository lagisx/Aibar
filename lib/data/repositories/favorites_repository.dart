import '../../core/config/app_constants.dart';
import '../../core/utils/network_retry.dart';
import '../models/favorite_photo.dart';
import '../services/supabase_service.dart';

class FavoritesRepository {
  static const Duration _timeout = Duration(seconds: 30);

  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Stream<List<FavoritePhoto>> watch() {
    return withStreamRetry(
      () => SupabaseService.client
          .from(AppConstants.favoritePhotosTable)
          .stream(primaryKey: ['id'])
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .map((rows) => rows.map(FavoritePhoto.fromMap).toList()),
    );
  }

  Future<void> add(String photoUrl) {
    return withRetry(
      () => SupabaseService.client
          .from(AppConstants.favoritePhotosTable)
          .upsert({
            'user_id': _userId,
            'photo_url': photoUrl,
          }, onConflict: 'user_id,photo_url')
          .timeout(_timeout),
    );
  }

  Future<void> remove(String photoUrl) {
    return withRetry(
      () => SupabaseService.client
          .from(AppConstants.favoritePhotosTable)
          .delete()
          .eq('user_id', _userId)
          .eq('photo_url', photoUrl)
          .timeout(_timeout),
    );
  }
}
