import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../data/models/chat_message.dart';
import '../../../shared_widgets/shimmer_box.dart';
import 'image_result_grid.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? sourcePhotoUrl;
  final bool isPro;
  final VoidCallback? onRegenerate;
  final bool isRegenerating;

  const MessageBubble({
    super.key,
    required this.message,
    this.sourcePhotoUrl,
    this.isPro = false,
    this.onRegenerate,
    this.isRegenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.sm),
      bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.lg),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? colors.primaryContainer
                  : colors.surfaceContainerHigh,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: message.imageUrl!,
                      width: 200,
                      height: 200,
                      memCacheWidth: 400,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(
                        width: 200,
                        height: 200,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.md),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (message.content != null && message.content!.isNotEmpty)
                  Text(
                    message.content!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                    ),
                  ),
                if (message.type == MessageType.imageResult &&
                    message.resultUrls.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ImageResultGrid(
                    imageUrls: message.resultUrls,
                    sourcePhotoUrl: sourcePhotoUrl,
                    isPro: isPro,
                  ),
                  if (onRegenerate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TextButton.icon(
                      onPressed: isRegenerating ? null : onRegenerate,
                      icon: isRegenerating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(isRegenerating ? 'Генерирую…' : 'Повторить'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
