enum QualityPreset { fast, balanced, maximum }

enum RealismLevel { stylized, photoreal }

enum SimilarityLevel { relaxed, strict }

QualityPreset _presetFromString(String value) {
  return QualityPreset.values.firstWhere(
    (p) => p.name == value,
    orElse: () => QualityPreset.balanced,
  );
}

RealismLevel _realismFromString(String value) {
  return RealismLevel.values.firstWhere(
    (r) => r.name == value,
    orElse: () => RealismLevel.photoreal,
  );
}

SimilarityLevel _similarityFromString(String value) {
  return SimilarityLevel.values.firstWhere(
    (s) => s.name == value,
    orElse: () => SimilarityLevel.strict,
  );
}

class GenerationSettings {
  final QualityPreset qualityPreset;
  final RealismLevel realism;
  final SimilarityLevel similarity;

  const GenerationSettings({
    this.qualityPreset = QualityPreset.balanced,
    this.realism = RealismLevel.photoreal,
    this.similarity = SimilarityLevel.strict,
  });

  factory GenerationSettings.fromMap(Map<String, dynamic> map) {
    return GenerationSettings(
      qualityPreset: _presetFromString(map['quality_preset'] as String),
      realism: _realismFromString(map['realism'] as String? ?? 'photoreal'),
      similarity: _similarityFromString(
        map['similarity'] as String? ?? 'strict',
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'quality_preset': qualityPreset.name,
    'realism': realism.name,
    'similarity': similarity.name,
  };

  GenerationSettings copyWith({
    QualityPreset? qualityPreset,
    RealismLevel? realism,
    SimilarityLevel? similarity,
  }) {
    return GenerationSettings(
      qualityPreset: qualityPreset ?? this.qualityPreset,
      realism: realism ?? this.realism,
      similarity: similarity ?? this.similarity,
    );
  }
}
