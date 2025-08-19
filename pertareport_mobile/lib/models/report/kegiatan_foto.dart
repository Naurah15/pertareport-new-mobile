// kegiatan_foto.dart
class KegiatanFoto {
  final int id;
  final String foto;

  KegiatanFoto({required this.id, required this.foto});

  factory KegiatanFoto.fromJson(Map<String, dynamic> json) {
    return KegiatanFoto(
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
