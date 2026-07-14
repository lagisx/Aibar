enum SubscriptionTier { free, pro, max }

SubscriptionTier subscriptionTierFromString(String value) {
  return SubscriptionTier.values.firstWhere(
    (t) => t.name == value,
    orElse: () => SubscriptionTier.free,
  );
}

class Subscription {
  final String userId;
  final SubscriptionTier tier;
  final int requestsUsedThisPeriod;
  final DateTime periodResetAt;
  final String status;

  const Subscription({
    required this.userId,
    required this.tier,
    required this.requestsUsedThisPeriod,
    required this.periodResetAt,
    required this.status,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      userId: map['user_id'] as String,
      tier: subscriptionTierFromString(map['tier'] as String),
      requestsUsedThisPeriod: map['requests_used_this_period'] as int? ?? 0,
      periodResetAt: DateTime.parse(map['period_reset_at'] as String),
      status: map['status'] as String? ?? 'active',
    );
  }
}
