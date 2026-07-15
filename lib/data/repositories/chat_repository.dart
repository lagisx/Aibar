import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/config/app_constants.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/ai_generation_service.dart';
import '../services/supabase_service.dart';

class ChatRepository {
  final AiGenerationService _aiGenerationService = AiGenerationService();
  final _uuid = const Uuid();

  static const int messagePageSize = 50;
  static const Duration _queryTimeout = Duration(seconds: 20);

  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Stream<List<ChatSession>> watchSessions() {
    return SupabaseService.client
        .from(AppConstants.chatSessionsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('last_message_at', ascending: false)
        .map((rows) => rows.map(ChatSession.fromMap).toList());
  }

  // чтобы при запуске приложения открывался последний чат, а не пустой экран
  Future<ChatSession?> fetchMostRecentSession() async {
    final rows = await SupabaseService.client
        .from(AppConstants.chatSessionsTable)
        .select()
        .eq('user_id', _userId)
        .order('last_message_at', ascending: false)
        .limit(1)
        .timeout(_queryTimeout);
    if (rows.isEmpty) return null;
    return ChatSession.fromMap(rows.first);
  }

  // грузит последнюю страницу сообщений; передайте before для более старой страницы
  Future<List<ChatMessage>> fetchMessages(
    String sessionId, {
    DateTime? before,
  }) async {
    var query = SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .select()
        .eq('session_id', sessionId);

    if (before != null) {
      query = query.lt('created_at', before.toIso8601String());
    }

    final rows = await query
        .order('created_at', ascending: false)
        .limit(messagePageSize)
        .timeout(_queryTimeout);

    return (rows as List)
        .map((row) => ChatMessage.fromMap(row as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  // chat_messages удалятся каскадом (FK on delete cascade из миграции 0003)
  Future<void> deleteSession(String sessionId) async {
    await SupabaseService.client
        .from(AppConstants.chatSessionsTable)
        .delete()
        .eq('id', sessionId)
        .timeout(_queryTimeout);
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    await SupabaseService.client
        .from(AppConstants.chatSessionsTable)
        .update({'title': newTitle})
        .eq('id', sessionId)
        .timeout(_queryTimeout);
  }

  Stream<ChatMessage> watchNewMessages(String sessionId) {
    final seenIds = <String>{};
    return SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at')
        .map((rows) => rows.map(ChatMessage.fromMap).toList())
        .expand((messages) => messages)
        .where((message) => seenIds.add(message.id));
  }

  Future<String> uploadSourcePhoto(File photo) async {
    final path = '$_userId/${_uuid.v4()}.jpg';
    await SupabaseService.client.storage
        .from(AppConstants.sourcePhotosBucket)
        .upload(path, photo)
        .timeout(_queryTimeout);
    return SupabaseService.client.storage
        .from(AppConstants.sourcePhotosBucket)
        .getPublicUrl(path);
  }

  Future<ChatSession> _createSession(String firstPromptText) async {
    const maxTitleLength = 60;
    final title = firstPromptText.length > maxTitleLength
        ? '${firstPromptText.substring(0, maxTitleLength)}…'
        : firstPromptText;

    final row = await SupabaseService.client
        .from(AppConstants.chatSessionsTable)
        .insert({'user_id': _userId, 'title': title})
        .select()
        .single()
        .timeout(_queryTimeout);
    return ChatSession.fromMap(row);
  }

  // сохраняет сообщение пользователя и сразу возвращает его — не ждёт ответа ИИ,
  // поэтому свою же реплику видно в чате мгновенно, а не через realtime-подписку
  Future<({String sessionId, ChatMessage message, String sourcePhotoUrl})>
      sendUserMessage({
    required File photo,
    required String promptText,
    String? sessionId,
  }) async {
    final session = sessionId ?? (await _createSession(promptText)).id;
    final photoUrl = await uploadSourcePhoto(photo);

    final messageRow = await SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .insert({
          'user_id': _userId,
          'session_id': session,
          'role': 'user',
          'type': 'image_prompt',
          'content': promptText,
          'image_url': photoUrl,
        })
        .select()
        .single()
        .timeout(_queryTimeout);

    await SupabaseService.client
        .from(AppConstants.generationRequestsTable)
        .insert({
          'user_id': _userId,
          'message_id': messageRow['id'],
          'prompt_text': promptText,
          'source_photo_url': photoUrl,
          'status': 'pending',
        })
        .timeout(_queryTimeout);

    return (
      sessionId: session,
      message: ChatMessage.fromMap(messageRow),
      sourcePhotoUrl: photoUrl,
    );
  }

  // отдельно от sendUserMessage — сама генерация может идти долго (Replicate)
  Future<void> requestGeneration({
    required String sourcePhotoUrl,
    required String promptText,
    required String messageId,
    required String sessionId,
    int variantCount = 1,
  }) {
    return _aiGenerationService.requestGeneration(
      sourcePhotoUrl: sourcePhotoUrl,
      promptText: promptText,
      messageId: messageId,
      sessionId: sessionId,
      variantCount: variantCount,
    );
  }
}
