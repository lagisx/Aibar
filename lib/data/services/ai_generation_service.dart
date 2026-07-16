import 'dart:async';

import 'supabase_service.dart';
import '../../core/config/app_constants.dart';
import '../models/generation_settings.dart';

class GenerationLimitExceededException implements Exception {
  final String message;
  GenerationLimitExceededException(this.message);

  @override
  String toString() => message;
}

class AiGenerationService {
  static const Duration _generationTimeout = Duration(minutes: 3);

  Future<void> requestGeneration({
    required String sourcePhotoUrl,
    required String promptText,
    required String messageId,
    required String sessionId,
    int variantCount = 1,
    GenerationSettings? settings,
  }) async {
    try {
      final response = await SupabaseService.client.functions
          .invoke(
            AppConstants.generateHairstyleFunction,
            body: {
              'source_photo_url': sourcePhotoUrl,
              'prompt_text': promptText,
              'message_id': messageId,
              'session_id': sessionId,
              'variant_count': variantCount,
              'settings': (settings ?? const GenerationSettings()).toMap(),
            },
          )
          .timeout(_generationTimeout);

      if (response.status == 429) {
        throw GenerationLimitExceededException(
          (response.data is Map && response.data['error'] != null)
              ? response.data['error'] as String
              : 'Лимит запросов исчерпан. Оформите подписку.',
        );
      }

      if (response.status != 200) {
        throw Exception(
          'Edge Function error (${response.status}): ${response.data}',
        );
      }
    } on GenerationLimitExceededException {
      rethrow;
    } on TimeoutException {
      throw Exception(
        'Генерация заняла слишком много времени. Попробуйте ещё раз.',
      );
    } catch (e) {
      throw Exception('Не удалось запустить генерацию: $e');
    }
  }

  Future<void> cancelGeneration(String messageId) async {
    await SupabaseService.client.functions.invoke(
      AppConstants.cancelGenerationFunction,
      body: {'message_id': messageId},
    );
  }
}
