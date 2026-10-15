abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String rentals = '/';
  static const String rentalNew = '/rentals/new';
  static const String rentalDetail = '/rentals/:id';
  static const String rentalEdit = '/rentals/:id/edit';
  static const String issueNew = '/rentals/:id/issues/new';
  static const String issueEdit = '/rentals/:id/issues/:issueId/edit';

  static String detailPath(String id) => '/rentals/$id';
  static String editPath(String id) => '/rentals/$id/edit';
  static String issueNewPath(String rentalId) =>
      '/rentals/$rentalId/issues/new';
  static String issueEditPath(String rentalId, String issueId) =>
      '/rentals/$rentalId/issues/$issueId/edit';
}