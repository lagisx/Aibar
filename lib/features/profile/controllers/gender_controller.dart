import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/gender_repository.dart';
import '../../auth/controllers/auth_controller.dart';

final genderRepositoryProvider = Provider<GenderRepository>((ref) {
  return GenderRepository();
});

final genderControllerProvider =
    AsyncNotifierProvider<GenderController, String?>(GenderController.new);

class GenderController extends AsyncNotifier<String?> {
  GenderRepository get _repo => ref.read(genderRepositoryProvider);

  @override
  Future<String?> build() {
    ref.watch(currentUserIdProvider);
    return _repo.fetch();
  }

  Future<void> setGender(String gender) async {
    state = AsyncData(gender);
    await _repo.save(gender);
  }
}
