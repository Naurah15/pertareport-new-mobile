import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  Future<List<BookmarkedProduct>> fetchBookmarks() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/bookmark/bookmarked-products_flutter/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        return List<BookmarkedProduct>.from(
          responseData['bookmarked_products']
              .map((x) => BookmarkedProduct.fromJson(x)),
        );
      } else {
        throw Exception('Failed to load bookmarks');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<void> deleteBookmark(int productId) async {
    final url =
        Uri.parse('http://127.0.0.1:8000/bookmark/remove_flutter/$productId/');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Berhasil dihapus
        setState(() {
          // Refresh data setelah penghapusan berhasil
          fetchBookmarks();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark successfully removed')),
        );
      } else {
        throw Exception('Failed to delete bookmark');
      }
    } catch (e) {
      print('Error deleting bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting bookmark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: FutureBuilder<List<BookmarkedProduct>>(
        future: fetchBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarks available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final bookmarks = snapshot.data!;
            return ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final product = bookmarks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      product.urlGambar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                    title: Text(
                      product.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${product.kategori}'),
                        Text('Harga: ${product.harga}'),
                        Text('Restoran: ${product.namaRestoran}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Konfirmasi sebelum menghapus
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Bookmark'),
                            content: const Text(
                                'Are you sure you want to remove this bookmark?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await deleteBookmark(
                              product.id); // Panggil metode delete
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class BookmarkedProduct {
  final int id;
  final String nama;
  final String kategori;
  final String harga;
  final String namaRestoran;
  final String lokasi;
  final String urlGambar;

  BookmarkedProduct({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.namaRestoran,
    required this.lokasi,
    required this.urlGambar,
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
      );
}
