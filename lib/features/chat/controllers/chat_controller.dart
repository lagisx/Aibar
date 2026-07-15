import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_translator.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/chat_session.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/ai_generation_service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatSessionsProvider = StreamProvider<List<ChatSession>>((ref) {
  return ref.watch(chatRepositoryProvider).watchSessions();
});

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, List<ChatMessage>>(
        ChatController.new);

// currentSessionId == null значит "новый чат" — его ещё нет в chat_sessions.
class ChatController extends AsyncNotifier<List<ChatMessage>> {
  String? _sessionId;
  StreamSubscription<ChatMessage>? _subscription;

  String? get currentSessionId => _sessionId;

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  @override
  Future<List<ChatMessage>> build() async {
    ref.onDispose(() => _subscription?.cancel());

    // при запуске открываем последний чат, а не пустой экран
    final lastSession = await _repo.fetchMostRecentSession();
    if (lastSession == null) return [];

    _sessionId = lastSession.id;
    final messages = await _repo.fetchMessages(lastSession.id);
    _listenForNewMessages(lastSession.id);
    return messages;
  }

  void startNewChat() {
    _subscription?.cancel();
    _sessionId = null;
    state = const AsyncData([]);
  }

  Future<void> openSession(String sessionId) async {
    _subscription?.cancel();
    _sessionId = sessionId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchMessages(sessionId));
    _listenForNewMessages(sessionId);
  }

  Future<void> deleteSession(String sessionId) async {
    await _repo.deleteSession(sessionId);
    if (_sessionId == sessionId) {
      startNewChat();
    }
  }

  Future<void> renameSession(String sessionId, String newTitle) {
    return _repo.renameSession(sessionId, newTitle);
  }

  void _listenForNewMessages(String sessionId) {
    _subscription = _repo.watchNewMessages(sessionId).listen((message) {
      final current = state.valueOrNull ?? [];
      if (current.any((m) => m.id == message.id)) return;
      state = AsyncData([...current, message]);
    });
  }

  // сначала сохраняем и сразу показываем сообщение пользователя, и только
  // потом (отдельно) ждём ответ ИИ — чтобы отправка не выглядела зависанием.
  // messageSent говорит вызывающей стороне, нужно ли вернуть текст/фото в
  // поле ввода: false — ничего не отправилось, true — сообщение уже видно
  // в чате, откатывать поле ввода нельзя (иначе будет дубль при повторной отправке)
  Future<({bool messageSent, String? error})> sendPhotoWithPrompt({
    required File photo,
    required String promptText,
    int variantCount = 1,
  }) async {
    final wasNewSession = _sessionId == null;
    final ({String sessionId, ChatMessage message, String sourcePhotoUrl}) sent;
    try {
      sent = await _repo.sendUserMessage(
        photo: photo,
        promptText: promptText,
        sessionId: _sessionId,
      );
    } catch (e, stackTrace) {
      return (
        messageSent: false,
        error: friendlyErrorMessage(e, context: 'send_user_message', stackTrace: stackTrace),
      );
    }

    if (wasNewSession) {
      _sessionId = sent.sessionId;
      _listenForNewMessages(sent.sessionId);
    }

    final current = state.valueOrNull ?? [];
    if (!current.any((m) => m.id == sent.message.id)) {
      state = AsyncData([...current, sent.message]);
    }

    try {
      await _repo.requestGeneration(
        sourcePhotoUrl: sent.sourcePhotoUrl,
        promptText: promptText,
        messageId: sent.message.id,
        sessionId: sent.sessionId,
        variantCount: variantCount,
      );
      return (messageSent: true, error: null);
    } on GenerationLimitExceededException catch (e) {
      return (messageSent: true, error: e.message);
    } catch (e, stackTrace) {
      return (
        messageSent: true,
        error: friendlyErrorMessage(e, context: 'generation', stackTrace: stackTrace),
      );
    }
  }
}
