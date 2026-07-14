import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/config/app_constants.dart';
import '../models/chat_message.dart';
import '../services/ai_generation_service.dart';
import '../services/supabase_service.dart';

class ChatRepository {
  final AiGenerationService _aiGenerationService = AiGenerationService();
  final _uuid = const Uuid();

  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<List<ChatMessage>> fetchHistory({int limit = 100}) async {
    final rows = await SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .select()
        .eq('user_id', _userId)
        .order('created_at')
        .limit(limit);

    return (rows as List)
        .map((row) => ChatMessage.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Subscribes to new rows inserted into `chat_messages` for the current
  /// user, so assistant replies show up in the chat as soon as the
  /// `generate-hairstyle` Edge Function writes them.
  Stream<ChatMessage> watchNewMessages() {
    final seenIds = <String>{};
    return SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at')
        .map((rows) => rows.map(ChatMessage.fromMap).toList())
        .expand((messages) => messages)
        .where((message) => seenIds.add(message.id));
  }

  Future<String> uploadSourcePhoto(File photo) async {
    final path = '$_userId/${_uuid.v4()}.jpg';
    await SupabaseService.client.storage
        .from(AppConstants.sourcePhotosBucket)
        .upload(path, photo);
    return SupabaseService.client.storage
        .from(AppConstants.sourcePhotosBucket)
        .getPublicUrl(path);
  }

  /// Sends the user's photo + prompt: creates the `chat_messages` /
  /// `generation_requests` rows and triggers the `generate-hairstyle`
  /// Edge Function, which does the actual AI call server-side.
  Future<void> sendGenerationRequest({
    required File photo,
    required String promptText,
  }) async {
    final photoUrl = await uploadSourcePhoto(photo);

    final messageRow = await SupabaseService.client
        .from(AppConstants.chatMessagesTable)
        .insert({
          'user_id': _userId,
          'role': 'user',
          'type': 'image_prompt',
          'content': promptText,
          'image_url': photoUrl,
        })
        .select()
        .single();

    await SupabaseService.client.from(AppConstants.generationRequestsTable).insert({
      'user_id': _userId,
      'message_id': messageRow['id'],
      'prompt_text': promptText,
      'source_photo_url': photoUrl,
      'status': 'pending',
    });

    await _aiGenerationService.requestGeneration(
      sourcePhotoUrl: photoUrl,
      promptText: promptText,
      messageId: messageRow['id'] as String,
    );
  }
}
