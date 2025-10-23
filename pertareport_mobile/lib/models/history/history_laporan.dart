import 'package:pertareport_mobile/models/report/spbu.dart';
// lib/models/history/history_laporan.dart
class HistoryLaporan {
  final int id;
  final String noDocument;
  final String lokasi;
  final String namaTeamSupport;
  final DateTime tanggalProses;
  final List<HistoryKegiatan> kegiatanList;
  final SPBU? spbu;

  HistoryLaporan({
    required this.id,
    required this.noDocument,
    required this.lokasi,
    required this.namaTeamSupport,
    required this.tanggalProses,
    required this.kegiatanList,
    this.spbu,
  });

  factory HistoryLaporan.fromJson(Map<String, dynamic> json, String mediaBaseUrl) {
    return HistoryLaporan(
      id: json['id'],
      noDocument: json['no_document'],
      lokasi: json['lokasi'] ?? '',
      namaTeamSupport: json['nama_team_support'] ?? '',
      tanggalProses: DateTime.parse(json['tanggal_proses']),
      kegiatanList: (json['kegiatan_list'] as List<dynamic>?)
          ?.map((item) => HistoryKegiatan.fromJson(item, mediaBaseUrl))
          .toList() ?? [],
      spbu: json['spbu'] != null ? SPBU.fromJson(json['spbu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_document': noDocument,
      'lokasi': lokasi,
      'nama_team_support': namaTeamSupport,
      'tanggal_proses': tanggalProses.toIso8601String(),
      'kegiatan_list': kegiatanList.map((k) => k.toJson()).toList(),
      'spbu': spbu?.toJson(),
    };
  }
}

class HistoryKegiatan {
  final String displayName;
  final String remark;
  final String? foto; // This will contain the full URL
  final List<HistoryFoto> fotoList;

  HistoryKegiatan({
    required this.displayName,
    required this.remark,
    this.foto,
    required this.fotoList,
  });

  factory HistoryKegiatan.fromJson(Map<String, dynamic> json, String mediaBaseUrl) {
    return HistoryKegiatan(
      displayName: json['display_name'] ?? '',
      remark: json['remark'] ?? '',
      foto: _buildFullPhotoUrl(json['foto'], mediaBaseUrl),
      fotoList: (json['foto_list'] as List<dynamic>?)
          ?.map((item) => HistoryFoto.fromJson(item, mediaBaseUrl))
          .toList() ?? [],
    );
  }

  static String? _buildFullPhotoUrl(String? photoPath, String mediaBaseUrl) {
    if (photoPath == null || photoPath.isEmpty) return null;
    
    // If it's already a full URL, return as is
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    
    // Remove leading slash if present and build full URL
    String cleanPath = photoPath.startsWith('/') ? photoPath.substring(1) : photoPath;
    return '$mediaBaseUrl/$cleanPath';
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'remark': remark,
      'foto': foto,
      'foto_list': fotoList.map((f) => f.toJson()).toList(),
    };
  }
}

class HistoryFoto {
  final int id;
  final String foto; // This will contain the full URL

  HistoryFoto({
    required this.id,
    required this.foto,
  });

  factory HistoryFoto.fromJson(Map<String, dynamic> json, String mediaBaseUrl) {
    return HistoryFoto(
      id: json['id'],
      foto: _buildFullPhotoUrl(json['foto'], mediaBaseUrl),
    );
  }

  static String _buildFullPhotoUrl(String photoPath, String mediaBaseUrl) {
    // If it's already a full URL, return as is
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    
    // Remove leading slash if present and build full URL
    String cleanPath = photoPath.startsWith('/') ? photoPath.substring(1) : photoPath;
    return '$mediaBaseUrl/$cleanPath';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto': foto,
    };
  }
}