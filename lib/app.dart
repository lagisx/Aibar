import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/error_translator.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/generation_settings/screens/generation_settings_screen.dart';
import 'features/onboarding/controllers/app_tour_controller.dart';
import 'features/onboarding/screens/app_tour_screen.dart';
import 'features/onboarding/screens/gender_selection_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/profile/controllers/gender_controller.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/subscription/screens/paywall_screen.dart';
import 'routes/app_routes.dart';

class HairstyleAiApp extends ConsumerWidget {
  const HairstyleAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeControllerProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp(
      title: 'VEGAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: SplashScreen(nextBuilder: (_) => const RootGate()),
      routes: {
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.paywall: (_) => const PaywallScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.generationSettings: (_) => const GenerationSettingsScreen(),
        AppRoutes.favorites: (_) => const FavoritesScreen(),
      },
    );
  }
}

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const OnboardingScreen();
    }

    final genderAsync = ref.watch(genderControllerProvider);
    return genderAsync.when(
      data: (gender) =>
          gender == null ? const GenderSelectionScreen() : const _AppTourGate(),
      loading: () => const _LoadingGate(),
      error: (error, stackTrace) => _ErrorGate(
        errorContext: 'gender',
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

class _AppTourGate extends ConsumerWidget {
  const _AppTourGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourSeenAsync = ref.watch(appTourControllerProvider);
    return tourSeenAsync.when(
      data: (seen) => seen ? const ChatScreen() : const AppTourScreen(),
      loading: () => const _LoadingGate(),
      error: (error, stackTrace) => _ErrorGate(
        errorContext: 'app_tour',
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

class _LoadingGate extends StatelessWidget {
  const _LoadingGate();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorGate extends StatelessWidget {
  final String errorContext;
  final Object error;
  final StackTrace stackTrace;

  const _ErrorGate({
    required this.errorContext,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          friendlyErrorMessage(
            error,
            context: errorContext,
            stackTrace: stackTrace,
          ),
        ),
      ),
    );
  }
}
