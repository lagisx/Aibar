import 'package:flutter/material.dart';

import '../models/style_preset.dart';

const List<StylePreset> stylePresets = [
  StylePreset(
    id: 'long_haircut',
    title: 'Длинная стрижка',
    promptText: 'длинные ухоженные волосы',
    icon: Icons.waves,
    gradient: [Color(0xFFCB3E7D), Color(0xFFFF7FB8)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'short_haircut',
    title: 'Короткая стрижка',
    promptText: 'короткая аккуратная стрижка',
    icon: Icons.face,
    gradient: [Color(0xFF20B486), Color(0xFF6FE0BB)],
    conflictGroup: 'length',
  ),
  StylePreset(
    id: 'beard',
    title: 'Борода',
    promptText: 'аккуратная ухоженная борода, причёску не менять',
    icon: Icons.face_retouching_natural,
    gradient: [Color(0xFF7A5230), Color(0xFFBE8A5C)],
    conflictGroup: null,
  ),
];
