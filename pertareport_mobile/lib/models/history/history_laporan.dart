// models/history/history_laporan.dart
import 'package:pertareport_mobile/models/report/kegiatan_laporan.dart';

class HistoryLaporan {
  final int id;
  final String lokasi;
  final String namaTeamSupport;
  final DateTime tanggalProses;
  final String noDocument;
  final List<KegiatanLaporan> kegiatanList;
  final bool canDownload;

  HistoryLaporan({
    required this.id,
    required this.lokasi,
    required this.namaTeamSupport,
    required this.tanggalProses,
    required this.noDocument,
    required this.kegiatanList,
    this.canDownload = true,
  });

  factory HistoryLaporan.fromJson(Map<String, dynamic> json) {
    return HistoryLaporan(
      id: json['id'],
      lokasi: json['lokasi'],
      namaTeamSupport: json['nama_team_support'],
      tanggalProses: DateTime.parse(json['tanggal_proses']),
      noDocument: json['no_document'],
      kegiatanList: (json['kegiatan_list'] as List<dynamic>?)
              ?.map((k) => KegiatanLaporan.fromJson(k))
              .toList() ??
          [],
      canDownload: json['can_download'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lokasi': lokasi,
      'nama_team_support': namaTeamSupport,
      'tanggal_proses': tanggalProses.toIso8601String(),
      'no_document': noDocument,
      'kegiatan_list': kegiatanList.map((k) => k.toJson()).toList(),
      'can_download': canDownload,
    };
  }

  // Helper methods
  String get formattedDate {
    return "${tanggalProses.day}/${tanggalProses.month}/${tanggalProses.year} ${tanggalProses.hour}:${tanggalProses.minute.toString().padLeft(2, '0')}";
  }

  int get totalPhotos {
    int count = 0;
    for (var kegiatan in kegiatanList) {
      if (kegiatan.foto != null) count++;
      count += kegiatan.fotoList.length;
    }
    return count;
  }

  String get locationUrl {
    return "https://www.google.com/maps?q=$lokasi";
  }

  @override
  String toString() => noDocument;
}