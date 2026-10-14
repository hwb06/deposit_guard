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

}