import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/subscription.dart';
import '../../../data/repositories/subscription_repository.dart';
import '../../auth/controllers/auth_controller.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final subscriptionControllerProvider =
    AsyncNotifierProvider<SubscriptionController, Subscription>(
      SubscriptionController.new,
    );

class SubscriptionController extends AsyncNotifier<Subscription> {
  SubscriptionRepository get _repo => ref.read(subscriptionRepositoryProvider);

  @override
  Future<Subscription> build() {
    ref.watch(currentUserIdProvider);
    return _repo.fetchCurrent();
  }

  Future<void> mockUpgrade(SubscriptionTier tier) async {
    state = const AsyncLoading();
    await _repo.mockUpgrade(tier);
    state = await AsyncValue.guard(() => _repo.fetchCurrent());
  }
}
