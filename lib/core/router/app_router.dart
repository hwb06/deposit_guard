import 'package:deposit_guard/presentation/screens/issue_form.dart';
import 'package:deposit_guard/presentation/screens/onboarding.dart';
import 'package:deposit_guard/presentation/screens/rental_detail.dart';
import 'package:deposit_guard/presentation/screens/rental_form_screen.dart';
import 'package:deposit_guard/presentation/screens/rentals_screen.dart';
import 'package:deposit_guard/presentation/screens/settings.dart' show SettingsScreen;
import 'package:deposit_guard/services/preferences_service.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/issue_model.dart';
import '../../data/models/rental_model.dart';
import '../../injection_container.dart';
import '../constants/app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.rentals,
  redirect: (context, state) {
    final onboardingDone = sl<PreferencesService>().onboardingDone;
    final atOnboarding = state.matchedLocation == AppRoutes.onboarding;

    if (!onboardingDone && !atOnboarding) return AppRoutes.onboarding;
    if (onboardingDone && atOnboarding) return AppRoutes.rentals;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.rentals,
      builder: (_, __) => const RentalsScreen(),
    ),
    // `new` must come before `:id`, otherwise "new" is read as an id.
    GoRoute(
      path: AppRoutes.rentalNew,
      builder: (_, __) => const RentalFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.rentalDetail,
      builder: (_, state) =>
          RentalDetailScreen(rentalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.rentalEdit,
      builder: (_, state) =>
          RentalFormScreen(rental: state.extra as RentalModel?),
    ),
    GoRoute(
      path: AppRoutes.issueNew,
      builder: (_, state) =>
          IssueFormScreen(rentalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.issueEdit,
      builder: (_, state) => IssueFormScreen(
        rentalId: state.pathParameters['id']!,
        issue: state.extra as IssueModel?,
      ),
    ),
  ],
);