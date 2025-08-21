// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pertareport_mobile/models/report/jenis_kegiatan.dart';
import 'package:pertareport_mobile/models/report/laporan.dart';
import 'package:pertareport_mobile/services/api_config.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;
  
  // Get all jenis kegiatan
  static Future<List<JenisKegiatan>> getJenisKegiatan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jenis-kegiatan/'),
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
        Uri.parse('$baseUrl/laporan/'),
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
        Uri.parse('$baseUrl/add-kegiatan/'),
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
        Uri.parse('$baseUrl/upload-images/'),
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

  // Upload images for specific kegiatan
  static Future<UploadImagesResponse> uploadImagesForKegiatan({
    required int kegiatanLaporanId,
    required List<File> images,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-kegiatan-images/'),
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

  // Get all laporan list
  static Future<List<Laporan>> getLaporanList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/laporan-list/'),
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
}

// Response model classes untuk API responses
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