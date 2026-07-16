import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_translator.dart';
import '../../../data/models/subscription.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/plan_card.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Тарифы')),
      body: subscriptionAsync.when(
        data: (subscription) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PlanCard(
              tier: SubscriptionTier.free,
              title: 'Free',
              price: '0 ₽/мес',
              features: const [
                'Ограниченное количество генераций',
                'Базовое качество результата',
              ],
              isCurrent: subscription.tier == SubscriptionTier.free,
              onSelect: () => ref
                  .read(subscriptionControllerProvider.notifier)
                  .mockUpgrade(SubscriptionTier.free),
            ),
            PlanCard(
              tier: SubscriptionTier.pro,
              title: 'Pro',
              price: '299 ₽/мес',
              features: const [
                'Расширенный лимит генераций',
                'Приоритетная генерация',
                'HD-качество результата',
              ],
              isCurrent: subscription.tier == SubscriptionTier.pro,
              onSelect: () => ref
                  .read(subscriptionControllerProvider.notifier)
                  .mockUpgrade(SubscriptionTier.pro),
            ),
            PlanCard(
              tier: SubscriptionTier.max,
              title: 'Max',
              price: '799 ₽/мес',
              features: const [
                'Максимальный лимит генераций',
                'Максимальный приоритет',
                'Ранний доступ к новым стилям',
              ],
              isCurrent: subscription.tier == SubscriptionTier.max,
              onSelect: () => ref
                  .read(subscriptionControllerProvider.notifier)
                  .mockUpgrade(SubscriptionTier.max),
            ),
            const SizedBox(height: 8),
            const Text(
              'Тестовая версия: оплата пока не подключена, смена тарифа '
              'обновляет значение напрямую в базе данных.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            friendlyErrorMessage(
              error,
              context: 'paywall',
              stackTrace: stackTrace,
            ),
          ),
        ),
      ),
    );
  }
}
