// To parse this JSON data, do
//
//     final bookmark = bookmarkFromJson(jsonString);

import 'dart:convert';

Bookmark bookmarkFromJson(String str) => Bookmark.fromJson(json.decode(str));

String bookmarkToJson(Bookmark data) => json.encode(data.toJson());

class Bookmark {
  bool success;
  List<BookmarkedProduct> bookmarkedProducts;

  Bookmark({
    required this.success,
    required this.bookmarkedProducts,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        success: json["success"],
        bookmarkedProducts: List<BookmarkedProduct>.from(
            json["bookmarked_products"]
                .map((x) => BookmarkedProduct.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "bookmarked_products":
            List<dynamic>.from(bookmarkedProducts.map((x) => x.toJson())),
      };
}

class BookmarkedProduct {
  int id;
  String nama;
  String kategori;
  String harga;
  String namaRestoran;
  String lokasi;
  String urlGambar;
  DateTime createdAt;
  DateTime updatedAt;

  BookmarkedProduct({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.namaRestoran,
    required this.lokasi,
    required this.urlGambar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookmarkedProduct.fromJson(Map<String, dynamic> json) =>
      BookmarkedProduct(
        id: json["id"],
        nama: json["nama"],
        kategori: json["kategori"],
        harga: json["harga"],
        namaRestoran: json["nama_restoran"],
        lokasi: json["lokasi"],
        urlGambar: json["url_gambar"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "kategori": kategori,
        "harga": harga,
        "nama_restoran": namaRestoran,
        "lokasi": lokasi,
        "url_gambar": urlGambar,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
