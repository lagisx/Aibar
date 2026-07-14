import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_constants.dart';

final consentControllerProvider =
    AsyncNotifierProvider<ConsentController, bool>(ConsentController.new);

class ConsentController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.photoConsentPrefsKey) ?? false;
  }

  Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.photoConsentPrefsKey, true);
    state = const AsyncData(true);
  }
}
