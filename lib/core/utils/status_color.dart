import 'package:applylog/features/applications/domain/entities/application.dart';
import 'package:flutter/material.dart';

Color statusColor(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.applied:
      return Colors.blue;
    case ApplicationStatus.screening:
      return Colors.orange;
    case ApplicationStatus.interview:
      return Colors.purple;
    case ApplicationStatus.offer:
      return Colors.green;
    case ApplicationStatus.rejected:
      return Colors.red;
    case ApplicationStatus.withdrawn:
      return Colors.grey;
  }
}
