enum TrafficPointCategory {
  accident,
  pothole,
  signal,
  construction,
  phone,
  redLight,
  speeding,
}

extension TrafficPointCategoryLabel on TrafficPointCategory {
  String get label {
    return switch (this) {
      TrafficPointCategory.accident => 'Histórico de acidentes',
      TrafficPointCategory.pothole => 'Buraco na via',
      TrafficPointCategory.signal => 'Semáforo quebrado',
      TrafficPointCategory.construction => 'Obra na pista',
      TrafficPointCategory.phone => 'Celular ao volante',
      TrafficPointCategory.redLight => 'Avanço de sinal',
      TrafficPointCategory.speeding => 'Excesso de velocidade',
    };
  }

  String get shortLabel {
    return switch (this) {
      TrafficPointCategory.accident => 'Acidentes',
      TrafficPointCategory.pothole => 'Buracos',
      TrafficPointCategory.signal => 'Semáforos',
      TrafficPointCategory.construction => 'Obras',
      TrafficPointCategory.phone => 'Celular',
      TrafficPointCategory.redLight => 'Avanço',
      TrafficPointCategory.speeding => 'Velocidade',
    };
  }

  bool get isReport {
    return switch (this) {
      TrafficPointCategory.phone ||
      TrafficPointCategory.redLight ||
      TrafficPointCategory.speeding => true,
      _ => false,
    };
  }
}

class TrafficPoint {
  final String id;
  final TrafficPointCategory category;
  final String title;
  final String address;
  final String description;
  final double x;
  final double y;
  final double? latitude;
  final double? longitude;
  final int confirmations;
  final int dismissals;
  final DateTime createdAt;

  const TrafficPoint({
    required this.id,
    required this.category,
    required this.title,
    required this.address,
    required this.description,
    required this.x,
    required this.y,
    this.latitude,
    this.longitude,
    required this.confirmations,
    required this.dismissals,
    required this.createdAt,
  });

  TrafficPoint copyWith({
    TrafficPointCategory? category,
    String? title,
    String? address,
    String? description,
    double? x,
    double? y,
    double? latitude,
    double? longitude,
    int? confirmations,
    int? dismissals,
    DateTime? createdAt,
  }) {
    return TrafficPoint(
      id: id,
      category: category ?? this.category,
      title: title ?? this.title,
      address: address ?? this.address,
      description: description ?? this.description,
      x: x ?? this.x,
      y: y ?? this.y,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      confirmations: confirmations ?? this.confirmations,
      dismissals: dismissals ?? this.dismissals,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
