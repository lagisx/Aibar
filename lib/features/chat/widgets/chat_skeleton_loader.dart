import 'package:flutter/material.dart';

import '../../../shared_widgets/shimmer_box.dart';

// заглушки вместо сообщений, пока грузится история чата
class ChatSkeletonLoader extends StatelessWidget {
  const ChatSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      children: const [
        _SkeletonBubble(alignRight: false, width: 220),
        _SkeletonBubble(alignRight: true, width: 150),
        _SkeletonBubble(alignRight: false, width: 240),
        _SkeletonBubble(alignRight: false, width: 180),
      ],
    );
  }
}

// такая же заглушка одной строкой — показываем внизу списка, пока ждём ответ ИИ
class GeneratingBubble extends StatelessWidget {
  const GeneratingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShimmerBox(width: 90, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
            const SizedBox(width: 8),
            Text(
              'Генерирую варианты…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBubble extends StatelessWidget {
  final bool alignRight;
  final double width;

  const _SkeletonBubble({required this.alignRight, required this.width});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ShimmerBox(
          width: width,
          height: 44,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
