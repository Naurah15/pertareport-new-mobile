// lib/models/history/history_laporan.dart
class HistoryLaporan {
  final int id;
  final String noDocument;
  final String lokasi;
  final String namaTeamSupport;
  final DateTime tanggalProses;
  final List<HistoryKegiatan> kegiatanList;

  HistoryLaporan({
    required this.id,
    required this.noDocument,
    required this.lokasi,
    required this.namaTeamSupport,
    required this.tanggalProses,
    required this.kegiatanList,
  });

  factory HistoryLaporan.fromJson(Map<String, dynamic> json) {
    return HistoryLaporan(
      id: json['id'],
      noDocument: json['no_document'],
      lokasi: json['lokasi'] ?? '',
      namaTeamSupport: json['nama_team_support'] ?? '',
      tanggalProses: DateTime.parse(json['tanggal_proses']),
      kegiatanList: (json['kegiatan_list'] as List<dynamic>?)
          ?.map((item) => HistoryKegiatan.fromJson(item))
          .toList() ?? [],
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
    };
  }
}

class HistoryKegiatan {
  final String displayName;
  final String remark;
  final String? foto;
  final List<HistoryFoto> fotoList;

  HistoryKegiatan({
    required this.displayName,
    required this.remark,
    this.foto,
    required this.fotoList,
  });

  factory HistoryKegiatan.fromJson(Map<String, dynamic> json) {
    return HistoryKegiatan(
      displayName: json['display_name'] ?? '',
      remark: json['remark'] ?? '',
      foto: json['foto'],
      fotoList: (json['foto_list'] as List<dynamic>?)
          ?.map((item) => HistoryFoto.fromJson(item))
          .toList() ?? [],
    );
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
  final String foto;

  HistoryFoto({
    required this.id,
    required this.foto,
  });

  factory HistoryFoto.fromJson(Map<String, dynamic> json) {
    return HistoryFoto(
      id: json['id'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto': foto,
    };
  }
}