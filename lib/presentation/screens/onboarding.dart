import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/settings/settings_cubit.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

const List<_OnboardingPage> _pages = [
  _OnboardingPage(
    icon: Icons.photo_camera_outlined,
    title: AppStrings.onboardingTitle1,
    message: AppStrings.onboardingMessage1,
  ),
  _OnboardingPage(
    icon: Icons.event_note_outlined,
    title: AppStrings.onboardingTitle2,
    message: AppStrings.onboardingMessage2,
  ),
  _OnboardingPage(
    icon: Icons.verified_user_outlined,
    title: AppStrings.onboardingTitle3,
    message: AppStrings.onboardingMessage3,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    await context.read<SettingsCubit>().completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.rentals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                child: _isLast
                    ? null
                    : TextButton(
                  onPressed: _finish,
                  child: const Text(AppStrings.skip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (_, index) =>
                    _OnboardingPageView(page: _pages[index]),
              ),
            ),
            _PageDots(count: _pages.length, index: _index),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: ElevatedButton(
                onPressed: _isLast ? _finish : _next,
                child: Text(
                  _isLast ? AppStrings.getStarted : AppStrings.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(page.icon, size: 56, color: context.colors.primary),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            page.title,
            style: context.text.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            page.message,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
            width: i == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i == index
                  ? context.colors.primary
                  : context.colors.outline,
            ),
          ),
      ],
    );
  }
}