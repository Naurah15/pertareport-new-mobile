import 'dart:convert';

UserProfileResponse userProfileResponseFromJson(String str) =>
    UserProfileResponse.fromJson(json.decode(str));

String userProfileResponseToJson(UserProfileResponse data) =>
    json.encode(data.toJson());

class UserProfileResponse {
  bool success;
  UserProfile profile;

  UserProfileResponse({
    required this.success,
    required this.profile,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        success: json["success"],
        profile: UserProfile.fromJson(json["profile"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "profile": profile.toJson(),
      };
}

class UserProfile {
  int id;
  String username;
  String email;
  String phoneNumber;
  String dateJoined;
  String? lastLogin;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.dateJoined,
    this.lastLogin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        phoneNumber: json["phone_number"] ?? "",
        dateJoined: json["date_joined"],
        lastLogin: json["last_login"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "phone_number": phoneNumber,
        "date_joined": dateJoined,
        "last_login": lastLogin,
      };
}
