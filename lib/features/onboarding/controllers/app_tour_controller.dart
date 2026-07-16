import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/app_tour_repository.dart';
import '../../auth/controllers/auth_controller.dart';

final appTourRepositoryProvider = Provider<AppTourRepository>((ref) {
  return AppTourRepository();
});

final appTourControllerProvider =
    AsyncNotifierProvider<AppTourController, bool>(AppTourController.new);

class AppTourController extends AsyncNotifier<bool> {
  AppTourRepository get _repo => ref.read(appTourRepositoryProvider);

  @override
  Future<bool> build() {
    ref.watch(currentUserIdProvider);
    return _repo.fetch();
  }

  Future<void> complete() async {
    state = const AsyncData(true);
    await _repo.markCompleted();
  }
}
