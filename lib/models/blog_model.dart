import 'package:flutter/foundation.dart';

class Blog {
  final String id;
  final String title;
  final String description;
  final String uid;
  final String imageUrl;
  final String profilePictureUrl;
  final String profileScreenImg;
  final String username;
  final String topic;
  final String token;
  final List<String> likes;
  final int commentCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isApproved;
  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.uid,
    required this.imageUrl,
    required this.profilePictureUrl,
    required this.profileScreenImg,
    required this.username,
    required this.topic,
    required this.token,
    required this.likes,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.isApproved,
  });

  Blog copyWith({
    String? id,
    String? title,
    String? description,
    String? uid,
    String? imageUrl,
    String? profilePictureUrl,
    String? profileScreenImg,
    String? username,
    String? topic,
    String? token,
    List<String>? likes,
    int? commentCount,
    int? likeCount,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      uid: uid ?? this.uid,
      imageUrl: imageUrl ?? this.imageUrl,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileScreenImg: profileScreenImg ?? this.profileScreenImg,
      username: username ?? this.username,
      topic: topic ?? this.topic,
      token: token ?? this.token,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'uid': uid});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'profilePictureUrl': profilePictureUrl});
    result.addAll({'profileScreenImg': profileScreenImg});
    result.addAll({'username': username});
    result.addAll({'topic': topic});
    result.addAll({'token': token});
    result.addAll({'likes': likes});
    result.addAll({'commentCount': commentCount});
    result.addAll({'likeCount': likeCount});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'isApproved': isApproved});

    return result;
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      uid: map['uid'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      profileScreenImg: map['profileScreenImg'] ?? '',
      username: map['username'] ?? '',
      topic: map['topic'] ?? '',
      token: map['token'] ?? '',
      likes: List<String>.from(map['likes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      likeCount: map['likeCount']?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isApproved: map['isApproved'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Blog(id: $id, title: $title, description: $description, uid: $uid, imageUrl: $imageUrl, profilePictureUrl: $profilePictureUrl, profileScreenImg: $profileScreenImg, username: $username, topic: $topic, token: $token, likes: $likes, commentCount: $commentCount, likeCount: $likeCount, createdAt: $createdAt, isApproved: $isApproved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Blog &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.uid == uid &&
        other.imageUrl == imageUrl &&
        other.profilePictureUrl == profilePictureUrl &&
        other.profileScreenImg == profileScreenImg &&
        other.username == username &&
        other.topic == topic &&
        other.token == token &&
        listEquals(other.likes, likes) &&
        other.commentCount == commentCount &&
        other.likeCount == likeCount &&
        other.createdAt == createdAt &&
        other.isApproved == isApproved;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        uid.hashCode ^
        imageUrl.hashCode ^
        profilePictureUrl.hashCode ^
        profileScreenImg.hashCode ^
        username.hashCode ^
        topic.hashCode ^
        token.hashCode ^
        likes.hashCode ^
        commentCount.hashCode ^
        likeCount.hashCode ^
        createdAt.hashCode ^
        isApproved.hashCode;
  }
}
