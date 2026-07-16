import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeUrl;
  final String afterUrl;

  const BeforeAfterSlider({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _position = 0.5;

  void _updatePosition(double dx, double width) {
    setState(() => _position = (dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('До / После'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onHorizontalDragUpdate: (details) =>
                  _updatePosition(details.localPosition.dx, width),
              onTapDown: (details) =>
                  _updatePosition(details.localPosition.dx, width),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.afterUrl,
                    fit: BoxFit.contain,
                  ),
                  ClipRect(
                    clipper: _BeforeClipper(_position),
                    child: CachedNetworkImage(
                      imageUrl: widget.beforeUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: width * _position - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white),
                  ),
                  Positioned(
                    left: (width * _position - 18).clamp(0.0, width - 36),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.compare_arrows,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    top: 12,
                    child: _CornerLabel(text: 'До'),
                  ),
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: _CornerLabel(text: 'После'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  final String text;
  const _CornerLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _BeforeClipper extends CustomClipper<Rect> {
  final double position;
  _BeforeClipper(this.position);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * position, size.height);

  @override
  bool shouldReclip(covariant _BeforeClipper oldClipper) =>
      oldClipper.position != position;
}
