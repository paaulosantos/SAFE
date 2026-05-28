import 'package:flutter/foundation.dart';
import 'package:safe/core/database/quiz_database.dart';
import 'package:safe/core/models/quiz.dart';
import 'package:safe/core/models/report_record.dart';
import 'package:safe/core/models/traffic_point.dart';
import 'package:safe/core/models/user_score.dart';
import 'package:safe/shared/services/current_user_profile.dart';

class SafeAppStore extends ChangeNotifier {
  SafeAppStore._();

  static final SafeAppStore instance = SafeAppStore._();

  final List<TrafficPoint> _trafficPoints = [
    TrafficPoint(
      id: 'p001',
      category: TrafficPointCategory.construction,
      title: 'Obras na pista',
      address: 'Av. Beira Mar - Aracaju',
      description:
          'Faixa parcialmente interditada e tráfego lento no sentido centro.',
      x: 0.42,
      y: 0.38,
      latitude: -10.95410,
      longitude: -37.05520,
      confirmations: 18,
      dismissals: 1,
      createdAt: DateTime(2026, 5, 26, 8, 30),
    ),
    TrafficPoint(
      id: 'p002',
      category: TrafficPointCategory.pothole,
      title: 'Buraco no cruzamento',
      address: 'Av. Hermes Fontes - Aracaju',
      description: 'Buraco profundo próximo à faixa de pedestres.',
      x: 0.68,
      y: 0.28,
      latitude: -10.93280,
      longitude: -37.06740,
      confirmations: 11,
      dismissals: 0,
      createdAt: DateTime(2026, 5, 26, 18, 10),
    ),
    TrafficPoint(
      id: 'p003',
      category: TrafficPointCategory.signal,
      title: 'Semáforo intermitente',
      address: 'Av. Tancredo Neves - Aracaju',
      description:
          'Semáforo alternando para amarelo piscante no horário de pico.',
      x: 0.56,
      y: 0.58,
      latitude: -10.92660,
      longitude: -37.07930,
      confirmations: 9,
      dismissals: 2,
      createdAt: DateTime(2026, 5, 27, 7, 45),
    ),
    TrafficPoint(
      id: 'p004',
      category: TrafficPointCategory.accident,
      title: 'Ponto com colisões recorrentes',
      address: 'Rotatória do DIA - Aracaju',
      description:
          'Trecho com conversões rápidas e baixa visibilidade lateral.',
      x: 0.26,
      y: 0.62,
      latitude: -10.91880,
      longitude: -37.07580,
      confirmations: 24,
      dismissals: 0,
      createdAt: DateTime(2026, 5, 25, 17, 20),
    ),
  ];

  final List<ReportRecord> _reports = [];

  UserScore _userScore = UserScore(
    userId: 'local-user',
    lastQuizDate: DateTime.now().subtract(const Duration(days: 1)),
  );

  String? _latestTrafficPointId;

  List<TrafficPoint> get trafficPoints => List.unmodifiable(_trafficPoints);
  List<ReportRecord> get reports => List.unmodifiable(_reports.reversed);
  UserScore get userScore => _userScore;
  String? get latestTrafficPointId => _latestTrafficPointId;

  int get reportCount => _reports.length;
  int get trafficPointCount => _trafficPoints.length;
  int get reportsThisMonth => _reports
      .where((report) => _isSameMonth(report.createdAt, DateTime.now()))
      .length;
  int get trafficPointsThisMonth => _trafficPoints
      .where((point) => _isSameMonth(point.createdAt, DateTime.now()))
      .length;

  QuizQuestion get dailyChallenge {
    final questions = QuizDatabase.allQuestions;
    return questions[DateTime.now().day % questions.length];
  }

  String get weeklyChallengeTitle {
    final week = DateTime.now().day ~/ 7;
    const challenges = [
      'Complete 5 quizzes sem perder o streak',
      'Valide 3 pontos perigosos no mapa',
      'Leia 3 cards do feed educativo',
      'Compartilhe um relatorio preventivo',
    ];

    return challenges[week % challenges.length];
  }

  String get weeklyChallengeProgressLabel {
    final progress = (userScore.quizzesCompleted % 5).clamp(0, 5);
    return '$progress/5 etapas';
  }

  String get campaignCountdownLabel {
    final today = DateTime.now();

    if (today.month == 5) {
      return 'Maio Amarelo ativo';
    }

    if (today.month < 5) {
      final mayFirst = DateTime(today.year, 5);
      final days = mayFirst
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      return 'Faltam $days dias para maio';
    }

    return 'Campanha ativa o ano todo';
  }

  List<TrafficPoint> trafficPointsByCategory(TrafficPointCategory? category) {
    final points = category == null
        ? _trafficPoints
        : _trafficPoints.where((point) => point.category == category);

    return points.toList()
      ..sort((a, b) => b.confirmations.compareTo(a.confirmations));
  }

  TrafficPoint? trafficPointById(String id) {
    for (final point in _trafficPoints) {
      if (point.id == id) return point;
    }

    return null;
  }

  TrafficPoint addTrafficPoint({
    required TrafficPointCategory category,
    required String title,
    required String address,
    required String description,
    required double x,
    required double y,
    double? latitude,
    double? longitude,
  }) {
    final point = TrafficPoint(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      title: title.trim().isEmpty ? category.label : title.trim(),
      address: address.trim().isEmpty
          ? 'Localização atual aproximada'
          : address.trim(),
      description: description.trim().isEmpty
          ? 'Ponto colaborativo registrado por usuário próximo.'
          : description.trim(),
      x: x,
      y: y,
      latitude: latitude,
      longitude: longitude,
      confirmations: 1,
      dismissals: 0,
      createdAt: DateTime.now(),
    );

    _trafficPoints.add(point);
    _latestTrafficPointId = point.id;
    notifyListeners();
    return point;
  }

