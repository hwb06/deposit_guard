enum IssueStage {
  moveIn('Move-in'),
  duringStay('During stay'),
  moveOut('Move-out');

  const IssueStage(this.label);
  final String label;

  static IssueStage fromName(String value) => IssueStage.values
      .firstWhere((e) => e.name == value, orElse: () => IssueStage.moveIn);
}