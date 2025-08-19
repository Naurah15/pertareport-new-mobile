// models/report/laporan.dart
import 'kegiatan_laporan.dart';

class Laporan {
  final int id;
  final String lokasi;
  final String namaTeamSupport;
  final DateTime tanggalProses;
  final String noDocument;
  final List<KegiatanLaporan> kegiatanList;

  Laporan({
    required this.id,
    required this.lokasi,
    required this.namaTeamSupport,
    required this.tanggalProses,
    required this.noDocument,
    required this.kegiatanList,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    return Laporan(
      id: json['id'],
      lokasi: json['lokasi'],
      namaTeamSupport: json['nama_team_support'],
      tanggalProses: DateTime.parse(json['tanggal_proses']),
      noDocument: json['no_document'],
      kegiatanList: (json['kegiatan_list'] as List<dynamic>?)
              ?.map((k) => KegiatanLaporan.fromJson(k))
              .toList() ??
          [],
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
    };
  }

  @override
  String toString() => noDocument;
}
