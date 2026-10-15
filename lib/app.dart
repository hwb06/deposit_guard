import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/backup/backup_cubit.dart';
import 'bloc/backup/backup_state.dart';
import 'bloc/rental/rental_bloc.dart';
import 'bloc/rental/rental_event.dart';
import 'bloc/rental/rental_state.dart';
import 'bloc/settings/settings_cubit.dart';
import 'bloc/settings/settings_state.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'services/reminder_service.dart';

class DepositGuardApp extends StatelessWidget {
  const DepositGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SettingsCubit>()),
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider(
          create: (_) => sl<RentalBloc>()..add(const RentalsLoaded()),
        ),
        BlocProvider(create: (_) => sl<BackupCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          // Re-schedule lease reminders whenever the saved rentals change.
          BlocListener<RentalBloc, RentalState>(
            listenWhen: (previous, current) =>
            current.status == RentalStatus.success &&
                previous.rentals != current.rentals,
            listener: (_, __) => sl<ReminderService>().sync(),
          ),
          // Reload the rentals list after a cloud restore.
          BlocListener<BackupCubit, BackupState>(
            listenWhen: (previous, current) =>
            previous.status != current.status &&
                current.status == BackupStatus.restored,
            listener: (context, _) =>
                context.read<RentalBloc>().add(const RentalsLoaded()),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (previous, current) =>
          previous.themeMode != current.themeMode,
          builder: (context, settings) {
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}