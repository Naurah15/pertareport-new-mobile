import 'dart:convert';

List<Message> messageFromJson(String str) =>
    List<Message>.from(json.decode(str).map((x) => Message.fromJson(x)));

String messageToJson(List<Message> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Message {
  // String model;
  String pk;
  Fields fields;

  Message({
    // required this.model,
    required this.pk,
    required this.fields,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        // model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        // "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String chat;
  String sender;
  String content;
  DateTime timestamp;

  Fields({
    required this.chat,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        chat: json["chat"],
        sender: json["sender"],
        content: json["content"],
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "chat": chat,
        "sender": sender,
        "content": content,
        "timestamp": timestamp.toIso8601String(),
      };
}
