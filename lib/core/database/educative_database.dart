class EducativeContent {
  final String id;
  final String title;
  final String description;
  final String category; // 'acidentes', 'dicas', 'legislacao'
  final String emoji;
  final DateTime date;

  EducativeContent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.emoji,
    required this.date,
  });
}

class EducativeDatabase {
  static final List<EducativeContent> allContent = [
    EducativeContent(
      id: 'edu001',
      title: 'Acidentes no Brasil em 2024',
      description:
          '📊 Segundo dados do DETRAN, mais de 1.3 milhão de acidentes foram registrados em 2024. A velocidade excessiva foi a principal causa. Use cinto de segurança sempre!',
      category: 'acidentes',
      emoji: '⚠️',
      date: DateTime(2024, 5, 25),
    ),
    EducativeContent(
      id: 'edu002',
      title: 'Dica de Segurança: Distância Seguindo Outro Veículo',
      description:
          '🚗 Mantenha uma distância de 2 segundos do veículo à sua frente. Em chuva ou má visibilidade, aumente para 4-5 segundos. Isso pode ser a diferença entre vida e morte em uma colisão.',
      category: 'dicas',
      emoji: '✅',
      date: DateTime(2024, 5, 24),
    ),
    EducativeContent(
      id: 'edu003',
      title: 'Lei do Cinto de Segurança',
      description:
          '🛡️ Usar cinto de segurança é obrigatório em TODAS as posições do veículo. Multa de R\$ 195,23 e 5 pontos por não usar. O cinto reduz risco de morte em 50%!',
      category: 'legislacao',
      emoji: '⚖️',
      date: DateTime(2024, 5, 23),
    ),
    EducativeContent(
      id: 'edu004',
      title: 'Análise: Por que Dirigir Cansado é Perigoso?',
      description:
          '😴 Dirigi cansado reduz tempo de reação em 30%. A cada 2 horas dirigindo, faça uma pausa de 15 minutos. Piores horários: 2-4h e 14-16h. Durma bem antes de viajar!',
      category: 'acidentes',
      emoji: '😴',
      date: DateTime(2024, 5, 22),
    ),
    EducativeContent(
      id: 'edu005',
      title:
          'Celular ao Volante - 3 segundos de distração equivalem a um campo de futebol!',
      description:
          '📱 A 100 km/h, 3 segundos de distração significam percorrer 83 metros sem controle. Você pode causar um acidente grave. Deixe o celular guardado!',
      category: 'dicas',
      emoji: '📵',
      date: DateTime(2024, 5, 21),
    ),
    EducativeContent(
      id: 'edu006',
      title: 'Multas Infração Gravíssima 2024',
      description:
          '💰 Celular: R\$ 293,47 | Avanço de sinal: R\$ 293,47 | Falta de cinto: R\$ 195,23 | Excesso velocidade 30+km/h: R\$ 880,41. Todas com pontos na carteira!',
      category: 'legislacao',
      emoji: '⚖️',
      date: DateTime(2024, 5, 20),
    ),
    EducativeContent(
      id: 'edu007',
      title: 'Segurança em Chuva: Dicas Práticas',
      description:
          '🌧️ Reduza velocidade em 40%, aumente distância de segurança, use farol baixo, evite buzinas. Chuva reduz aderência em 50%. Pneus com menos de 1,6mm de profundidade são perigosos!',
      category: 'dicas',
      emoji: '☔',
      date: DateTime(2024, 5, 19),
    ),
    EducativeContent(
      id: 'edu008',
      title: 'Maio Amarelo: Resgatar Vidas é um Compromisso de TODOS',
      description:
          '⚠️ A campanha Maio Amarelo busca conscientizar sobre a segurança no trânsito. 95% dos acidentes são causados por erros humanos. No trânsito, escolha a vida!',
      category: 'legislacao',
      emoji: '💛',
      date: DateTime(2024, 5, 18),
    ),
    EducativeContent(
      id: 'edu009',
      title: 'Manutenção Preventiva Salva Vidas',
      description:
          '🔧 Verifique: pressão dos pneus (mensalmente), freios, óleo, sistema de iluminação. Um pneu furado em alta velocidade pode causar capotagem. Manutenção em dia = segurança garantida!',
      category: 'dicas',
      emoji: '✅',
      date: DateTime(2024, 5, 17),
    ),
    EducativeContent(
      id: 'edu010',
      title: 'Faixa Contínua vs Tracejada',
      description:
          '🛣️ Faixa BRANCA CONTÍNUA = Proibido ultrapassar | Faixa BRANCA TRACEJADA = Permitido ultrapassar. Desrespeitar pode resultar em multa de R\$ 88,38 e 4 pontos!',
      category: 'legislacao',
      emoji: '🚦',
      date: DateTime(2024, 5, 16),
    ),
  ];

  static List<EducativeContent> getRecent({int count = 5}) {
    final sorted = List<EducativeContent>.from(allContent)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  static List<EducativeContent> getByCategory(String category) {
    return allContent.where((c) => c.category == category).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
