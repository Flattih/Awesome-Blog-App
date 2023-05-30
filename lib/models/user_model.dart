import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String uid;
  final String? fcmToken;
  final List<String> followers;
  final List<String> following;
  final bool isAdmin;
  final String bio;
  UserModel({
    required this.name,
    required this.profilePic,
    required this.uid,
    this.fcmToken,
    required this.followers,
    required this.following,
    required this.isAdmin,
    required this.bio,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? uid,
    String? fcmToken,
    List<String>? followers,
    List<String>? following,
    bool? isAdmin,
    String? bio,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      fcmToken: fcmToken ?? this.fcmToken,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isAdmin: isAdmin ?? this.isAdmin,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'profilePic': profilePic});
    result.addAll({'uid': uid});
    if (fcmToken != null) {
      result.addAll({'fcmToken': fcmToken});
    }
    result.addAll({'followers': followers});
    result.addAll({'following': following});
    result.addAll({'isAdmin': isAdmin});
    result.addAll({'bio': bio});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      uid: map['uid'] ?? '',
      fcmToken: map['fcmToken'],
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      isAdmin: map['isAdmin'] ?? false,
      bio: map['bio'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, uid: $uid, fcmToken: $fcmToken, followers: $followers, following: $following, isAdmin: $isAdmin, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.uid == uid &&
        other.fcmToken == fcmToken &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        other.isAdmin == isAdmin &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        uid.hashCode ^
        fcmToken.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        isAdmin.hashCode ^
        bio.hashCode;
  }
}
