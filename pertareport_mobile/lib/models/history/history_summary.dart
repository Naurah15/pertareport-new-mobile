// models/history/history_summary.dart
class HistorySummary {
  final int totalReports;
  final int totalActivities;
  final int totalPhotos;
  final DateTime? lastReportDate;
  final String mostActiveLocation;
  final Map<String, int> activityTypeCount;
  final List<MonthlyReport> monthlyStats;

  HistorySummary({
    required this.totalReports,
    required this.totalActivities,
    required this.totalPhotos,
    this.lastReportDate,
    required this.mostActiveLocation,
    required this.activityTypeCount,
    required this.monthlyStats,
  });

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    return HistorySummary(
      totalReports: json['total_reports'] ?? 0,
      totalActivities: json['total_activities'] ?? 0,
      totalPhotos: json['total_photos'] ?? 0,
      lastReportDate: json['last_report_date'] != null
          ? DateTime.tryParse(json['last_report_date'])
          : null,
      mostActiveLocation: json['most_active_location'] ?? '',
      activityTypeCount: (json['activity_type_count'] ?? {})
          .map<String, int>((k, v) => MapEntry(k.toString(), v ?? 0)),
      monthlyStats: (json['monthly_stats'] as List<dynamic>?)
              ?.map((m) => MonthlyReport.fromJson(m))
              .toList() ??
          [],
    );
  }


  String get lastReportFormatted {
    if (lastReportDate == null) return 'No reports yet';
    final now = DateTime.now();
    final difference = now.difference(lastReportDate!);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }

  double get averageActivitiesPerReport {
    if (totalReports == 0) return 0;
    return totalActivities / totalReports;
  }

  double get averagePhotosPerReport {
    if (totalReports == 0) return 0;
    return totalPhotos / totalReports;
  }
}

class MonthlyReport {
  final String month;
  final int year;
  final int reportCount;
  final int activityCount;
  final int photoCount;

  MonthlyReport({
    required this.month,
    required this.year,
    required this.reportCount,
    required this.activityCount,
    required this.photoCount,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      month: json['month'],
      year: json['year'],
      reportCount: json['report_count'],
      activityCount: json['activity_count'],
      photoCount: json['photo_count'],
    );
  }

  String get displayName => '$month $year';
}