class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category; // 'ctb', 'sinais', 'praticas'
  final int difficulty; // 1-5
  final String? imageUrl;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
    this.imageUrl,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswerIndex: map['correctAnswerIndex'] as int,
      explanation: map['explanation'] as String,
      category: map['category'] as String,
      difficulty: map['difficulty'] as int? ?? 1,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
    };
  }
}

class QuizAnswer {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final DateTime answeredAt;

  QuizAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.answeredAt,
  });
}

class QuizSession {
  final String id;
  final String userId;
  final List<QuizAnswer> answers;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int totalPoints;

  QuizSession({
    required this.id,
    required this.userId,
    required this.answers,
    required this.startedAt,
    this.finishedAt,
    this.totalPoints = 0,
  });

  int get correctAnswers => answers.where((a) => a.isCorrect).length;
  int get totalAnswers => answers.length;
  double get percentage =>
      totalAnswers > 0 ? (correctAnswers / totalAnswers) * 100 : 0;

  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      answers: (map['answers'] as List? ?? [])
          .map(
            (a) => QuizAnswer(
              questionId: a['questionId'] as String,
              selectedAnswerIndex: a['selectedAnswerIndex'] as int,
              isCorrect: a['isCorrect'] as bool,
              answeredAt: DateTime.parse(a['answeredAt'] as String),
            ),
          )
          .toList(),
      startedAt: DateTime.parse(map['startedAt'] as String),
      finishedAt: map['finishedAt'] != null
          ? DateTime.parse(map['finishedAt'] as String)
          : null,
      totalPoints: map['totalPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'answers': answers
          .map(
            (a) => {
              'questionId': a.questionId,
              'selectedAnswerIndex': a.selectedAnswerIndex,
              'isCorrect': a.isCorrect,
              'answeredAt': a.answeredAt.toIso8601String(),
            },
          )
          .toList(),
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'totalPoints': totalPoints,
    };
  }
}
