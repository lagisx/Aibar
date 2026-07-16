import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../settings/screens/terms_screen.dart';
import '../controllers/app_tour_controller.dart';

const _accent = Color(0xFF5F5FD4);
const _ink = Color(0xFF1B1B1F);
const _inkMuted = Color(0xFF5C5C66);

class _TourPage {
  final String imageAsset;
  final Alignment imageAlignment;
  final Color panel;
  final String title;
  final String description;

  const _TourPage({
    required this.imageAsset,
    required this.imageAlignment,
    required this.panel,
    required this.title,
    required this.description,
  });
}

const _pages = [
  _TourPage(
    imageAsset: 'assets/tour/tour_1.webp',
    imageAlignment: Alignment.topCenter,
    panel: Color(0xFFD8D7E1),
    title: 'Выбирайте стили',
    description:
        'Комбинируйте причёску и бороду из готовых пресетов одним касанием',
  ),
  _TourPage(
    imageAsset: 'assets/tour/tour_2.webp',
    imageAlignment: Alignment.topCenter,
    panel: Color(0xFFEBDCCE),
    title: 'Сколько угодно вариантов',
    description: 'Получайте от 1 до 3 вариантов причёски за один запрос',
  ),
  _TourPage(
    imageAsset: 'assets/tour/tour_3.webp',
    imageAlignment: Alignment.topCenter,
    panel: Color(0xFFDBDEDE),
    title: 'Гибкие настройки',
    description:
        'Быстро, Баланс или Максимум — сами выберите баланс скорости и качества',
  ),
  _TourPage(
    imageAsset: 'assets/tour/tour_4.webp',
    imageAlignment: Alignment.bottomCenter,
    panel: Color(0xFFE2D5C9),
    title: 'Всё готово!',
    description: 'Загрузите фото и начните подбирать свой новый образ',
  ),
];

class AppTourScreen extends ConsumerStatefulWidget {
  const AppTourScreen({super.key});

  @override
  ConsumerState<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends ConsumerState<AppTourScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _agreed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      if (_agreed) {
        ref.read(appTourControllerProvider.notifier).complete();
      }
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _pages[_index].panel,
        body: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final isLast = i == _pages.length - 1;
            return _TourSlide(
              page: _pages[i],
              currentIndex: _index,
              pageCount: _pages.length,
              isLast: isLast,
              agreed: _agreed,
              onAgreedChanged: (value) => setState(() => _agreed = value),
              isNextEnabled: !isLast || _agreed,
              onNext: _next,
            );
          },
        ),
      ),
    );
  }
}

class _TourSlide extends StatelessWidget {
  final _TourPage page;
  final int currentIndex;
  final int pageCount;
  final bool isLast;
  final bool agreed;
  final ValueChanged<bool> onAgreedChanged;
  final bool isNextEnabled;
  final VoidCallback onNext;

  const _TourSlide({
    required this.page,
    required this.currentIndex,
    required this.pageCount,
    required this.isLast,
    required this.agreed,
    required this.onAgreedChanged,
    required this.isNextEnabled,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 360 ? 22.0 : 25.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: page.panel),
        Image.asset(
          page.imageAsset,
          fit: BoxFit.cover,
          alignment: page.imageAlignment,
          errorBuilder: (context, error, stackTrace) =>
              ColoredBox(color: page.panel),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.42, 0.68, 1.0],
              colors: [
                page.panel.withValues(alpha: 0),
                page.panel.withValues(alpha: 0.88),
                page.panel,
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: _ink,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: _inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _PageDots(count: pageCount, currentIndex: currentIndex),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 64,
                    child: isLast
                        ? Row(
                            children: [
                              Expanded(
                                child: _ConsentCheckbox(
                                  agreed: agreed,
                                  onChanged: onAgreedChanged,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _CircleButton(
                                icon: Icons.check_rounded,
                                enabled: isNextEnabled,
                                onTap: onNext,
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.centerRight,
                            child: _CircleButton(
                              icon: Icons.arrow_forward_rounded,
                              enabled: true,
                              onTap: onNext,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageDots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3.5),
            width: i == currentIndex ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == currentIndex
                  ? _accent
                  : _ink.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const _ConsentCheckbox({required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Checkbox(
            value: agreed,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: _accent,
            checkColor: Colors.white,
            side: BorderSide(
              color: _inkMuted.withValues(alpha: 0.6),
              width: 1.6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(!agreed),
            child: Text.rich(
              TextSpan(
                text: 'Я согласен(а) на обработку фото и ',
                children: [
                  TextSpan(
                    text: 'условия использования',
                    style: const TextStyle(
                      color: _accent,
                      decoration: TextDecoration.underline,
                      decorationColor: _accent,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TermsScreen()),
                      ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13, height: 1.35, color: _ink),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? _accent : _accent.withValues(alpha: 0.35),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Center(child: Icon(icon, size: 26, color: Colors.white)),
        ),
      ),
    );
  }
}
