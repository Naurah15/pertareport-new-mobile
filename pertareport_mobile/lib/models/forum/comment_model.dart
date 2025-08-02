// To parse this JSON data, do
//
//     final commentEntry = commentEntryFromJson(jsonString);

import 'dart:convert';

CommentEntry commentEntryFromJson(String str) =>
    CommentEntry.fromJson(json.decode(str));

String commentEntryToJson(CommentEntry data) => json.encode(data.toJson());

class CommentEntry {
  List<Comment> comment;

  CommentEntry({
    required this.comment,
  });

  factory CommentEntry.fromJson(Map<String, dynamic> json) => CommentEntry(
        comment:
            List<Comment>.from(json["comment"].map((x) => Comment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "comment": List<dynamic>.from(comment.map((x) => x.toJson())),
      };
}

class Comment {
  String user;
  String content;
  DateTime createdAt;
  String forumEntry;

  Comment({
    required this.user,
    required this.content,
    required this.createdAt,
    required this.forumEntry,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        user: json["user"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        forumEntry: json["forum_entry"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "forum_entry": forumEntry,
      };
}
