// services/api_service.dart - Fixed version with all static methods
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pertareport_mobile/models/report/jenis_kegiatan.dart';
import 'package:pertareport_mobile/models/report/laporan.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_summary.dart';
import 'package:pertareport_mobile/services/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static final String reportUrl = ApiConfig.baseUrlReport;
  static final String historyUrl = ApiConfig.baseUrlHistory;
  
  // Get all jenis kegiatan
  static Future<List<JenisKegiatan>> getJenisKegiatan() async {
    try {
      final response = await http.get(
        Uri.parse('${reportUrl}jenis-kegiatan/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => JenisKegiatan.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load jenis kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jenis kegiatan: $e');
    }
  }

  // Create new laporan
  static Future<CreateLaporanResponse> createLaporan({
    required String lokasi,
    required String namaTeamSupport,
    required String remark,
    required int kegiatanId,
    String? kegiatanOther,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${reportUrl}laporan/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'lokasi': lokasi,
          'nama_team_support': namaTeamSupport,
          'remark': remark,
          'kegiatan_id': kegiatanId,
          if (kegiatanOther != null) 'kegiatan_other': kegiatanOther,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return CreateLaporanResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create laporan');
      }
    } catch (e) {
      throw Exception('Error creating laporan: $e');
    }
  }

  // Add kegiatan to existing laporan
  static Future<CreateLaporanResponse> addKegiatanToLaporan({
    required int laporanId,
    required String remark,
    required int kegiatanId,
    String? kegiatanOther,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${reportUrl}add-kegiatan/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'laporan_id': laporanId,
          'remark': remark,
          'kegiatan_id': kegiatanId,
          if (kegiatanOther != null) 'kegiatan_other': kegiatanOther,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return CreateLaporanResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add kegiatan to laporan');
      }
    } catch (e) {
      throw Exception('Error adding kegiatan to laporan: $e');
    }
  }

  // Upload images for laporan (old method - for backward compatibility)
  static Future<UploadImagesResponse> uploadImages({
    required int laporanId,
    required List<File> images,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${reportUrl}upload-images/'),
      );

      request.fields['laporan_id'] = laporanId.toString();

      for (File image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UploadImagesResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload images');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  // Upload images for specific kegiatan (Mobile/Desktop version)
  static Future<UploadImagesResponse> uploadImagesForKegiatan({
    required int kegiatanLaporanId,
    required List<File> images,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${reportUrl}upload-kegiatan-images/'),
      );

      request.fields['kegiatan_laporan_id'] = kegiatanLaporanId.toString();

      for (File image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UploadImagesResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload images for kegiatan');
      }
    } catch (e) {
      throw Exception('Error uploading images for kegiatan: $e');
    }
  }

  // Upload web images for specific kegiatan
  static Future<UploadImagesResponse> uploadWebImagesForKegiatan({
    required int kegiatanLaporanId,
    required List<Uint8List> webImages,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${reportUrl}upload-kegiatan-images/'),
      );

      request.fields['kegiatan_laporan_id'] = kegiatanLaporanId.toString();

      for (int i = 0; i < webImages.length; i++) {
        final imageBytes = webImages[i];
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: 'image_$i.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UploadImagesResponse.fromJson(responseData);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload web images for kegiatan');
      }
    } catch (e) {
      throw Exception('Error uploading web images for kegiatan: $e');
    }
  }

  // Universal upload images for kegiatan
  static Future<UploadImagesResponse> uploadUniversalImagesForKegiatan({
    required int kegiatanLaporanId,
    List<File>? mobileImages,
    List<Uint8List>? webImages,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${reportUrl}upload-kegiatan-images/'),
      );

      request.fields['kegiatan_laporan_id'] = kegiatanLaporanId.toString();
      
      print('Uploading to kegiatan laporan ID: $kegiatanLaporanId');

      // Handle mobile/desktop images (File)
      if (mobileImages != null && mobileImages.isNotEmpty) {
        for (int i = 0; i < mobileImages.length; i++) {
          final image = mobileImages[i];
          print('Adding mobile image ${i + 1}: ${image.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'images', 
              image.path,
              filename: 'mobile_image_${i + 1}.jpg',
            ),
          );
        }
      }

      // Handle web images (Uint8List)
      if (webImages != null && webImages.isNotEmpty) {
        for (int i = 0; i < webImages.length; i++) {
          final imageBytes = webImages[i];
          print('Adding web image ${i + 1}, size: ${imageBytes.length} bytes');
          
          String contentType = 'image/jpeg';
          String filename = 'web_image_${i + 1}.jpg';
          
          // Check for PNG magic bytes
          if (imageBytes.length > 8) {
            final pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
            bool isPng = true;
            for (int j = 0; j < 8 && j < imageBytes.length; j++) {
              if (imageBytes[j] != pngHeader[j]) {
                isPng = false;
                break;
              }
            }
            if (isPng) {
              contentType = 'image/png';
              filename = 'web_image_${i + 1}.png';
            }
          }
          
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              imageBytes,
              filename: filename,
              contentType: MediaType.parse(contentType),
            ),
          );
        }
      }

      print('Sending request with ${request.files.length} files...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final uploadResponse = UploadImagesResponse.fromJson(responseData);
        
        if (uploadResponse.files.isEmpty) {
          throw Exception('No files were actually uploaded to the server');
        }
        
        print('Successfully uploaded ${uploadResponse.files.length} files');
        return uploadResponse;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload images for kegiatan');
      }
    } catch (e) {
      print('Error uploading images for kegiatan: $e');
      throw Exception('Error uploading images for kegiatan: $e');
    }
  }

  // Get all laporan list
  static Future<List<Laporan>> getLaporanList() async {
    try {
      final response = await http.get(
        Uri.parse('${historyUrl}laporan-list/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Laporan.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load laporan list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching laporan list: $e');
    }
  }

  // ========== HISTORY METHODS (NOW STATIC) ==========
  
  /// Get history summary/dashboard data
  static Future<HistorySummary> getHistorySummary() async {
    try {
      final response = await http.get(
        Uri.parse('${historyUrl}/history/summary/'),
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

  /// Get history list of reports for the current user
  static Future<List<HistoryLaporan>> getHistoryList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrlHistory}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map && responseData.containsKey('laporan_list')) {
          final List<dynamic> data = responseData['laporan_list'];
          return data.map((item) => HistoryLaporan.fromJson(item)).toList();
        } else if (responseData is List) {
          return responseData.map((item) => HistoryLaporan.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getHistoryList: $e');
      throw Exception('Error loading history: $e');
    }
  }


  /// Download report file (Excel or PDF)
  static Future<Uint8List> downloadLaporanFile(int laporanId, String type) async {
    try {
      final endpoint = type == 'excel' 
          ? '$historyUrl/history/download/excel/$laporanId/'
          : '$historyUrl/history/download/pdf/$laporanId/';
      
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
        ? '$historyUrl/history/download/excel/$laporanId/'
        : '$historyUrl/history/download/pdf/$laporanId/';
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

      final uri = Uri.parse('${historyUrl}history/search/').replace(queryParameters: queryParams);
      
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
        Uri.parse('${historyUrl}history/stats/'),
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

// Response model classes
class CreateLaporanResponse {
  final String status;
  final String message;
  final int laporanId;
  final String noDocument;
  final int kegiatanLaporanId;

  CreateLaporanResponse({
    required this.status,
    required this.message,
    required this.laporanId,
    required this.noDocument,
    required this.kegiatanLaporanId,
  });

  factory CreateLaporanResponse.fromJson(Map<String, dynamic> json) {
    return CreateLaporanResponse(
      status: json['status'],
      message: json['message'],
      laporanId: json['laporan_id'],
      noDocument: json['no_document'],
      kegiatanLaporanId: json['kegiatan_laporan_id'],
    );
  }
}

class UploadImagesResponse {
  final String status;
  final String message;
  final List<UploadedFile> files;

  UploadImagesResponse({
    required this.status,
    required this.message,
    required this.files,
  });

  factory UploadImagesResponse.fromJson(Map<String, dynamic> json) {
    return UploadImagesResponse(
      status: json['status'],
      message: json['message'],
      files: (json['files'] as List)
          .map((item) => UploadedFile.fromJson(item))
          .toList(),
    );
  }
}

class UploadedFile {
  final int id;
  final String? url;

  UploadedFile({required this.id, this.url});

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      url: json['url'],
    );
  }
}