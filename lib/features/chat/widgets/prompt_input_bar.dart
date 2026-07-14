import 'dart:io';

import 'package:flutter/material.dart';

class PromptInputBar extends StatefulWidget {
  final File? attachedPhoto;
  final VoidCallback onAttachPhoto;
  final VoidCallback onRemovePhoto;
  final ValueChanged<String> onSend;
  final bool sending;

  const PromptInputBar({
    super.key,
    required this.attachedPhoto,
    required this.onAttachPhoto,
    required this.onRemovePhoto,
    required this.onSend,
    required this.sending,
  });

  @override
  State<PromptInputBar> createState() => _PromptInputBarState();
}

class _PromptInputBarState extends State<PromptInputBar> {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.attachedPhoto != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                        child: IconButton(
                          icon: const Icon(Icons.cancel, size: 20),
                          onPressed: widget.onRemovePhoto,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onPressed: widget.sending ? null : widget.onAttachPhoto,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Опишите желаемую стрижку/бороду...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                widget.sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
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
          ],
        ),
      ),
    );
  }
}
