import '../../core/config/app_constants.dart';
import '../models/subscription.dart';
import '../services/supabase_service.dart';

class SubscriptionRepository {
  String get _userId {
    final id = SupabaseService.currentUser?.id;
    if (id == null) throw Exception('Пользователь не авторизован');
    return id;
  }

  Future<Subscription> fetchCurrent() async {
    final row = await SupabaseService.client
        .from(AppConstants.subscriptionsTable)
        .select()
        .eq('user_id', _userId)
        .maybeSingle();

    final tier = row == null
        ? SubscriptionTier.free
        : subscriptionTierFromString(row['tier'] as String);
    final limit = await _fetchTierLimit(tier);

    if (row == null) {
      return Subscription(
        userId: _userId,
        tier: SubscriptionTier.free,
        requestsUsedThisPeriod: 0,
        requestLimit: limit,
        periodResetAt: DateTime.now().add(const Duration(days: 30)),
        status: 'active',
      );
    }
    return Subscription.fromMap(row, requestLimit: limit);
  }

  Future<int> _fetchTierLimit(SubscriptionTier tier) async {
    try {
      final row = await SupabaseService.client
          .from(AppConstants.subscriptionTiersTable)
          .select('request_limit')
          .eq('tier', tier.name)
          .maybeSingle();

      final limit = row?['request_limit'] as int?;
      if (limit != null) return limit;
    } catch (_) {
    }
    return AppConstants.fallbackTierRequestLimits[tier.name] ?? 0;
  }

  Future<void> mockUpgrade(SubscriptionTier tier) async {
    await SupabaseService.client.from(AppConstants.subscriptionsTable).upsert({
      'user_id': _userId,
      'tier': tier.name,
    });
  }

  bool hasReachedLimit(Subscription subscription) {
    return subscription.hasReachedLimit;
  }
}