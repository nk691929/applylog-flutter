import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  /// Format: Aug 21, 2026
  String toReadableDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format: Aug 21, 2026 • 06:29 PM
  String toReadableDateTime() {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(this);
  }

  /// Format: 21/08/2026
  String toNumericDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
}