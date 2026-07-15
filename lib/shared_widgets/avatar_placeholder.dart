import 'package:flutter/material.dart';

// заглушка вместо аватарки: первая буква email или просто иконка
class AvatarPlaceholder extends StatelessWidget {
  final String? email;
  final double radius;

  const AvatarPlaceholder({super.key, required this.email, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final letter = (email != null && email!.isNotEmpty)
        ? email![0].toUpperCase()
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: letter != null
          ? Text(
              letter,
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(Icons.person_outline, color: colors.onPrimaryContainer),
    );
  }
}
