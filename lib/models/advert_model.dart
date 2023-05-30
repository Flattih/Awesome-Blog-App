class Advert {
  final String baslik;
  final String icerik;
  final String resim;
  Advert({
    required this.baslik,
    required this.icerik,
    required this.resim,
  });

  Advert copyWith({
    String? baslik,
    String? icerik,
    String? resim,
  }) {
    return Advert(
      baslik: baslik ?? this.baslik,
      icerik: icerik ?? this.icerik,
      resim: resim ?? this.resim,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'baslik': baslik});
    result.addAll({'icerik': icerik});
    result.addAll({'resim': resim});

    return result;
  }

  factory Advert.fromMap(Map<String, dynamic> map) {
    return Advert(
      baslik: map['baslik'] ?? '',
      icerik: map['icerik'] ?? '',
      resim: map['resim'] ?? '',
    );
  }

  @override
  String toString() =>
      'Advert(baslik: $baslik, icerik: $icerik, resim: $resim)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Advert &&
        other.baslik == baslik &&
        other.icerik == icerik &&
        other.resim == resim;
  }

  @override
  int get hashCode => baslik.hashCode ^ icerik.hashCode ^ resim.hashCode;
}
