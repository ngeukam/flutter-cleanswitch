class TimeFormatter {
  static String convertMinutesToHourMin(dynamic minutesInput) {
    double minutes;

    if (minutesInput is String) {
      minutes = double.tryParse(minutesInput) ?? 0;
    } else if (minutesInput is num) {
      minutes = minutesInput.toDouble();
    } else {
      minutes = 0;
    }

    int h = minutes ~/ 60;
    int m = (minutes % 60).round();
    return '${h}h ${m}min';
  }
}