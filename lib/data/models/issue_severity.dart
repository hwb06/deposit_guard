enum IssueSeverity {
  minor('Minor'),
  moderate('Moderate'),
  severe('Severe');

  const IssueSeverity(this.label);
  final String label;

  static IssueSeverity fromName(String value) => IssueSeverity.values
      .firstWhere((e) => e.name == value, orElse: () => IssueSeverity.minor);
}