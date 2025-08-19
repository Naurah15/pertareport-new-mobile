// models/kegiatan_foto.dart
class KegiatanFoto {
  final int id;
  final String? url; // Changed from 'foto' to 'url'

  KegiatanFoto({required this.id, this.url});

  factory KegiatanFoto.fromJson(Map<String, dynamic> json) {
    return KegiatanFoto(
      id: json['id'],
      url: json['url'], // Django mengirim sebagai 'url', bukan 'foto'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}