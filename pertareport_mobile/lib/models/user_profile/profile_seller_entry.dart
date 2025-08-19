// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ProfileSellerEntry welcomeSellerFromJson(String str) => ProfileSellerEntry.fromJson(json.decode(str));

String welcomeSellerToJson(ProfileSellerEntry data) => json.encode(data.toJson());

class ProfileSellerEntry {
    String profileType;
    ProfileSeller profile;

    ProfileSellerEntry({
        required this.profileType,
        required this.profile,
    });

    factory ProfileSellerEntry.fromJson(Map<String, dynamic> json) => ProfileSellerEntry(
        profileType: json["profile_type"],
        profile: ProfileSeller.fromJson(json["profile"]),
    );

    Map<String, dynamic> toJson() => {
        "profile_type": profileType,
        "profile": profile.toJson(),
    };
}

class ProfileSeller {
    String storeName;
    String userName;
    String city;
    String subdistrict;
    String village;
    String address;
    String maps;
    String profilePicture;

    ProfileSeller({
        required this.storeName,
        required this.userName,
        required this.city,
        required this.subdistrict,
        required this.village,
        required this.address,
        required this.maps,
        required this.profilePicture,
    });

    factory ProfileSeller.fromJson(Map<String, dynamic> json) => ProfileSeller(
        storeName: json["store_name"],
        userName: json["username"],
        city: json["city"],
        subdistrict: json["subdistrict"],
        village: json["village"],
        address: json["address"],
        maps: json["maps"],
        profilePicture: json["profile_picture"],
    );

    Map<String, dynamic> toJson() => {
        "store_name": storeName,
        "username": userName,
        "city": city,
        "subdistrict": subdistrict,
        "village": village,
        "address": address,
        "maps": maps,
        "profile_picture": profilePicture,
    };
}
