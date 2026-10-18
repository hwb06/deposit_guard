import 'package:deposit_guard/bloc/backup/connectivity/connectivity_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/backup/backup_cubit.dart';
import 'bloc/issue/issue_bloc.dart';
import 'bloc/issue_form/issue_form_cubit.dart';
import 'bloc/rental/rental_bloc.dart';
import 'bloc/rental_detail/rental_detail_cubit.dart';
import 'bloc/settings/settings_cubit.dart';
import 'data/local/app_database.dart';
import 'data/local/issue_dao.dart';
import 'data/local/rental_dao.dart';
import 'data/remote/backup_remote_source.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/issue_repository.dart';
import 'data/repositories/rental_repository.dart';
import 'services/connectivity_service.dart';
import 'services/image/image_service.dart';
import 'services/preferences_service.dart';
import 'services/reminder_service.dart';
import 'services/report_service.dart';

final GetIt sl = GetIt.instance;

/// [authAvailable] is true only when Supabase was initialised successfully.
Future<void> initDependencies({required bool authAvailable}) async {
  final imageService = ImageService();
  await imageService.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  sl
  // Services
    ..registerSingleton<ImageService>(imageService)
    ..registerSingleton<PreferencesService>(
      PreferencesService(sharedPreferences),
    )
    ..registerLazySingleton<ConnectivityService>(() => ConnectivityService())
  // Data sources
    ..registerLazySingleton<AppDatabase>(() => AppDatabase.instance)
    ..registerLazySingleton<RentalDao>(() => RentalDao(sl()))
    ..registerLazySingleton<IssueDao>(() => IssueDao(sl()))
    ..registerLazySingleton<BackupRemoteSource>(
          () => BackupRemoteSource(
        authAvailable ? Supabase.instance.client : null,
      ),
    )
  // Repositories
    ..registerLazySingleton<RentalRepository>(() => RentalRepository(sl()))
    ..registerLazySingleton<IssueRepository>(() => IssueRepository(sl()))
    ..registerLazySingleton<AuthRepository>(
          () => AuthRepository(
        authAvailable ? Supabase.instance.client.auth : null,
      ),
    )
    ..registerLazySingleton<BackupRepository>(
          () => BackupRepository(
        remote: sl(),
        rentals: sl(),
        issues: sl(),
        images: sl(),
        preferences: sl(),
      ),
    )
    ..registerLazySingleton<ReportService>(() => ReportService(sl(), sl()))
    ..registerLazySingleton<ReminderService>(() => ReminderService(sl()))
  // Blocs / Cubits
    ..registerFactory<AuthBloc>(() => AuthBloc(sl()))
    ..registerFactory<SettingsCubit>(() => SettingsCubit(sl()))
    ..registerFactory<BackupCubit>(() => BackupCubit(sl(), sl()))
    ..registerFactory<ConnectivityCubit>(() => ConnectivityCubit(sl()))
    ..registerFactory<RentalBloc>(() => RentalBloc(sl()))
    ..registerFactory<RentalDetailCubit>(() => RentalDetailCubit(sl(), sl()))
    ..registerFactory<IssueBloc>(() => IssueBloc(sl()))
    ..registerFactory<IssueFormCubit>(() => IssueFormCubit(sl(), sl()));

  // Needs the repositories above, so it is initialised last.
  await sl<ReminderService>().init();
}