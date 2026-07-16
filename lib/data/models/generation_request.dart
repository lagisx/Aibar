enum GenerationStatus { pending, done, failed }

GenerationStatus _statusFromString(String value) {
  return GenerationStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => GenerationStatus.pending,
  );
}

class GenerationRequest {
  final String id;
  final String userId;
  final String? messageId;
  final String promptText;
  final String sourcePhotoUrl;
  final List<String> resultUrls;
  final GenerationStatus status;
  final DateTime createdAt;

  const GenerationRequest({
    required this.id,
    required this.userId,
    this.messageId,
    required this.promptText,
    required this.sourcePhotoUrl,
    this.resultUrls = const [],
    required this.status,
    required this.createdAt,
  });

  factory GenerationRequest.fromMap(Map<String, dynamic> map) {
    return GenerationRequest(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      messageId: map['message_id'] as String?,
      promptText: map['prompt_text'] as String,
      sourcePhotoUrl: map['source_photo_url'] as String,
      resultUrls:
          (map['result_urls'] as List?)?.map((e) => e as String).toList() ??
          const [],
      status: _statusFromString(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
