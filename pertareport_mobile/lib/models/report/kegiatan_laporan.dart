// kegiatan_laporan.dart
import 'jenis_kegiatan.dart';
import 'kegiatan_foto.dart';

class KegiatanLaporan {
  final int id;
  final JenisKegiatan kegiatan;
  final String? kegiatanOther;
  final String remark;
  final String foto;
  final List<KegiatanFoto> fotoList;

  KegiatanLaporan({
    required this.id,
    required this.kegiatan,
    this.kegiatanOther,
    required this.remark,
    required this.foto,
    required this.fotoList,
  });

  factory KegiatanLaporan.fromJson(Map<String, dynamic> json) {
    return KegiatanLaporan(
      id: json['id'],
      kegiatan: JenisKegiatan.fromJson(json['kegiatan']),
      kegiatanOther: json['kegiatan_other'],
      remark: json['remark'],
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
      'kegiatan': kegiatan.toJson(),
      'kegiatan_other': kegiatanOther,
      'remark': remark,
      'foto': foto,
      'foto_list': fotoList.map((f) => f.toJson()).toList(),
    };
  }
}
