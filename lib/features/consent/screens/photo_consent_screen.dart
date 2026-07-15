import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared_widgets/primary_button.dart';
import '../controllers/consent_controller.dart';

// без согласия на обработку фото в чат не пускаем
class PhotoConsentScreen extends ConsumerStatefulWidget {
  const PhotoConsentScreen({super.key});

  @override
  ConsumerState<PhotoConsentScreen> createState() =>
      _PhotoConsentScreenState();
}

class _PhotoConsentScreenState extends ConsumerState<PhotoConsentScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Icon(Icons.photo_camera_outlined,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Обработка фото',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Чтобы сгенерировать новую причёску или бороду, мы отправляем '
                'ваше фото во внешний AI-сервис и временно храним его в '
                'облаке. Фото автоматически удаляется через несколько дней '
                'и используется только для генерации результата — мы не '
                'передаём его третьим лицам и не используем в других целях.',
              ),
              const Spacer(),
              CheckboxListTile(
                value: _checked,
                onChanged: (value) =>
                    setState(() => _checked = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Я согласен(на) на обработку моего фото для генерации '
                  'причёсок и ознакомлен(а) с политикой конфиденциальности.',
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Продолжить',
                onPressed: _checked
                    ? () => ref.read(consentControllerProvider.notifier).accept()
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
