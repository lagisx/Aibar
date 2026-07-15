import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/error_translator.dart';
import '../../../data/services/image_picker_service.dart';
import '../../../routes/app_routes.dart';
import '../../../shared_widgets/app_drawer.dart';
import '../../style_presets/data/style_presets_data.dart';
import '../../style_presets/models/style_preset.dart';
import '../../style_presets/widgets/style_presets_sheet.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_skeleton_loader.dart';
import '../widgets/message_bubble.dart';
import '../widgets/prompt_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _imagePickerService = ImagePickerService();
  final _scrollController = ScrollController();
  final _promptBarKey = GlobalKey<PromptInputBarState>();
  File? _attachedPhoto;
  bool _sending = false;
  final Set<String> _selectedStyleIds = {};
  int _variantCount = 1;

  List<StylePreset> get _selectedStyles =>
      stylePresets.where((p) => _selectedStyleIds.contains(p.id)).toList();

  void _openStylePresets() {
    showStylePresetsSheet(
      context,
      selectedIds: _selectedStyleIds,
      variantCount: _variantCount,
      onVariantCountChanged: (count) => setState(() => _variantCount = count),
      onToggle: (preset) => setState(() {
        if (!_selectedStyleIds.remove(preset.id)) {
          _selectedStyleIds.add(preset.id);
        }
      }),
    );
  }

  // склеивает выбранные стили с текстом пользователя в единый запрос к ИИ
  String _composeFinalPrompt(String userPrompt) {
    final styles = _selectedStyles.map((p) => p.promptText).join(', ');
    if (styles.isEmpty) return userPrompt;
    return '$styles. $userPrompt';
  }

  Future<void> _attachPhoto() async {
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      builder: (context) => const _PhotoSourceSheet(),
    );
    if (source == null) return;

    final photo = source == _PhotoSource.camera
        ? await _imagePickerService.pickFromCamera()
        : await _imagePickerService.pickFromGallery();
    if (photo != null) setState(() => _attachedPhoto = photo);
  }

  Future<void> _send(String prompt) async {
    final photo = _attachedPhoto;
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала прикрепите фото')),
      );
      return;
    }

    // очищаем сразу — если не отправится, вернём текст и фото обратно
    setState(() {
      _sending = true;
      _attachedPhoto = null;
    });
    _scrollToBottom();

    final result = await ref.read(chatControllerProvider.notifier).sendPhotoWithPrompt(
          photo: photo,
          promptText: _composeFinalPrompt(prompt),
          variantCount: _variantCount,
        );

    if (!mounted) return;
    setState(() => _sending = false);

    if (!result.messageSent) {
      setState(() => _attachedPhoto = photo);
      _promptBarKey.currentState?.fillPrompt(prompt);
    }

    final error = result.error;
    if (error != null) {
      final isLimit = error.toLowerCase().contains('лимит');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          action: isLimit
              ? SnackBarAction(
                  label: 'Тарифы',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.paywall),
                )
              : null,
        ),
      );
    }
  }

  void _startNewChat() {
    ref.read(chatControllerProvider.notifier).startNewChat();
    setState(() => _selectedStyleIds.clear());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // новое сообщение (своё или ответ ИИ) — сразу прокручиваем вниз, иначе
    // кажется, что чат не обновился
    ref.listen(chatControllerProvider, (previous, next) {
      next.whenData((_) => _scrollToBottom());
    });
    final messagesAsync = ref.watch(chatControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('AI Hairstyle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Новый чат',
            onPressed: _startNewChat,
          ),
        ],
      ),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const _EmptyChatState();
                }
                final itemCount = messages.length + (_sending ? 1 : 0);
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const GeneratingBubble();
                    }
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
              loading: () => const ChatSkeletonLoader(),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(friendlyErrorMessage(error, context: 'chat', stackTrace: stackTrace)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(chatControllerProvider),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedStyleIds.isNotEmpty) _SelectedStylesRow(
                  styles: _selectedStyles,
                  onRemove: (preset) => setState(() => _selectedStyleIds.remove(preset.id)),
                ),
                PromptInputBar(
                  key: _promptBarKey,
                  attachedPhoto: _attachedPhoto,
                  onAttachPhoto: _attachPhoto,
                  onRemovePhoto: () => setState(() => _attachedPhoto = null),
                  onOpenStylePresets: _openStylePresets,
                  onSend: _send,
                  sending: _sending,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedStylesRow extends StatelessWidget {
  final List<StylePreset> styles;
  final ValueChanged<StylePreset> onRemove;

  const _SelectedStylesRow({required this.styles, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: styles.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
          itemBuilder: (context, index) {
            final preset = styles[index];
            return Chip(
              visualDensity: VisualDensity.compact,
              avatar: Icon(preset.icon, size: 16),
              label: Text(preset.title, style: const TextStyle(fontSize: 12)),
              onDeleted: () => onRemove(preset),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: colors.onPrimaryContainer, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Новый образ начинается здесь',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Прикрепите фото и опишите причёску или бороду — '
              'сгенерирую несколько вариантов.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PhotoSource { camera, gallery }

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Сделать фото'),
            onTap: () => Navigator.of(context).pop(_PhotoSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Выбрать из галереи'),
            onTap: () => Navigator.of(context).pop(_PhotoSource.gallery),
          ),
        ],
      ),
    );
  }
}
