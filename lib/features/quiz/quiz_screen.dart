import 'package:flutter/material.dart';
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/database/quiz_database.dart';
import 'package:safe/core/models/quiz.dart';
import 'package:safe/shared/services/current_user_profile.dart';
import 'package:safe/shared/services/safe_app_store.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const QuizScreen({super.key, this.onBack});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SafeAppStore _store = SafeAppStore.instance;
  late List<QuizQuestion> _questions;

  int _currentIndex = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  int _sessionPoints = 0;
  bool _isAnswered = false;
  bool _isCompleted = false;

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _questions = QuizDatabase.getRandomQuestions(count: 5);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: _isCompleted
                ? _buildResultScreen(context)
                : _buildQuizBody(context),
          ),
        );
      },
    );
  }

  Widget _buildQuizBody(BuildContext context) {
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Text(
            'Pergunta ${_currentIndex + 1} de ${_questions.length}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bgCardLight,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _currentQuestion.question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuestionVisual(_currentQuestion),
          const SizedBox(height: 20),
          ...List.generate(_currentQuestion.options.length, _buildAnswerOption),
          const SizedBox(height: 14),
          if (_isAnswered) _buildExplanationCard(),
          const SizedBox(height: 24),
          _buildNextButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded, color: AppColors.accent, size: 24),
                SizedBox(width: 8),
                Text(
                  'SAFE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$_sessionPoints pts',
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionVisual(QuizQuestion question) {
    final icon = switch (question.category) {
      'ctb' => Icons.menu_book_rounded,
      'sinais' => Icons.traffic_rounded,
      _ => Icons.health_and_safety_rounded,
    };

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.purple.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.accent, size: 48),
                const SizedBox(height: 10),
                Text(
                  question.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = index == _currentQuestion.correctAnswerIndex;
    final showCorrect = _isAnswered && isCorrect;
    final showWrong = _isAnswered && isSelected && !isCorrect;
    final color = showCorrect
        ? AppColors.green
        : showWrong
        ? AppColors.red
        : isSelected
        ? AppColors.accent
        : AppColors.bgCard;
    final textColor = isSelected || showCorrect
        ? AppColors.bgPrimary
        : Colors.white;

    return GestureDetector(
      onTap: _isAnswered ? null : () => _answerCurrentQuestion(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected || showCorrect ? color : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            _buildOptionIndicator(isSelected, showCorrect, showWrong),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _currentQuestion.options[index],
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: showCorrect ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionIndicator(
    bool isSelected,
    bool showCorrect,
    bool showWrong,
  ) {
    if (showCorrect || showWrong) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgPrimary,
        ),
        child: Icon(
          showCorrect ? Icons.check_rounded : Icons.close_rounded,
          color: showCorrect ? AppColors.green : AppColors.red,
          size: 16,
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.bgPrimary : AppColors.textMuted,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    final answeredCorrectly =
        _selectedAnswer == _currentQuestion.correctAnswerIndex;
    final title = answeredCorrectly ? 'Resposta correta' : 'Resposta incorreta';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2318),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (answeredCorrectly ? AppColors.green : AppColors.red)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                answeredCorrectly
                    ? Icons.lightbulb_rounded
                    : Icons.school_rounded,
                color: AppColors.accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastQuestion = _currentIndex == _questions.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isAnswered ? () => _goToNextQuestion() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.bgCardLight,
          foregroundColor: AppColors.bgPrimary,
          disabledForegroundColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          isLastQuestion ? 'VER RANKING FINAL' : 'PRÓXIMA PERGUNTA',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context) {
    final perfect = _correctAnswers == _questions.length;
    final leaderboard = _store.getLeaderboard(limit: 5);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  perfect ? Icons.emoji_events_rounded : Icons.shield_rounded,
                  color: AppColors.accent,
                  size: 54,
                ),
                const SizedBox(height: 12),
                Text(
                  perfect ? 'Quiz perfeito!' : 'Quiz concluído',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_correctAnswers/${_questions.length} acertos • $_sessionPoints pontos',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildResultChip(
                      Icons.local_fire_department_rounded,
                      '${_store.userScore.streak} dias',
                    ),
                    _buildResultChip(
                      Icons.speed_rounded,
                      '${_store.userScore.safetyScore} score',
                    ),
                    if (_store.userScore.badges.containsKey('maio_amarelo'))
                      _buildResultChip(
                        Icons.workspace_premium_rounded,
                        'Maio Amarelo',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ranking',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in leaderboard) ...[
            _buildLeaderboardItem(
              entry.rank,
              entry.userId,
              entry.userName,
              entry.points,
              entry.streak,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _startNewQuiz,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Novo quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bgPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildResultChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String userId,
    String name,
    int points,
    int streak,
  ) {
    final isUser = userId == CurrentUserProfile.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUser
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.orange,
            size: 16,
          ),
          Text(
            '$streak',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _answerCurrentQuestion(int answerIndex) async {
    final isCorrect = answerIndex == _currentQuestion.correctAnswerIndex;
    final earnedPoints = isCorrect ? 10 + (_currentQuestion.difficulty * 2) : 0;

    setState(() {
      _selectedAnswer = answerIndex;
      _isAnswered = true;

      if (isCorrect) {
        _correctAnswers++;
        _sessionPoints += earnedPoints;
      }
    });

    if (earnedPoints > 0) {
      await _store.awardQuizPoints(earnedPoints);
    }
  }

  Future<void> _goToNextQuestion() async {
    final isLastQuestion = _currentIndex == _questions.length - 1;

    if (isLastQuestion) {
      final perfect = _correctAnswers == _questions.length;
      if (perfect) {
        setState(() => _sessionPoints += 50);
        await _store.awardQuizPoints(50);
      }

      await _store.completeQuiz(
        earnedPoints: 0,
        correctAnswers: _correctAnswers,
        totalQuestions: _questions.length,
        perfect: perfect,
      );

      if (!mounted) return;
      setState(() => _isCompleted = true);
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _isAnswered = false;
    });
  }

  void _startNewQuiz() {
    setState(() {
      _questions = QuizDatabase.getRandomQuestions(count: 5);
      _currentIndex = 0;
      _selectedAnswer = null;
      _correctAnswers = 0;
      _sessionPoints = 0;
      _isAnswered = false;
      _isCompleted = false;
    });
  }
}
