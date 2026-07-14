import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/ai_generation_service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, List<ChatMessage>>(
        ChatController.new);

class ChatController extends AsyncNotifier<List<ChatMessage>> {
  StreamSubscription<ChatMessage>? _subscription;

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() => _subscription?.cancel());
    final history = await _repo.fetchHistory();
    _listenForNewMessages();
    return history;
  }

  void _listenForNewMessages() {
    _subscription?.cancel();
    _subscription = _repo.watchNewMessages().listen((message) {
      final current = state.valueOrNull ?? [];
      if (current.any((m) => m.id == message.id)) return;
      state = AsyncData([...current, message]);
    });
  }

  Future<String?> sendPhotoWithPrompt({
    required File photo,
    required String promptText,
  }) async {
    try {
      await _repo.sendGenerationRequest(photo: photo, promptText: promptText);
      return null;
    } on GenerationLimitExceededException catch (e) {
      return e.message;
    } catch (e) {
      return 'Не удалось отправить запрос: $e';
    }
  }
}
