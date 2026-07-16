import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_translator.dart';
import '../../../core/utils/photo_downloader.dart';
import '../../../data/services/local_notification_service.dart';
import '../../../shared_widgets/pro_upsell_dialog.dart';
import '../../favorites/controllers/favorites_controller.dart';
import 'before_after_slider.dart';

class FullscreenImageGallery extends ConsumerStatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? sourcePhotoUrl;
  final bool isPro;

  const FullscreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.sourcePhotoUrl,
    this.isPro = false,
  });

  @override
  ConsumerState<FullscreenImageGallery> createState() =>
      _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState
    extends ConsumerState<FullscreenImageGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  void _goTo(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await downloadPhotoToGallery(widget.imageUrls[_currentIndex]);
      LocalNotificationService.showDownloadComplete();
    } catch (e, stackTrace) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            friendlyErrorMessage(
              e,
              context: 'download_fullscreen',
              stackTrace: stackTrace,
            ),
          ),
        ),
      );
    }
  }

  void _openCompare() {
    final sourceUrl = widget.sourcePhotoUrl;
    if (sourceUrl == null) return;
    if (!widget.isPro) {
      showProUpsellDialog(
        context,
        message: 'Сравнение "До/После" доступно на подписке Pro и выше.',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BeforeAfterSlider(
          beforeUrl: sourceUrl,
          afterUrl: widget.imageUrls[_currentIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;
    final currentUrl = widget.imageUrls[_currentIndex];
    final isFavorite = ref.watch(isFavoritePhotoProvider(currentUrl));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: hasMultiple
            ? Text('${_currentIndex + 1} / ${widget.imageUrls.length}')
            : null,
        actions: [
          if (widget.sourcePhotoUrl != null)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              tooltip: 'До / После',
              onPressed: _openCompare,
            ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Скачать',
            onPressed: _download,
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            tooltip: 'Избранное',
            onPressed: () => ref
                .read(favoritesActionsProvider)
                .toggle(currentUrl, currentlyFavorite: isFavorite),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Center(
              child: InteractiveViewer(
                child: Image.network(widget.imageUrls[index]),
              ),
            ),
          ),
          if (hasMultiple && _currentIndex > 0)
            Positioned(
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () => _goTo(_currentIndex - 1),
              ),
            ),
          if (hasMultiple && _currentIndex < widget.imageUrls.length - 1)
            Positioned(
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 36,
                ),
                onPressed: () => _goTo(_currentIndex + 1),
              ),
            ),
        ],
      ),
    );
  }
}
