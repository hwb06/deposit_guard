abstract final class AppStrings {
  static const String appName = 'DepositGuard';
  static const String tagline =
      'Document your rental. Protect your deposit.';

  // Common
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';

  // Generic states
  static const String somethingWentWrong =
      'Something went wrong. Try again.';
  static const String noInternet =
      'You are offline. Changes are saved on this device.';

  // Rentals
  static const String rentalsTitle = 'My rentals';
  static const String searchRentals = 'Search rentals';
  static const String addRental = 'Add rental';
  static const String noRentalsTitle = 'Start your first rental';
  static const String noRentalsMessage =
      'Add your rental and log its condition with photos.';
  static const String noResultsTitle = 'No matches found';
  static const String noResultsMessage = 'Try a different search.';
  static const String leaseEnded = 'Lease ended';

  // Rental form
  static const String newRentalTitle = 'New rental';
  static const String editRentalTitle = 'Edit rental';
  static const String rentalNameLabel = 'Rental name';
  static const String rentalNameHint = 'Unit 4B';
  static const String rentalAddressLabel = 'Address';
  static const String rentalAddressHint = 'Maple Apartments, Dallas, TX';
  static const String leaseStartLabel = 'Lease start';
  static const String leaseEndLabel = 'Lease end';
  static const String selectDate = 'Select a date';
  static const String enterName = 'Enter a rental name';
  static const String enterAddress = 'Enter the address';
  static const String leaseEndAfterStart =
      'Lease end must be after the start date';
  static const String saveRental = 'Save rental';

  // Rental detail
  static const String deleteRentalTitle = 'Delete this rental?';
  static const String deleteRentalMessage =
      'All issues logged for this rental will be removed from this device.';
  static const String rentalNotFoundTitle = 'Rental not found';
  static const String rentalNotFoundMessage =
      'This rental no longer exists.';
  static const String issuesTitle = 'Issues';
  static const String noIssuesTitle = 'No issues logged yet';
  static const String noIssuesMessage =
      'Log the condition of each room with a photo.';

  // Issues
  static const String addIssue = 'Add issue';
  static const String newIssueTitle = 'New issue';
  static const String editIssueTitle = 'Edit issue';
  static const String issueTitleLabel = 'What is the issue?';
  static const String issueTitleHint = 'Carpet stain near window';
  static const String roomLabel = 'Room';
  static const String severityLabel = 'Severity';
  static const String stageLabel = 'When did you notice it?';
  static const String noteLabel = 'Note (optional)';
  static const String noteHint = 'Size, location, anything useful';
  static const String enterIssueTitle = 'Describe the issue';
  static const String saveIssue = 'Save issue';
  static const String addPhoto = 'Add a photo';
  static const String takePhoto = 'Take photo';
  static const String chooseGallery = 'Choose from gallery';
  static const String removePhoto = 'Remove photo';
  static const String photoFailed = "Couldn't load that photo. Try again.";
  static const String deleteIssueTitle = 'Delete this issue?';
  static const String deleteIssueMessage =
      'The issue and its photo will be removed from this device.';
  static const String searchIssues = 'Search issues';
  static const String allFilter = 'All';
  static const String noIssueMatchesTitle = 'No issues match';
  static const String noIssueMatchesMessage =
      'Try a different room, severity or search.';

  // Onboarding
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get started';
  static const String onboardingTitle1 = 'Photograph every room';
  static const String onboardingMessage1 =
      'Log scratches, stains and damage with photos on the day you move in.';
  static const String onboardingTitle2 = 'Everything is dated';
  static const String onboardingMessage2 =
      'Each issue is saved with a date, room and severity. It works offline.';
  static const String onboardingTitle3 = 'Get your deposit back';
  static const String onboardingMessage3 =
      'Share a clear report with your landlord at move-out. No account needed.';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String appearance = 'Appearance';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String account = 'Account';
  static const String guestMode = 'Guest mode';
  static const String guestModeMessage =
      'Your data is stored on this device only.';
  static const String general = 'General';
  static const String showIntroAgain = 'Show intro again';

  // Auth
  static const String signIn = 'Sign in';
  static const String signUp = 'Create account';
  static const String signOut = 'Sign out';
  static const String signInOrCreate = 'Sign in or create an account';
  static const String signedIn = 'Signed in';
  static const String emailLabel = 'Email';
  static const String emailHint = 'name@company.com';
  static const String passwordLabel = 'Password';
  static const String enterEmail = 'Enter your email';
  static const String invalidEmail = 'Enter a valid email address';
  static const String enterPassword = 'Enter your password';
  static const String passwordTooShort = 'Use at least 8 characters';
  static const String authSubtitleSignIn =
      'Sign in to back up your rentals. Your data stays on this device either way.';
  static const String authSubtitleSignUp =
      'Create an account to back up your rentals.';
  static const String switchToSignUp = 'New here? Create an account';
  static const String switchToSignIn = 'Already have an account? Sign in';
  static const String signOutTitle = 'Sign out?';
  static const String signOutMessage =
      'Your rentals and photos stay on this device.';
  static const String authInvalidCredentials =
      'Email or password is incorrect.';
  static const String authEmailTaken =
      'An account with this email already exists. Sign in instead.';
  static const String authEmailNotConfirmed =
      'Confirm your email first, then sign in.';
  static const String authCheckEmail =
      'Account created. Check your email to confirm, then sign in.';
  static const String authRateLimited =
      'Too many attempts. Try again in a few minutes.';
  static const String authNetworkError =
      "Couldn't connect. Check your internet and try again.";
  static const String authGeneric = "Couldn't sign you in. Try again.";
  static const String authUnavailable = 'Sign-in is not set up in this build.';

  // Reminders & reports
  static const String reminderTitle = 'Lease ending soon';
  static const String exportReport = 'Export PDF report';
  static const String preparingReport = 'Preparing report...';
  static const String reportFailed = "Couldn't create the report. Try again.";

  // Cloud backup
  static const String backupTitle = 'Cloud backup';
  static const String backUpNow = 'Back up now';
  static const String restoreFromBackup = 'Restore from backup';
  static const String restoreSubtitle = 'Add your cloud backup to this device';
  static const String restoreTitle = 'Restore from backup?';
  static const String restoreMessage =
      'This adds anything from your cloud backup that this device is missing '
      'and updates items that are newer in the cloud. Nothing on this device '
      'is deleted.';
  static const String restore = 'Restore';
  static const String backupSignInTitle = 'Back up your rentals';
  static const String backupSignInMessage =
      'Sign in to save your rentals and photos to the cloud.';
  static const String neverBackedUp = 'Not backed up yet';
  static String lastBackedUp(String when) => 'Last backed up $when';

  // Backup progress
  static const String backupChecking = 'Checking your cloud backup...';
  static const String restoreReading = 'Reading your cloud backup...';
  static const String restoreSaving = 'Saving to this device...';
  static String backupUploadingPhotos(int done, int total) =>
      'Uploading photo $done of $total...';
  static String restoreDownloadingPhotos(int done, int total) =>
      'Downloading photo $done of $total...';

  // Backup results
  static const String backupUpToDate = 'Everything is already backed up.';
  static const String restoreNothingNew =
      'Nothing new to restore. This device already has your latest data.';
  static const String restorePhotosMissing =
      'Some photos could not be downloaded. Restore again to retry.';

  static String backupDone({
    required int rentals,
    required int issues,
    required int photos,
    required int removed,
  }) {
    final parts = <String>[
      if (rentals > 0) _count(rentals, 'rental'),
      if (issues > 0) _count(issues, 'issue'),
      if (photos > 0) _count(photos, 'photo'),
    ];
    return <String>[
      if (parts.isNotEmpty) 'Backed up ${_join(parts)}.',
      if (removed > 0) 'Removed ${_count(removed, 'deleted item')} from the cloud.',
    ].join(' ');
  }

  static String restoreDone({
    required int rentals,
    required int issues,
    required int photos,
    int photoFailures = 0,
  }) {
    final parts = <String>[
      if (rentals > 0) _count(rentals, 'rental'),
      if (issues > 0) _count(issues, 'issue'),
      if (photos > 0) _count(photos, 'photo'),
    ];
    return <String>[
      if (parts.isNotEmpty) 'Restored ${_join(parts)}.',
      if (photoFailures > 0) restorePhotosMissing,
    ].join(' ');
  }

  static String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

  static String _join(List<String> parts) => switch (parts.length) {
    0 => '',
    1 => parts.first,
    2 => '${parts.first} and ${parts.last}',
    _ => '${parts.sublist(0, parts.length - 1).join(', ')}, '
        'and ${parts.last}',
  };

  // Backup errors
  static const String backupUnavailable =
      'Cloud backup is not set up in this build.';
  static const String backupSignInRequired = 'Sign in to use cloud backup.';
  static const String backupSessionExpired =
      'Your session expired. Sign in again.';
  static const String backupNetworkError =
      "Couldn't reach the cloud. Check your internet and try again.";
  static const String backupNotSetUp =
      "Cloud backup isn't set up on the server yet. Run the setup SQL in Supabase.";
  static const String backupGeneric = "Couldn't finish the backup. Try again.";
  static const String restoreGeneric = "Couldn't finish the restore. Try again.";
  static const String working = 'Working...';

}
