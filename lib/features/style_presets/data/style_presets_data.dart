import 'package:flutter/material.dart';

import '../models/style_preset.dart';

// заглушки вместо реальных фото-примеров результата — когда появятся
// сгенерированные образцы, замените gradient/icon на настоящее imageUrl
// в StylePreset (после того как решим завести туда это поле)
const List<StylePreset> stylePresets = [
  StylePreset(
    id: 'short_haircut',
    title: 'Короткая стрижка',
    promptText: 'короткая аккуратная мужская стрижка',
    icon: Icons.content_cut,
    gradient: [Color(0xFF6C4DF6), Color(0xFF9C7BFF)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'classic_part',
    title: 'Классический пробор',
    promptText: 'классическая стрижка с боковым пробором',
    icon: Icons.man_outlined,
    gradient: [Color(0xFF20B486), Color(0xFF6FE0BB)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'afro',
    title: 'Афро',
    promptText: 'объёмная стрижка афро',
    icon: Icons.face,
    gradient: [Color(0xFFE0662E), Color(0xFFFFA166)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'long_hair',
    title: 'Длинные волосы',
    promptText: 'длинные ухоженные волосы',
    icon: Icons.waves,
    gradient: [Color(0xFFCB3E7D), Color(0xFFFF7FB8)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'punk',
    title: 'Панк-стиль',
    promptText: 'яркая панк-стрижка с выбритыми висками',
    icon: Icons.bolt,
    gradient: [Color(0xFFD62839), Color(0xFFFF6B7A)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'thick_beard',
    title: 'Густая борода',
    promptText: 'густая ухоженная борода',
    icon: Icons.face_retouching_natural,
    gradient: [Color(0xFF2E7DFA), Color(0xFF6DB3FF)],
    conflictGroup: 'beard',
  ),
  StylePreset(
    id: 'goatee',
    title: 'Борода-эспаньолка',
    promptText: 'борода-эспаньолка',
    icon: Icons.face_6,
    gradient: [Color(0xFF7A5230), Color(0xFFBE8A5C)],
    conflictGroup: 'beard',
  ),
  StylePreset(
    id: 'clean_shaven',
    title: 'Гладко выбрит',
    promptText: 'чисто выбритое лицо, без бороды',
    icon: Icons.face_2,
    gradient: [Color(0xFF4A5568), Color(0xFF8B96A5)],
    conflictGroup: 'beard',
  ),
];
