// services/history_api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';
import 'package:pertareport_mobile/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class HistoryApiService {
  static final String baseUrl = ApiConfig.baseUrlHistory;
  static final String mediaBaseUrl = ApiConfig.mediaBaseUrl;

  /// Get current username and check if admin
  static Future<Map<String, dynamic>> _getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final password = prefs.getString('password') ?? '';
      
      // Check if user is admin
      final isAdmin = (username == 'admin' && password == 'Mimin1234%');
      
      return {
        'username': username,
        'isAdmin': isAdmin,
      };
    } catch (e) {
      print('Error getting user info: $e');
      return {
        'username': '',
        'isAdmin': false,
      };
    }
  }

  /// Get history list with user filtering
  static Future<List<HistoryLaporan>> getHistoryList({HistoryFilter? filter}) async {
    try {
      // Get user info
      final userInfo = await _getUserInfo();
      final username = userInfo['username'] as String;
      final isAdmin = userInfo['isAdmin'] as bool;

      // Build query parameters
      Map<String, String> queryParams = {};
      
      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      // Add username filter for non-admin users
      if (!isAdmin && username.isNotEmpty) {
        queryParams['nama_team_support'] = username;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      
      print('Fetching history with params: $queryParams');
      print('Is Admin: $isAdmin');
      print('Username: $username');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('laporan_list')) {
          data = responseData['laporan_list'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          throw Exception('Unexpected response format');
        }

        // Additional client-side filtering for non-admin users as safety measure
        List<HistoryLaporan> laporanList = data
            .map((item) => HistoryLaporan.fromJson(item, mediaBaseUrl))
            .toList();

        // If not admin, double-check filtering on client side
        if (!isAdmin && username.isNotEmpty) {
          laporanList = laporanList.where((laporan) {
            return laporan.namaTeamSupport.toLowerCase() == username.toLowerCase();
          }).toList();
        }

        print('Total laporan fetched: ${laporanList.length}');
        return laporanList;
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getHistoryList: $e');
      throw Exception('Error loading history: $e');
    }
  }

  /// Download laporan file (Excel or PDF) for web
  static String getDownloadUrl(int laporanId, String type) {
    final endpoint = type == 'excel' ? 'download-excel' : 'download-pdf';
    return '$baseUrl$endpoint/$laporanId/';
  }

  /// Download laporan file (Excel or PDF) for mobile
  static Future<Uint8List> downloadLaporanFile(int laporanId, String type) async {
    try {
      final url = getDownloadUrl(laporanId, type);
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  /// Get Google Maps URL from coordinates
  static String getGoogleMapsUrl(String lokasi) {
    // Remove spaces and parse coordinates
    final coords = lokasi.replaceAll(' ', '').split(',');
    if (coords.length == 2) {
      final lat = coords[0].trim();
      final lng = coords[1].trim();
      return 'https://www.google.com/maps?q=$lat,$lng';
    }
    // If format is not lat,lng, try to search the location
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(lokasi)}';
  }

  /// Bulk download with filtering based on user role
  static Future<Uint8List> bulkDownload({
    required String type,
    HistoryFilter? filter,
  }) async {
    try {
      // Get user info
      final userInfo = await _getUserInfo();
      final username = userInfo['username'] as String;
      final isAdmin = userInfo['isAdmin'] as bool;

      // Build query parameters
      Map<String, String> queryParams = {'type': type};
      
      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      // Add username filter for non-admin users
      if (!isAdmin && username.isNotEmpty) {
        queryParams['nama_team_support'] = username;
      }

      final uri = Uri.parse('${baseUrl}bulk-download/').replace(queryParameters: queryParams);
      
      print('Bulk download with params: $queryParams');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during bulk download: $e');
    }
  }

  /// Get bulk download URL for web (synchronous version for immediate use)
  static Future<String> getBulkDownloadUrl({
    required String type,
    HistoryFilter? filter,
  }) async {
    // Get user info
    final userInfo = await _getUserInfo();
    final username = userInfo['username'] as String;
    final isAdmin = userInfo['isAdmin'] as bool;

    // Build query parameters
    Map<String, String> queryParams = {'type': type};
    
    if (filter != null) {
      queryParams.addAll(filter.toQueryParams());
    }

    // Add username filter for non-admin users
    if (!isAdmin && username.isNotEmpty) {
      queryParams['nama_team_support'] = username;
    }

    final uri = Uri.parse('${baseUrl}bulk-download/').replace(queryParameters: queryParams);
    return uri.toString();
  }

  /// Download bulk file for mobile
  static Future<Uint8List> downloadBulkFile(String type, {HistoryFilter? filter}) async {
    return await bulkDownload(type: type, filter: filter);
  }
}