// models/report/kegiatan_foto.dart
class KegiatanFoto {
  final int id;
  final String foto; // This should match Django's 'foto' field, not 'url'

  KegiatanFoto({required this.id, required this.foto});

  factory KegiatanFoto.fromJson(Map<String, dynamic> json) {
    return KegiatanFoto(
      id: json['id'],
      foto: json['foto'], // Django sends this as 'foto'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto': foto,
    };
  }

  // Helper method to get full URL if needed
  String get imageUrl => foto; // Assuming foto contains full URL from backend
}