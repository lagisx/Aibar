import 'package:flutter/material.dart';

import '../../../data/models/subscription.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final String title;
  final String price;
  final List<String> features;
  final bool isCurrent;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.tier,
    required this.title,
    required this.price,
    required this.features,
    required this.isCurrent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? colors.primary : colors.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(price, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isCurrent ? null : onSelect,
              child: Text(isCurrent ? 'Текущий тариф' : 'Оформить'),
            ),
          ),
        ],
      ),
    );
  }
}
