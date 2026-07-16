import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_constants.dart';

final variantCountControllerProvider =
    AsyncNotifierProvider<VariantCountController, int>(
      VariantCountController.new,
    );

class VariantCountController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.variantCountPrefsKey) ?? 1;
  }

  Future<void> setCount(int count) async {
    state = AsyncData(count);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.variantCountPrefsKey, count);
  }
}
