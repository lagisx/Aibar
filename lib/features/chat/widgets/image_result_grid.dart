import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../shared_widgets/shimmer_box.dart';
import 'fullscreen_image_gallery.dart';

// сетка сгенерированных вариантов причёски/бороды в ответе ассистента
class ImageResultGrid extends StatelessWidget {
  final List<String> imageUrls;

  const ImageResultGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () => _openFullscreen(context, index),
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      },
    );
  }

  void _openFullscreen(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageGallery(imageUrls: imageUrls, initialIndex: index),
      ),
    );
  }
}
