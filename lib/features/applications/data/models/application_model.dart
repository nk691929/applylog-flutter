import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel extends Application {
  ApplicationModel({
    required super.id,
    required super.companyName,
    required super.roleTitle,
    required super.status,
    required super.dateApplied,
    super.followUpDate,
    super.notes,
    super.source,
  });

  factory ApplicationModel.fromFireStore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return ApplicationModel(
      id: docId,
      companyName: json['companyName'],
      roleTitle: json['roleTitle'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.applied,
      ),
      dateApplied: (json['dateApplied'] as Timestamp).toDate(),
      source: json['source'] as String,
      notes: json['notes'] as String,
      followUpDate: json['followUpDate'] != null
          ? (json['followUpDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'companyName': companyName,
      'roleTitle': roleTitle,
      "status": status,
      'dateApplied': Timestamp.fromDate(dateApplied),
      'source': source,
      'notes': notes,
      'followUpDate': followUpDate != null
          ? Timestamp.fromDate(followUpDate!)
          : null,
    };
  }
}
