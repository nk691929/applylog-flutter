int notificationIdFromApplicationId(String applicationId) {
  var hash = 0;

  for (final codeUnits in applicationId.codeUnits) {
    hash = (hash * 31 + codeUnits) & 0x7fffffff;
  }
  return hash;
}
