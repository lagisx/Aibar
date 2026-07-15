import 'package:flutter/material.dart';

// один пресет причёски/бороды: иконка-заглушка (пока нет реальных фото-примеров)
// плюс текст-модификатор, который добавляется к промпту пользователя.
// conflictGroup — пресеты с одинаковой непустой группой нельзя выбрать
// вместе (например, "короткая стрижка" и "длинные волосы" оба про длину)
class StylePreset {
  final String id;
  final String title;
  final String promptText;
  final IconData icon;
  final List<Color> gradient;
  final String? conflictGroup;

  const StylePreset({
    required this.id,
    required this.title,
    required this.promptText,
    required this.icon,
    required this.gradient,
    this.conflictGroup,
  });
}
