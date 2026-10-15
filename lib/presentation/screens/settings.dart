import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/settings/settings_cubit.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../data/models/app_user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsCubit, ThemeMode>(
          (cubit) => cubit.state.themeMode,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          const _SectionTitle(AppStrings.appearance),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(AppStrings.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(AppStrings.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(AppStrings.themeDark),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) => context
                  .read<SettingsCubit>()
                  .setThemeMode(selection.first),
            ),
          ),
          const _SectionTitle(AppStrings.account),
          const _AccountSection(),
          const _SectionTitle(AppStrings.general),
          _Group(
            children: [
              ListTile(
                leading: const Icon(Icons.slideshow_outlined),
                title: const Text(AppStrings.showIntroAgain),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.read<SettingsCubit>().replayOnboarding();
                  if (!context.mounted) return;
                  context.go(AppRoutes.onboarding);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>(
          (bloc) => bloc.state.user,
    );
    final isAvailable = context.read<AuthBloc>().isAvailable;

    if (user != null) {
      return _Group(
        children: [
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(user.email ?? AppStrings.signedIn),
            subtitle: const Text(AppStrings.signedIn),
            trailing: TextButton(
              onPressed: () => _confirmSignOut(context),
              child: const Text(AppStrings.signOut),
            ),
          ),
        ],
      );
    }

    return _Group(
      children: [
        const ListTile(
          leading: Icon(Icons.person_outline),
          title: Text(AppStrings.guestMode),
          subtitle: Text(AppStrings.guestModeMessage),
        ),
        if (isAvailable)
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text(AppStrings.signInOrCreate),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.auth),
          ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.signOutTitle),
        content: const Text(AppStrings.signOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<AuthBloc>().add(const AuthSignOutPressed());
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.lg,
        bottom: AppDimensions.sm,
      ),
      child: Text(text, style: context.text.titleMedium),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: BorderSide(color: context.colors.outline),
      ),
      child: Column(children: children),
    );
  }
}