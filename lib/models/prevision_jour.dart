class PrevisionJour {
  final String date;        // "2026-06-26"
  final double tempMax;
  final double tempMin;
  final int weatherCode;

  PrevisionJour({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
  });

  // Formater "2026-06-26" → "26/06"
  String get dateFormatee {
    final parts = date.split('-');
    return '${parts[2]}/${parts[1]}';
  }

  String get conditionTexte {
    if (weatherCode == 0) return 'Ensoleille';
    if (weatherCode <= 3) return 'Nuageux';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Pluvieux';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Averses';
    if (weatherCode >= 95) return 'Orageux';
    return 'Variable';
  }
}