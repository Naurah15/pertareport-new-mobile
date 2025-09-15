// lib/services/history_api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';
import 'package:pertareport_mobile/services/api_config.dart';
import 'package:flutter/foundation.dart';

class HistoryApiService {
  static final String baseUrl = ApiConfig.baseUrlHistory;
  
  // Add your media base URL here - replace with your actual media server URL
  static final String mediaBaseUrl = ApiConfig.mediaBaseUrl; // e.g., "https://your-api-server.com"

  /// Get history list with optional filters
  static Future<List<HistoryLaporan>> getHistoryList({
    HistoryFilter? filter,
  }) async {
    try {
      String endpoint = baseUrl;
      
      // Add query parameters if filter exists
      if (filter != null && filter.hasDateFilter) {
        final queryParams = filter.toQueryParams();
        if (queryParams.isNotEmpty) {
          final queryString = queryParams.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
          endpoint += '?$queryString';
        }
      }

      print('Fetching history from: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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

        List<HistoryLaporan> laporanList = data
            .map((item) => HistoryLaporan.fromJson(item, mediaBaseUrl))
            .toList();

        // Apply search filter if exists
        if (filter?.searchQuery != null && filter!.searchQuery!.isNotEmpty) {
          final query = filter.searchQuery!.toLowerCase();
          laporanList = laporanList.where((laporan) {
            return laporan.noDocument.toLowerCase().contains(query) ||
                   laporan.lokasi.toLowerCase().contains(query) ||
                   laporan.namaTeamSupport.toLowerCase().contains(query);
          }).toList();
        }

        return laporanList;
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getHistoryList: $e');
      throw Exception('Error loading history: $e');
    }
  }

  /// Convert relative photo path to full URL
  static String? getFullPhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return null;
    
    // If it's already a full URL, return as is
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    
    // Remove leading slash if present
    String cleanPath = photoPath.startsWith('/') ? photoPath.substring(1) : photoPath;
    
    return '$mediaBaseUrl/$cleanPath';
  }

  /// Download individual laporan file (Excel or PDF)
  static Future<Uint8List> downloadLaporanFile(int laporanId, String type) async {
    try {
      final endpoint = type.toLowerCase() == 'excel' 
          ? '${baseUrl}download/excel/$laporanId/'
          : '${baseUrl}download/pdf/$laporanId/';
      
      print('Downloading from: $endpoint');

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
      throw Exception('Error downloading file: $e');
    }
  }

  /// Download bulk files (Excel or PDF)
  static Future<Uint8List> downloadBulkFile(String type, {HistoryFilter? filter}) async {
    try {
      String endpoint = type.toLowerCase() == 'excel' 
          ? '${baseUrl}bulk/excel/'
          : '${baseUrl}bulk/pdf/';
      
      // Add query parameters if filter exists
      if (filter != null && filter.hasDateFilter) {
        final queryParams = filter.toQueryParams();
        if (queryParams.isNotEmpty) {
          final queryString = queryParams.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
          endpoint += '?$queryString';
        }
      }

      print('Downloading bulk from: $endpoint');

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download bulk file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading bulk file: $e');
      throw Exception('Error downloading bulk file: $e');
    }
  }

  /// Get download URL for web (direct link)
  static String getDownloadUrl(int laporanId, String type) {
    return type.toLowerCase() == 'excel' 
        ? '${baseUrl}download/excel/$laporanId/'
        : '${baseUrl}download/pdf/$laporanId/';
  }

  /// Get bulk download URL for web (direct link)
  static String getBulkDownloadUrl(String type, {HistoryFilter? filter}) {
    String url = type.toLowerCase() == 'excel' 
        ? '${baseUrl}bulk/excel/'
        : '${baseUrl}bulk/pdf/';
    
    // Add query parameters if filter exists
    if (filter != null && filter.hasDateFilter) {
      final queryParams = filter.toQueryParams();
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }
    }
    
    return url;
  }

  /// Get Google Maps URL for location
  static String getGoogleMapsUrl(String location) {
    return 'https://www.google.com/maps?q=${Uri.encodeComponent(location)}';
  }
}