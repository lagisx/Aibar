import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class PromptInputBar extends StatefulWidget {
  final File? attachedPhoto;
  final VoidCallback onAttachPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onOpenStylePresets;
  final ValueChanged<String> onSend;
  final bool sending;

  const PromptInputBar({
    super.key,
    required this.attachedPhoto,
    required this.onAttachPhoto,
    required this.onRemovePhoto,
    required this.onOpenStylePresets,
    required this.onSend,
    required this.sending,
  });

  @override
  State<PromptInputBar> createState() => PromptInputBarState();
}

class PromptInputBarState extends State<PromptInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  void fillPrompt(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.attachedPhoto != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.sm),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.file(
                          widget.attachedPhoto!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: widget.onRemovePhoto,
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: colors.surface,
                            child: Icon(Icons.close, size: 14, color: colors.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_a_photo_outlined),
                        tooltip: 'Прикрепить фото',
                        onPressed: widget.sending ? null : widget.onAttachPhoto,
                      ),
                      IconButton(
                        icon: const Icon(Icons.style_outlined),
                        tooltip: 'Готовые стили',
                        onPressed: widget.sending ? null : widget.onOpenStylePresets,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Опишите причёску или бороду…',
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          ),
                        ),
                      ),
                      widget.sending
                          ? const Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton.filled(
                              icon: const Icon(Icons.arrow_upward),
                              onPressed: _handleSend,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
