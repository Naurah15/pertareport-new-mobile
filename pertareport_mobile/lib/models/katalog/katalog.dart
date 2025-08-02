import 'dart:convert';

List<KatalogResponse> welcomeFromJson(String str) => List<KatalogResponse>.from(
    json.decode(str).map((x) => KatalogResponse.fromJson(x)));

String welcomeToJson(List<KatalogResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KatalogResponse {
  Model model;
  int pk;
  Fields fields;

  KatalogResponse({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory KatalogResponse.fromJson(Map<String, dynamic> json) =>
      KatalogResponse(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  Kategori kategori;
  String nama;
  int harga;
  String namaRestoran;
  String lokasi;
  String urlGambar;

  Fields({
    required this.kategori,
    required this.nama,
    required this.harga,
    required this.namaRestoran,
    required this.lokasi,
    required this.urlGambar,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        kategori: kategoriValues.map[json["kategori"]]!,
        nama: json["nama"],
        harga: json["harga"],
        namaRestoran: json["nama_restoran"],
        lokasi: json["lokasi"],
        urlGambar: json["url_gambar"],
      );

  Map<String, dynamic> toJson() => {
        "kategori": kategoriValues.reverse[kategori],
        "nama": nama,
        "harga": harga,
        "nama_restoran": namaRestoran,
        "lokasi": lokasi,
        "url_gambar": urlGambar,
      };
}

enum Kategori { CAMILAN, MAKANAN, MAKANAN_PENUTUP, MINUMAN }

final kategoriValues = EnumValues({
  "Camilan": Kategori.CAMILAN,
  "Makanan": Kategori.MAKANAN,
  "Makanan Penutup": Kategori.MAKANAN_PENUTUP,
  "Minuman": Kategori.MINUMAN
});

enum Model { KATALOG_PRODUCT }

final modelValues = EnumValues({"katalog.product": Model.KATALOG_PRODUCT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
