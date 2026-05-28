import 'package:uuid/uuid.dart';
import 'package:safe/core/database/quiz_database.dart';
import 'package:safe/core/models/quiz.dart';
import 'package:safe/core/models/user_score.dart';

class QuizService {
  // Simular banco de dados local (depois integrar com Firebase)
  final Map<String, UserScore> _userScores = {};
  final Map<String, QuizSession> _quizSessions = {};

  // Iniciar uma nova sessão de quiz
  QuizSession startNewQuizSession(String userId, {String? category}) {
    final session = QuizSession(
      id: const Uuid().v4(),
      userId: userId,
      answers: [],
      startedAt: DateTime.now(),
    );

    _quizSessions[session.id] = session;
    return session;
  }

  // Responder uma pergunta
  void answerQuestion(
    String sessionId,
    String questionId,
    int selectedAnswerIndex,
  ) {
    final session = _quizSessions[sessionId];
    if (session == null) return;

    QuizQuestion? question;
    for (final item in QuizDatabase.allQuestions) {
      if (item.id == questionId) {
        question = item;
        break;
      }
    }

    if (question == null) return;

    final isCorrect = question.correctAnswerIndex == selectedAnswerIndex;

    final answer = QuizAnswer(
      questionId: questionId,
      selectedAnswerIndex: selectedAnswerIndex,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );

    _quizSessions[sessionId]!.answers.add(answer);
  }

  // Finalizar sessão de quiz
  QuizSession? finishQuizSession(String sessionId, String userId) {
    final session = _quizSessions[sessionId];
    if (session == null) return null;

    final finishedSession = QuizSession(
      id: session.id,
      userId: userId,
      answers: session.answers,
      startedAt: session.startedAt,
      finishedAt: DateTime.now(),
      totalPoints: _calculatePoints(session),
    );

    _quizSessions[sessionId] = finishedSession;

    // Atualizar score do usuário
    _updateUserScore(userId, finishedSession);

    return _quizSessions[sessionId];
  }

  // Calcular pontos da sessão
  int _calculatePoints(QuizSession session) {
    int points = 0;

    for (int i = 0; i < session.answers.length; i++) {
      if (session.answers[i].isCorrect) {
        points += 10; // 10 pontos por questão correta
      }
    }

    // Bônus se todas corretas
    if (session.correctAnswers == session.totalAnswers) {
      points += 50; // Bônus de 50 pontos
    }

    return points;
  }

  // Atualizar score do usuário
  void _updateUserScore(String userId, QuizSession session) {
    final currentScore =
        _userScores[userId] ??
        UserScore(userId: userId, lastQuizDate: DateTime.now());

    final now = DateTime.now();
    final wasYesterday = now.difference(currentScore.lastQuizDate).inDays == 1;
    final isToday = now.difference(currentScore.lastQuizDate).inDays == 0;

    final newStreak = isToday
        ? currentScore.streak
        : (wasYesterday ? currentScore.streak + 1 : 1);

    final newMaxStreak = newStreak > currentScore.maxStreak
        ? newStreak
        : currentScore.maxStreak;

    _userScores[userId] = UserScore(
      userId: userId,
      totalPoints: currentScore.totalPoints + session.totalPoints,
      streak: newStreak,
      maxStreak: newMaxStreak,
      quizzesCompleted: currentScore.quizzesCompleted + 1,
      correctAnswers: currentScore.correctAnswers + session.correctAnswers,
      lastQuizDate: now,
      badges: currentScore.badges,
    );

    // Atualizar badges
    _updateBadges(userId);
  }

  // Atualizar badges do usuário
  void _updateBadges(String userId) {
    final score = _userScores[userId];
    if (score == null) return;

    final newBadges = Map<String, int>.from(score.badges);

    // Quiz Perfeito
    if (!newBadges.containsKey('perfeito')) {
      // Verificar se última sessão foi perfeita
      // (Por simplicidade, adicionamos aqui)
    }

    // Semana de Segurança
    if (score.streak >= 7 && !newBadges.containsKey('semana')) {
      newBadges['semana'] = 1;
    }

    // Mês do Motorista
    if (score.maxStreak >= 30 && !newBadges.containsKey('mes')) {
      newBadges['mes'] = 1;
    }

    // Expert CTB
    // (Contar questões CTB corretas)

    _userScores[userId] = UserScore(
      userId: userId,
      totalPoints: score.totalPoints,
      streak: score.streak,
      maxStreak: score.maxStreak,
      quizzesCompleted: score.quizzesCompleted,
      correctAnswers: score.correctAnswers,
      lastQuizDate: score.lastQuizDate,
      badges: newBadges,
    );
  }

  // Obter score do usuário
  UserScore? getUserScore(String userId) {
    return _userScores[userId];
  }

  // Obter sessão de quiz
  QuizSession? getQuizSession(String sessionId) {
    return _quizSessions[sessionId];
  }

  // Obter ranking top 10
  List<UserScore> getTopLeaderboard({int limit = 10}) {
    final sorted = _userScores.values.toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return sorted.take(limit).toList();
  }
}
