class TopicModel {
  final String title;
  final String desc;
  final String imgUrl;
  TopicModel({
    required this.title,
    required this.desc,
    required this.imgUrl,
  });

  TopicModel copyWith({
    String? title,
    String? desc,
    String? imgUrl,
  }) {
    return TopicModel(
      title: title ?? this.title,
      desc: desc ?? this.desc,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'desc': desc});
    result.addAll({'imgUrl': imgUrl});

    return result;
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      imgUrl: map['imgUrl'] ?? '',
    );
  }

  @override
  String toString() =>
      'TopicModel(title: $title, desc: $desc, imgUrl: $imgUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TopicModel &&
        other.title == title &&
        other.desc == desc &&
        other.imgUrl == imgUrl;
  }

  @override
  int get hashCode => title.hashCode ^ desc.hashCode ^ imgUrl.hashCode;
}
