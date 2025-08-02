import 'package:flutter/material.dart';

class TopPlacesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Places',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B4636),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Berikut adalah rekomendasi tempat dan makanan dari kami',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5B4636),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildRestaurantCard(
                imageUrl: 'images/vegan.jpg',
                name: 'Vegan Cafe Black Forest',
                rating: '⭐ 4.8/5',
                location:
                    'Jalan Parangtritis No. 87, Yogyakarta, Java, Indonesia, 55153',
              ),
              _buildRestaurantCard(
                imageUrl: 'images/am-co-jogja.jpg',
                name: 'A&M Co. Yogyakarta',
                rating: '⭐ 4.5/5',
                location:
                    'Jl. Parangtritis No.139, Brontokusuman, Kec. Mergangsan Kota Yogyakarta',
              ),
              _buildRestaurantCard(
                imageUrl: 'images/tempo-gelato.jpg',
                name: 'Tempo Gelato',
                rating: '⭐ 4.5/5',
                location:
                    'Jl. Tamansiswa 56, Wirogunan, Mergangsan 55151 Yogyakarta',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard({
    required String imageUrl,
    required String name,
    required String rating,
    required String location,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B4636),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B4636),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5B4636),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
