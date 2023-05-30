class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String blogId;
  final String username;
  final String profilePic;
  final String uid;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.blogId,
    required this.username,
    required this.profilePic,
    required this.uid,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? blogId,
    String? username,
    String? profilePic,
    String? uid,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      blogId: blogId ?? this.blogId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'text': text});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'blogId': blogId});
    result.addAll({'username': username});
    result.addAll({'profilePic': profilePic});
    result.addAll({'uid': uid});

    return result;
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      blogId: map['blogId'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
      uid: map['uid'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, blogId: $blogId, username: $username, profilePic: $profilePic, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.blogId == blogId &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        blogId.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        uid.hashCode;
  }
}
