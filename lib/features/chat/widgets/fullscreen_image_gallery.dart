import 'package:flutter/material.dart';

// свайп или кнопки влево/вправо для перелистывания результатов генерации
class FullscreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageGallery> createState() => _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState extends State<FullscreenImageGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
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

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: hasMultiple
            ? Text('${_currentIndex + 1} / ${widget.imageUrls.length}')
            : null,
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
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 36),
                onPressed: () => _goTo(_currentIndex - 1),
              ),
            ),
          if (hasMultiple && _currentIndex < widget.imageUrls.length - 1)
            Positioned(
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 36),
                onPressed: () => _goTo(_currentIndex + 1),
              ),
            ),
        ],
      ),
    );
  }
}
