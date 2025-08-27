// services/api_service_history_extension.dart
// Add these methods to your existing ApiService class

import 'dart:typed_data';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_summary.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServiceHistoryExtension {
  // Add these methods to your existing ApiService class
  
  static const String baseUrl = 'your-api-base-url'; // Replace with your actual API base URL
  
  /// Get history list of reports for the current user
  static Future<List<HistoryLaporan>> getHistoryList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}', // Implement your auth token logic
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> laporanList = data['laporan_list'] ?? [];
        
        return laporanList
            .map((json) => HistoryLaporan.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading history: $e');
    }
  }

  /// Get history summary/dashboard data
  static Future<HistorySummary> getHistorySummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/summary/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return HistorySummary.fromJson(data);
      } else {
        throw Exception('Failed to load summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading summary: $e');
    }
  }

  /// Download report file (Excel or PDF)
  static Future<Uint8List> downloadLaporanFile(int laporanId, String type) async {
    try {
      final endpoint = type == 'excel' 
          ? '$baseUrl/history/download/excel/$laporanId/'
          : '$baseUrl/history/download/pdf/$laporanId/';
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  /// Get download URL for web (direct link)
  static String getDownloadUrl(int laporanId, String type) {
    return type == 'excel' 
        ? '$baseUrl/history/download/excel/$laporanId/'
        : '$baseUrl/history/download/pdf/$laporanId/';
  }

  /// Search history reports
  static Future<List<HistoryLaporan>> searchHistory({
    String? query,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, String> queryParams = {};
      
      if (query != null && query.isNotEmpty) queryParams['search'] = query;
      if (filter != null && filter != 'all') queryParams['filter'] = filter;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl/history/search/').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        return results
            .map((json) => HistoryLaporan.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching history: $e');
    }
  }

  /// Get activity statistics for dashboard
  static Future<Map<String, dynamic>> getActivityStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/stats/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  /// Export multiple reports (bulk download)
  static Future<Uint8List> exportBulkReports({
    required List<int> reportIds,
    required String format, // 'excel' or 'pdf'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history/bulk-export/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: json.encode({
          'report_ids': reportIds,
          'format': format,
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to export reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error exporting reports: $e');
    }
  }

  /// Delete a report (if allowed)
  static Future<bool> deleteReport(int laporanId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/history/delete/$laporanId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting report: $e');
    }
  }

  /// Get report details by ID
  static Future<HistoryLaporan> getReportById(int laporanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/detail/$laporanId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return HistoryLaporan.fromJson(data);
      } else {
        throw Exception('Failed to load report details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading report details: $e');
    }
  }

  // Helper method to get auth token - implement based on your auth system
  static Future<String> _getAuthToken() async {
    // TODO: Implement your authentication token retrieval logic
    // This could be from SharedPreferences, Secure Storage, etc.
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('auth_token') ?? '';
    return 'your-auth-token-here';
  }
}

// Add these methods to your existing ApiService class:
/*
  // History methods - add these to your existing ApiService class

  static Future<List<HistoryLaporan>> getHistoryList() {
    return ApiServiceHistoryExtension.getHistoryList();
  }

  static Future<HistorySummary> getHistorySummary() {
    return ApiServiceHistoryExtension.getHistorySummary();
  }

  static Future<Uint8List> downloadLaporanFile(int laporanId, String type) {
    return ApiServiceHistoryExtension.downloadLaporanFile(laporanId, type);
  }

  static String getDownloadUrl(int laporanId, String type) {
    return ApiServiceHistoryExtension.getDownloadUrl(laporanId, type);
  }

  static Future<List<HistoryLaporan>> searchHistory({
    String? query,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ApiServiceHistoryExtension.searchHistory(
      query: query,
      filter: filter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  static Future<Map<String, dynamic>> getActivityStats() {
    return ApiServiceHistoryExtension.getActivityStats();
  }

  static Future<Uint8List> exportBulkReports({
    required List<int> reportIds,
    required String format,
  }) {
    return ApiServiceHistoryExtension.exportBulkReports(
      reportIds: reportIds,
      format: format,
    );
  }

  static Future<bool> deleteReport(int laporanId) {
    return ApiServiceHistoryExtension.deleteReport(laporanId);
  }

  static Future<HistoryLaporan> getReportById(int laporanId) {
    return ApiServiceHistoryExtension.getReportById(laporanId);
  }
*/