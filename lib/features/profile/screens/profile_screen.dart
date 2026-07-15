import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_translator.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../consent/controllers/consent_controller.dart';
import '../../generation_settings/controllers/generation_settings_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? '—'),
          ),
          subscriptionAsync.when(
            data: (subscription) => ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Тариф'),
              subtitle: Text(subscription.tier.name.toUpperCase()),
            ),
            loading: () => const ListTile(title: Text('Загрузка тарифа...')),
            error: (e, stackTrace) => ListTile(
              title: Text(friendlyErrorMessage(e, context: 'profile', stackTrace: stackTrace)),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              ref.invalidate(chatControllerProvider);
              ref.invalidate(chatSessionsProvider);
              ref.invalidate(subscriptionControllerProvider);
              ref.invalidate(consentControllerProvider);
              ref.invalidate(generationSettingsControllerProvider);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
