import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class ToolMarquee extends StatefulWidget {
  final List<IconData> icons;
  final List<Color> colors;
  final List<String?>? imageAssets;
  final bool reverse;
  final Duration duration;

  const ToolMarquee({
    super.key,
    required this.icons,
    required this.colors,
    this.imageAssets,
    this.reverse = false,
    this.duration = const Duration(seconds: 22),
  });

  @override
  State<ToolMarquee> createState() => _ToolMarqueeState();
}

class _ToolMarqueeState extends State<ToolMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  static const double _tile = 140;
  static const double _gap = 20;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.icons.length;
    final unitWidth = (_tile + _gap) * count;
    const repeats = 3;
    final tiles = List.generate(count * repeats, (i) => i % count);

    return SizedBox(
      height: _tile,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dx = widget.reverse
                ? -unitWidth + _controller.value * unitWidth
                : -_controller.value * unitWidth;
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final i in tiles)
                  Padding(
                    padding: const EdgeInsets.only(right: _gap),
                    child: _ToolTile(
                      icon: widget.icons[i],
                      color: widget.colors[i % widget.colors.length],
                      imageAsset:
                          widget.imageAssets != null &&
                              i < widget.imageAssets!.length
                          ? widget.imageAssets![i]
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? imageAsset;

  const _ToolTile({required this.icon, required this.color, this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: imageAsset == null
          ? Icon(icon, color: color, size: 56)
          : Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(icon, color: color, size: 56),
            ),
    );
  }
}
