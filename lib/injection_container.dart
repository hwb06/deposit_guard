import 'package:deposit_guard/services/image/image_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/issue/issue_bloc.dart';
import 'bloc/issue_form/issue_form_cubit.dart';
import 'bloc/rental/rental_bloc.dart';
import 'bloc/rental_detail/rental_detail_cubit.dart';
import 'bloc/settings/settings_cubit.dart';
import 'data/local/app_database.dart';
import 'data/local/issue_dao.dart';
import 'data/local/rental_dao.dart';
import 'data/repositories/issue_repository.dart';
import 'data/repositories/rental_repository.dart';
import 'services/preferences_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  final imageService = ImageService();
  await imageService.init();
  final sharedPreferences = await SharedPreferences.getInstance();

  sl
  // Services
    ..registerSingleton<ImageService>(imageService)
    ..registerSingleton<PreferencesService>(
      PreferencesService(sharedPreferences),
    )
  // Data sources
    ..registerLazySingleton<AppDatabase>(() => AppDatabase.instance)
    ..registerLazySingleton<RentalDao>(() => RentalDao(sl()))
    ..registerLazySingleton<IssueDao>(() => IssueDao(sl()))
  // Repositories
    ..registerLazySingleton<RentalRepository>(() => RentalRepository(sl()))
    ..registerLazySingleton<IssueRepository>(() => IssueRepository(sl()))
  // Blocs / Cubits
    ..registerFactory<SettingsCubit>(() => SettingsCubit(sl()))
    ..registerFactory<RentalBloc>(() => RentalBloc(sl()))
    ..registerFactory<RentalDetailCubit>(() => RentalDetailCubit(sl(), sl()))
    ..registerFactory<IssueBloc>(() => IssueBloc(sl()))
    ..registerFactory<IssueFormCubit>(() => IssueFormCubit(sl(), sl()));
}