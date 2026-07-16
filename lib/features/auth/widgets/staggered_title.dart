import 'package:flutter/material.dart';

class StaggeredTitle extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const StaggeredTitle({super.key, required this.text, this.style});

  @override
  State<StaggeredTitle> createState() => _StaggeredTitleState();
}

class _StaggeredTitleState extends State<StaggeredTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const start = 0.15;
    const step = 0.05;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.text.length; i++)
              _letter(widget.text[i], i, start, step),
          ],
        );
      },
    );
  }

  Widget _letter(String ch, int i, double start, double step) {
    final eased = Curves.easeOut.transform(
      ((_controller.value - (start + i * step)) / 0.35).clamp(0.0, 1.0),
    );
    return Opacity(
      opacity: eased,
      child: Transform.translate(
        offset: Offset(0, (1 - eased) * 14),
        child: Text(ch == ' ' ? ' ' : ch, style: widget.style),
      ),
    );
  }
}
