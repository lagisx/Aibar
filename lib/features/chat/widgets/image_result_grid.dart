import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_translator.dart';
import '../../../core/utils/photo_downloader.dart';
import '../../../data/services/local_notification_service.dart';
import '../../../shared_widgets/pro_upsell_dialog.dart';
import '../../../shared_widgets/shimmer_box.dart';
import '../../favorites/controllers/favorites_controller.dart';
import 'before_after_slider.dart';
import 'fullscreen_image_gallery.dart';

class ImageResultGrid extends ConsumerWidget {
  final List<String> imageUrls;
  final String? sourcePhotoUrl;
  final bool isPro;

  const ImageResultGrid({
    super.key,
    required this.imageUrls,
    this.sourcePhotoUrl,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final url = imageUrls[index];
        final isFavorite = ref.watch(isFavoritePhotoProvider(url));
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => _openFullscreen(context, index),
                child: CachedNetworkImage(
                  imageUrl: url,
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
              ),
              if (sourcePhotoUrl != null)
                Positioned(
                  left: 4,
                  top: 4,
                  child: _RoundIconButton(
                    icon: Icons.compare_arrows,
                    onTap: () => _openCompare(context, url),
                  ),
                ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoundIconButton(
                      icon: Icons.download_outlined,
                      onTap: () => _download(context, url),
                    ),
                    const SizedBox(width: 4),
                    _RoundIconButton(
                      icon: isFavorite ? Icons.star : Icons.star_border,
                      onTap: () => ref
                          .read(favoritesActionsProvider)
                          .toggle(url, currentlyFavorite: isFavorite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openFullscreen(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageGallery(
          imageUrls: imageUrls,
          initialIndex: index,
          sourcePhotoUrl: sourcePhotoUrl,
          isPro: isPro,
        ),
      ),
    );
  }

  void _openCompare(BuildContext context, String resultUrl) {
    if (!isPro) {
      showProUpsellDialog(
        context,
        message: 'Сравнение "До/После" доступно на подписке Pro и выше.',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BeforeAfterSlider(beforeUrl: sourcePhotoUrl!, afterUrl: resultUrl),
      ),
    );
  }

  Future<void> _download(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await downloadPhotoToGallery(url);
      LocalNotificationService.showDownloadComplete();
    } catch (e, stackTrace) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            friendlyErrorMessage(
              e,
              context: 'download_result',
              stackTrace: stackTrace,
            ),
          ),
        ),
      );
    }
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
