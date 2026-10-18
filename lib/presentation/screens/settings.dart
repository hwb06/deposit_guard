import '../../core/config/app_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/backup/backup_cubit.dart';
import '../../../bloc/backup/backup_state.dart';
import '../../../bloc/settings/settings_cubit.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../data/models/app_user.dart';
import '../../../injection_container.dart';
import '../../../services/reminder_service.dart';

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
          const _BackupSection(),
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
          // Debug builds only. Not compiled into release builds.
          if (AppFlags.showQaTools) ...[
            const _SectionTitle('Debug tools'),
            _Group(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Test reminder in 30 seconds'),
                  onTap: () {
                    sl<ReminderService>()
                        .debugRemindIn(const Duration(seconds: 30));
                    context.showSnack('Scheduled. Put the app in background.');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Send test error to Sentry'),
                  onTap: () {
                    Sentry.captureException(
                      Exception('Sentry test from DepositGuard'),
                      stackTrace: StackTrace.current,
                    );
                    context.showSnack('Test error sent.');
                  },
                ),
              ],
            ),
          ],
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

/// Hidden when Supabase is not configured. Guests see a sign-in prompt;
/// signed-in users get the backup and restore actions.
class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    if (!context.read<AuthBloc>().isAvailable) return const SizedBox.shrink();

    final user = context.select<AuthBloc, AppUser?>(
          (bloc) => bloc.state.user,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
      previous.user?.id != current.user?.id,
      listener: (context, _) => context.read<BackupCubit>().refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(AppStrings.backupTitle),
          if (user == null)
            _Group(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: const Text(AppStrings.backupSignInTitle),
                  subtitle: const Text(AppStrings.backupSignInMessage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.auth),
                ),
              ],
            )
          else
            const _BackupActions(),
        ],
      ),
    );
  }
}

class _BackupActions extends StatelessWidget {
  const _BackupActions();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupCubit, BackupState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        context.showSnack(
          message,
          isError: state.status == BackupStatus.failure,
        );
      },
      builder: (context, state) {
        final busy = state.busy;
        final lastBackup = state.lastBackup;
        final cubit = context.read<BackupCubit>();

        final backupSubtitle = busy
            ? (state.progress ?? AppStrings.working)
            : lastBackup == null
            ? AppStrings.neverBackedUp
            : AppStrings.lastBackedUp(lastBackup.formattedDateTime);

        return _Group(
          children: [
            ListTile(
              enabled: !busy,
              leading: state.status == BackupStatus.backingUp
                  ? const _Spinner()
                  : const Icon(Icons.cloud_upload_outlined),
              title: const Text(AppStrings.backUpNow),
              subtitle: Text(backupSubtitle),
              onTap: busy ? null : cubit.backUp,
            ),
            const Divider(height: 1),
            ListTile(
              enabled: !busy,
              leading: state.status == BackupStatus.restoring
                  ? const _Spinner()
                  : const Icon(Icons.cloud_download_outlined),
              title: const Text(AppStrings.restoreFromBackup),
              subtitle: state.status == BackupStatus.restoring
                  ? Text(state.progress ?? AppStrings.working)
                  : const Text(AppStrings.restoreSubtitle),
              onTap: busy ? null : () => _confirmRestore(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.restoreTitle),
        content: const Text(AppStrings.restoreMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.restore),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<BackupCubit>().restore();
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
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