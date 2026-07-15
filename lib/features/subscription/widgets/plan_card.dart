import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
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
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isCurrent ? colors.primaryContainer.withValues(alpha: 0.25) : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCurrent ? colors.primary : Colors.transparent,
          width: isCurrent ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    child: const Text('Текущий тариф'),
                  )
                : FilledButton(
                    onPressed: onSelect,
                    child: const Text('Оформить'),
                  ),
          ),
        ],
      ),
    );
  }
}
