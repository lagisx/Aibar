import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/error_translator.dart';
import '../../../core/utils/photo_downloader.dart';
import '../../../data/services/local_notification_service.dart';
import '../../../shared_widgets/shimmer_box.dart';
import '../../chat/widgets/fullscreen_image_gallery.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritePhotosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_border,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Тут появятся фото, которые вы добавите в избранное из результатов генерации.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          final urls = favorites.map((f) => f.photoUrl).toList();
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final photo = favorites[index];
              return _FavoriteTile(
                photoUrl: photo.photoUrl,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageGallery(
                      imageUrls: urls,
                      initialIndex: index,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            friendlyErrorMessage(
              error,
              context: 'favorites',
              stackTrace: stackTrace,
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final String photoUrl;
  final VoidCallback onOpen;

  const _FavoriteTile({required this.photoUrl, required this.onOpen});

  Future<void> _download(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await downloadPhotoToGallery(photoUrl);
      LocalNotificationService.showDownloadComplete();
    } catch (e, stackTrace) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            friendlyErrorMessage(
              e,
              context: 'download_favorite',
              stackTrace: stackTrace,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: GestureDetector(
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              memCacheWidth: 400,
              placeholder: (context, url) => const ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image_outlined),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.download_outlined,
                    onTap: () => _download(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _RoundIconButton(
                    icon: Icons.close,
                    onTap: () => ref
                        .read(favoritesActionsProvider)
                        .toggle(photoUrl, currentlyFavorite: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
