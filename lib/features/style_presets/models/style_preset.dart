import 'package:flutter/material.dart';

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
