import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/favorite_photo.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../auth/controllers/auth_controller.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

final favoritePhotosProvider = StreamProvider<List<FavoritePhoto>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(favoritesRepositoryProvider).watch();
});

final isFavoritePhotoProvider = Provider.family<bool, String>((ref, photoUrl) {
  final favorites = ref.watch(favoritePhotosProvider).valueOrNull ?? const [];
  return favorites.any((f) => f.photoUrl == photoUrl);
});

class FavoritesActions {
  FavoritesActions(this._repo);
  final FavoritesRepository _repo;

  Future<void> toggle(String photoUrl, {required bool currentlyFavorite}) {
    return currentlyFavorite ? _repo.remove(photoUrl) : _repo.add(photoUrl);
  }
}

final favoritesActionsProvider = Provider<FavoritesActions>((ref) {
  return FavoritesActions(ref.read(favoritesRepositoryProvider));
});
