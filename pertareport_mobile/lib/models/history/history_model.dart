// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

List<ForumEntry> forumEntryFromJson(String str) =>
    List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  String pk;
  Fields fields;

  ForumEntry({
    required this.pk,
    required this.fields,
  });

  factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int user;
  String title;
  String description;
  int commentsCount;
  bool isAuthor;

  Fields({
    required this.user,
    required this.title,
    required this.description,
    required this.commentsCount,
    required this.isAuthor,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        title: json["title"],
        description: json["description"],
        commentsCount: json["comments_count"],
        isAuthor: json["is_author"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "title": title,
        "description": description,
        "comments_count": commentsCount,
        "is_author": isAuthor,
      };
}
