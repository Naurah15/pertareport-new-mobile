// models/report/spbu.dart
class SPBU {
  final int id;
  final String nama;
  final String kode;
  final String? alamat;

  SPBU({
    required this.id,
    required this.nama,
    required this.kode,
    this.alamat,
  });

  factory SPBU.fromJson(Map<String, dynamic> json) {
    return SPBU(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kode': kode,
      'alamat': alamat,
    };
  }

  @override
  String toString() => '$kode - $nama';
}