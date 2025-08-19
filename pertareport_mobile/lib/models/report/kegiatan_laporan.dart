// models/report/kegiatan_laporan.dart
import 'jenis_kegiatan.dart';
import 'kegiatan_foto.dart';

class KegiatanLaporan {
  final int id;
  final int laporanId; // Foreign key to Laporan
  final JenisKegiatan kegiatan;
  final String? kegiatanOther;
  final String remark;
  final String? foto; // Single foto field from Django model
  final List<KegiatanFoto> fotoList; // Related foto_list

  KegiatanLaporan({
    required this.id,
    required this.laporanId,
    required this.kegiatan,
    this.kegiatanOther,
    required this.remark,
    this.foto,
    required this.fotoList,
  });

  factory KegiatanLaporan.fromJson(Map<String, dynamic> json) {
    return KegiatanLaporan(
      id: json['id'],
      laporanId: json['laporan'], // Foreign key ID
      kegiatan: JenisKegiatan.fromJson(json['kegiatan']), // Should be full object
      kegiatanOther: json['kegiatan_other'],
      remark: json['remark'] ?? '',
      foto: json['foto'],
      fotoList: (json['foto_list'] as List<dynamic>?)
              ?.map((f) => KegiatanFoto.fromJson(f))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'laporan': laporanId,
      'kegiatan': kegiatan.id, // Send only ID for foreign key
      'kegiatan_other': kegiatanOther,
      'remark': remark,
      'foto': foto,
      'foto_list': fotoList.map((f) => f.toJson()).toList(),
    };
  }

  // Method to get display name (matches Django's get_kegiatan_display_name)
  String get displayName {
    if (kegiatanOther != null && kegiatanOther!.isNotEmpty) {
      return kegiatanOther!;
    }
    return kegiatan.nama;
  }
}
