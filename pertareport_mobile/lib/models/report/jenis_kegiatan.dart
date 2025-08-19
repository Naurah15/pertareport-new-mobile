// models/report/jenis_kegiatan.dart
class JenisKegiatan {
  final int id;
  final String nama;

  JenisKegiatan({required this.id, required this.nama});

  factory JenisKegiatan.fromJson(Map<String, dynamic> json) {
    return JenisKegiatan(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }

  @override
  String toString() => nama;
}
