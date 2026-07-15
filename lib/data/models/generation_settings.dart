enum IntensityLevel { weak, standard, strong }

IntensityLevel _levelFromString(String value) {
  return IntensityLevel.values.firstWhere(
    (l) => l.name == value,
    orElse: () => IntensityLevel.standard,
  );
}

class GenerationSettings {
  final IntensityLevel changeIntensity;
  final IntensityLevel facePreservation;
  final IntensityLevel realism;
  final IntensityLevel detailLevel;
  final IntensityLevel similarityToOriginal;

  const GenerationSettings({
    this.changeIntensity = IntensityLevel.standard,
    this.facePreservation = IntensityLevel.standard,
    this.realism = IntensityLevel.standard,
    this.detailLevel = IntensityLevel.standard,
    this.similarityToOriginal = IntensityLevel.standard,
  });

  factory GenerationSettings.fromMap(Map<String, dynamic> map) {
    return GenerationSettings(
      changeIntensity: _levelFromString(map['change_intensity'] as String),
      facePreservation: _levelFromString(map['face_preservation'] as String),
      realism: _levelFromString(map['realism'] as String),
      detailLevel: _levelFromString(map['detail_level'] as String),
      similarityToOriginal: _levelFromString(map['similarity_to_original'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'change_intensity': changeIntensity.name,
        'face_preservation': facePreservation.name,
        'realism': realism.name,
        'detail_level': detailLevel.name,
        'similarity_to_original': similarityToOriginal.name,
      };

  GenerationSettings copyWith({
    IntensityLevel? changeIntensity,
    IntensityLevel? facePreservation,
    IntensityLevel? realism,
    IntensityLevel? detailLevel,
    IntensityLevel? similarityToOriginal,
  }) {
    return GenerationSettings(
      changeIntensity: changeIntensity ?? this.changeIntensity,
      facePreservation: facePreservation ?? this.facePreservation,
      realism: realism ?? this.realism,
      detailLevel: detailLevel ?? this.detailLevel,
      similarityToOriginal: similarityToOriginal ?? this.similarityToOriginal,
    );
  }
}
