// To parse this JSON data, do
//
//     final ReviewResponse = ReviewResponseFromJson(jsonString);

import 'dart:convert';

ReviewResponse ReviewResponseFromJson(String str) =>
    ReviewResponse.fromJson(json.decode(str));

String ReviewResponseToJson(ReviewResponse data) => json.encode(data.toJson());

class ReviewResponse {
  String status;
  int productId;
  List<Review> reviews;

  ReviewResponse({
    required this.status,
    required this.productId,
    required this.reviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
        status: json["status"],
        productId: json["product_id"],
        reviews:
            List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "product_id": productId,
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
      };
}

class Review {
  int id;
  String username;
  String reviewText;
  DateTime time;

  Review({
    required this.id,
    required this.username,
    required this.reviewText,
    required this.time,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        username: json["username"],
        reviewText: json["review_text"],
        time: DateTime.parse(json["time"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "review_text": reviewText,
        "time": time.toIso8601String(),
      };
}
