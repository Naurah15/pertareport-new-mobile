class Chat {
  // String model;
  String pk;
  Fields fields;

  Chat({
    // required this.model,
    required this.pk,
    required this.fields,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      // model: json['model'],
      pk: json['pk'],
      fields: Fields.fromJson(json['fields']),
    );
  }
}

class Fields {
  DateTime createdAt;
  List<int> users;

  Fields({
    required this.createdAt,
    required this.users,
  });

  factory Fields.fromJson(Map<String, dynamic> json) {
    return Fields(
      createdAt: DateTime.parse(json['created_at']),
      users: List<int>.from(json['users']),
    );
  }
}
