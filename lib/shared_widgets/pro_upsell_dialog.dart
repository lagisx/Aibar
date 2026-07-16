import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

Future<void> showProUpsellDialog(
  BuildContext context, {
  String message = 'Эта функция доступна только на подписке Pro и выше.',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        Icons.workspace_premium_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 36,
      ),
      title: const Text('Нужна подписка Pro', textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.paywall);
              },
              child: const Text('Оформить Pro'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Не сейчас'),
            ),
          ],
        ),
      ],
    ),
  );
}
