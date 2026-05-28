enum ReportCategory { phone, redLight, speeding }

extension ReportCategoryLabel on ReportCategory {
  String get label {
    return switch (this) {
      ReportCategory.phone => 'Celular ao volante',
      ReportCategory.redLight => 'Avanço de sinal',
      ReportCategory.speeding => 'Excesso de velocidade',
    };
  }
}

class ReportRecord {
  final String id;
  final ReportCategory category;
  final String location;
  final String details;
  final bool hasPhoto;
  final DateTime createdAt;

  const ReportRecord({
    required this.id,
    required this.category,
    required this.location,
    required this.details,
    required this.hasPhoto,
    required this.createdAt,
  });

  String get protocol => id.toUpperCase();

  String get detranSummary {
    final evidence = hasPhoto ? 'com evidência visual' : 'sem foto anexada';
    final note = details.trim().isEmpty
        ? 'Sem detalhes adicionais.'
        : details.trim();

    return 'Protocolo $protocol\n'
        'Categoria: ${category.label}\n'
        'Localização: $location\n'
        'Evidência: $evidence\n'
        'Descrição: $note';
  }
}
