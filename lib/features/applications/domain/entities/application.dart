enum ApplicationStatus {
  applied,
  screening,
  interview,
  offer,
  rejected,
  withdrawn,
}

class Application {
  final String id;
  final String companyName;
  final String roleTitle;
  final ApplicationStatus status;
  final DateTime dateApplied;
  final String? source;
  final String? notes;
  final DateTime? followUpDate;

  const Application({
    required this.id,
    required this.companyName,
    required this.roleTitle,
    required this.status,
    required this.dateApplied,
    this.source,
    this.notes,
    this.followUpDate,
  });

  int get daysSinceApplied => DateTime.now().difference(dateApplied).inDays;
}
