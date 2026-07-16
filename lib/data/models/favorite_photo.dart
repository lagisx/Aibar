class FavoritePhoto {
  final String id;
  final String photoUrl;
  final DateTime createdAt;

  const FavoritePhoto({
    required this.id,
    required this.photoUrl,
    required this.createdAt,
  });

  factory FavoritePhoto.fromMap(Map<String, dynamic> map) => FavoritePhoto(
    id: map['id'] as String,
    photoUrl: map['photo_url'] as String,
    createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
  );
}