  void confirmTrafficPoint(String id) {
    final index = _trafficPoints.indexWhere((point) => point.id == id);
    if (index == -1) return;

    _trafficPoints[index] = _trafficPoints[index].copyWith(
      confirmations: _trafficPoints[index].confirmations + 1,
    );
    notifyListeners();
  }

  void discardTrafficPoint(String id) {
    final index = _trafficPoints.indexWhere((point) => point.id == id);
    if (index == -1) return;

    final updated = _trafficPoints[index].copyWith(
      dismissals: _trafficPoints[index].dismissals + 1,
    );

    if (updated.dismissals >= 3) {
      _trafficPoints.removeAt(index);
    } else {
      _trafficPoints[index] = updated;
    }

    notifyListeners();
  }

  ReportRecord submitReport({
    required ReportCategory category,
    required String location,
    required String details,
    required bool hasPhoto,
    required double x,
    required double y,
    required double latitude,
    required double longitude,
  }) {
    final report = ReportRecord(
      id: 'safe-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}',
      category: category,
      location: location,
      details: details,
      hasPhoto: hasPhoto,
      createdAt: DateTime.now(),
    );

    _reports.add(report);
    final point = TrafficPoint(
      id: 'report-${report.id}',
      category: _trafficCategoryFromReport(category),
      title: category.label,
      address: location,
      description: details.trim().isEmpty
          ? 'Denúncia anônima registrada pelo SAFE.'
          : details.trim(),
      x: x,
      y: y,
      latitude: latitude,
      longitude: longitude,
      confirmations: 1,
      dismissals: 0,
      createdAt: report.createdAt,
    );

    _trafficPoints.add(point);
    _latestTrafficPointId = point.id;
    notifyListeners();
    return report;
  }

  TrafficPointCategory _trafficCategoryFromReport(ReportCategory category) {
    return switch (category) {
      ReportCategory.phone => TrafficPointCategory.phone,
      ReportCategory.redLight => TrafficPointCategory.redLight,
      ReportCategory.speeding => TrafficPointCategory.speeding,
    };
  }

  void completeQuiz({
    required int earnedPoints,
    required int correctAnswers,
    required int totalQuestions,
    required bool perfect,
  }) {
    final today = _dateOnly(DateTime.now());
    final lastQuizDay = _dateOnly(_userScore.lastQuizDate);
    final daysSinceLastQuiz = today.difference(lastQuizDay).inDays;
    final newStreak = switch ((
      _userScore.quizzesCompleted,
      daysSinceLastQuiz,
    )) {
      (0, _) => 1,
      (_, 0) => _userScore.streak,
      (_, 1) => _userScore.streak + 1,
      _ => 1,
    };
    final badges = Map<String, int>.from(_userScore.badges);
    final quizzesCompleted = _userScore.quizzesCompleted + 1;

    if (perfect) badges['perfeito'] = 1;
    if (newStreak >= 7) badges['semana'] = 1;
    if (newStreak >= 30) badges['mes'] = 1;
    if (DateTime.now().month == 5 && quizzesCompleted >= 10) {
      badges['maio_amarelo'] = 1;
    }

    _userScore = UserScore(
      userId: _userScore.userId,
      totalPoints: _userScore.totalPoints + earnedPoints,
      streak: newStreak,
      maxStreak: newStreak > _userScore.maxStreak
          ? newStreak
          : _userScore.maxStreak,
      quizzesCompleted: quizzesCompleted,
      correctAnswers: _userScore.correctAnswers + correctAnswers,
      lastQuizDate: today,
      badges: badges,
    );

    notifyListeners();
  }

  List<Leaderboard> getLeaderboard({int limit = 5}) {
    final entries = [
      Leaderboard(
        userId: CurrentUserProfile.id,
        userName: CurrentUserProfile.name,
        rank: 0,
        points: _userScore.totalPoints,
        streak: _userScore.streak,
        safetyLevel: _userScore.safetyLevel,
      ),
      const Leaderboard(
        userId: 'ana',
        userName: 'Ana',
        rank: 0,
        points: 680,
        streak: 11,
        safetyLevel: 'Excelente',
      ),
      const Leaderboard(
        userId: 'marcos',
        userName: 'Marcos',
        rank: 0,
        points: 590,
        streak: 7,
        safetyLevel: 'Muito Bom',
      ),
      const Leaderboard(
        userId: 'julia',
        userName: 'Júlia',
        rank: 0,
        points: 470,
        streak: 4,
        safetyLevel: 'Bom',
      ),
    ]..sort((a, b) => b.points.compareTo(a.points));

    return entries
        .asMap()
        .entries
        .map(
          (entry) => Leaderboard(
            userId: entry.value.userId,
            userName: entry.value.userName,
            rank: entry.key + 1,
            points: entry.value.points,
            streak: entry.value.streak,
            safetyLevel: entry.value.safetyLevel,
          ),
        )
        .take(limit)
        .toList();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameMonth(DateTime date, DateTime reference) {
    return date.year == reference.year && date.month == reference.month;
  }
}
