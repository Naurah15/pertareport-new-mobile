// lib/models/history/history_filter.dart
class HistoryFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  HistoryFilter({
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  HistoryFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearSearchQuery = false,
  }) {
    return HistoryFilter(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  Map<String, String> toQueryParams() {
    Map<String, String> params = {};
    
    if (startDate != null) {
      params['start_date'] = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    }
    
    if (endDate != null) {
      params['end_date'] = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    }
    
    return params;
  }

  bool get hasFilters => startDate != null || endDate != null || (searchQuery != null && searchQuery!.isNotEmpty);

  bool get hasDateFilter => startDate != null || endDate != null;

  String get dateRangeText {
    if (startDate != null && endDate != null) {
      return 'Periode: ${_formatDate(startDate!)} s/d ${_formatDate(endDate!)}';
    } else if (startDate != null) {
      return 'Dari Tanggal: ${_formatDate(startDate!)}';
    } else if (endDate != null) {
      return 'Sampai Tanggal: ${_formatDate(endDate!)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}