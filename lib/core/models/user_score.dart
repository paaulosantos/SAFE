class UserScore {
  final String userId;
  final int totalPoints;
  final int streak; // dias consecutivos respondendo quiz
  final int maxStreak;
  final int quizzesCompleted;
  final int correctAnswers;
  final DateTime lastQuizDate;
  final Map<String, int> badges; // 'perfeito', 'semana', 'mês', etc

  UserScore({
    required this.userId,
    this.totalPoints = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.quizzesCompleted = 0,
    this.correctAnswers = 0,
    required this.lastQuizDate,
    this.badges = const {},
  });

  int get safetyScore {
    // Índice de segurança de 0 a 100
    if (quizzesCompleted == 0) return 50; // Inicial
    final percentage = (correctAnswers / (quizzesCompleted * 5)) * 100;
    return (percentage * 0.7 + (streak / 30) * 30).toInt().clamp(0, 100);
  }

  String get safetyLevel {
    if (safetyScore >= 90) return 'Excelente 🏆';
    if (safetyScore >= 75) return 'Muito Bom ⭐';
    if (safetyScore >= 60) return 'Bom ✓';
    if (safetyScore >= 45) return 'Regular';
    return 'Precisa Melhorar ⚠️';
  }

  bool get isStreakActive {
    final now = DateTime.now();
    final diff = now.difference(lastQuizDate).inDays;
    return diff <= 1; // Streak ativo se respondeu ontem ou hoje
  }

  factory UserScore.fromMap(Map<String, dynamic> map) {
    return UserScore(
      userId: map['userId'] as String,
      totalPoints: map['totalPoints'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
      maxStreak: map['maxStreak'] as int? ?? 0,
      quizzesCompleted: map['quizzesCompleted'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      lastQuizDate: map['lastQuizDate'] != null
          ? DateTime.parse(map['lastQuizDate'] as String)
          : DateTime.now(),
      badges: Map<String, int>.from(map['badges'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'streak': streak,
      'maxStreak': maxStreak,
      'quizzesCompleted': quizzesCompleted,
      'correctAnswers': correctAnswers,
      'lastQuizDate': lastQuizDate.toIso8601String(),
      'badges': badges,
    };
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String condition; // 'perfeito_quiz', 'semana_completa', etc
  final int requirement;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.condition,
    required this.requirement,
  });
}

class Badges {
  static const List<Badge> allBadges = [
    Badge(
      id: 'perfeito',
      name: 'Quiz Perfeito',
      description: 'Responda 5 questões seguidas corretamente',
      emoji: '🎯',
      condition: 'perfeito_quiz',
      requirement: 1,
    ),
    Badge(
      id: 'semana',
      name: 'Semana de Segurança',
      description: 'Responda quizzes por 7 dias consecutivos',
      emoji: '🔥',
      condition: 'semana_completa',
      requirement: 7,
    ),
    Badge(
      id: 'mes',
      name: 'Mês do Motorista',
      description: 'Mantenha 30 dias de streak',
      emoji: '🏆',
      condition: 'mes_completo',
      requirement: 30,
    ),
    Badge(
      id: 'maio_amarelo',
      name: 'Defensor do Maio Amarelo',
      description: 'Complete 10 quizzes em maio',
      emoji: '⚠️',
      condition: 'maio_amarelo',
      requirement: 10,
    ),
    Badge(
      id: 'expert_ctb',
      name: 'Especialista em CTB',
      description: 'Acerte 50 questões sobre Código de Trânsito',
      emoji: '📚',
      condition: 'expert_ctb',
      requirement: 50,
    ),
    Badge(
      id: 'sinais_master',
      name: 'Mestre dos Sinais',
      description: 'Acerte 40 questões sobre sinais de trânsito',
      emoji: '🚦',
      condition: 'sinais_master',
      requirement: 40,
    ),
    Badge(
      id: 'praticas_seguras',
      name: 'Práticas Seguras',
      description: 'Acerte 40 questões sobre boas práticas',
      emoji: '✅',
      condition: 'praticas_seguras',
      requirement: 40,
    ),
  ];
}

class Leaderboard {
  final String userId;
  final String userName;
  final int rank;
  final int points;
  final int streak;
  final String safetyLevel;

  const Leaderboard({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.points,
    required this.streak,
    required this.safetyLevel,
  });
}
