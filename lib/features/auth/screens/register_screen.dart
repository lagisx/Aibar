import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/error_translator.dart';
import '../../../shared_widgets/primary_button.dart';
import '../../../shared_widgets/staggered_fade_in.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_mode_toggle.dart';
import '../../../shared_widgets/scissors_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _infoMessage = null;
    });
    try {
      final hasSession = await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (hasSession) {
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      setState(() {
        _infoMessage =
            'Проверьте почту и подтвердите email, затем войдите в аккаунт.';
      });
    } catch (e, stackTrace) {
      setState(
        () => _errorMessage = friendlyErrorMessage(
          e,
          context: 'register',
          stackTrace: stackTrace,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Center(child: ScissorsLogo(size: 72)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Создать аккаунт',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                StaggeredFadeIn(
                  index: 0,
                  child: AuthModeToggle(
                    isLogin: false,
                    onSelectLogin: () => Navigator.of(context).pop(),
                    onSelectRegister: () {},
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                StaggeredFadeIn(
                  index: 1,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (value) =>
                        (value == null || !value.contains('@'))
                        ? 'Введите корректный email'
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StaggeredFadeIn(
                  index: 2,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6)
                        ? 'Минимум 6 символов'
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StaggeredFadeIn(
                  index: 3,
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Повторите пароль',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value != _passwordController.text)
                        ? 'Пароли не совпадают'
                        : null,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_infoMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(_infoMessage!),
                ],
                const SizedBox(height: AppSpacing.xl),
                StaggeredFadeIn(
                  index: 4,
                  child: PrimaryButton(
                    label: 'Создать аккаунт',
                    onPressed: _signUp,
                    loading: _loading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
