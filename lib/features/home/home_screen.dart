import 'package:flutter/material.dart';
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/database/educative_database.dart';
import 'package:safe/core/models/traffic_point.dart';
import 'package:safe/core/models/user_score.dart';
import 'package:safe/shared/services/current_user_profile.dart';
import 'package:safe/shared/services/safe_app_store.dart';
import 'package:safe/shared/widgets/app_logo.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onOpenMap;
  final VoidCallback? onOpenQuiz;

  const HomeScreen({super.key, this.onOpenMap, this.onOpenQuiz});

  @override
  Widget build(BuildContext context) {
    final store = SafeAppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildLogoRow(store.userScore),
                  const SizedBox(height: 20),
                  _buildHeader(store.userScore),
                  const SizedBox(height: 24),
                  _buildMaioAmareloBanner(store),
                  const SizedBox(height: 14),
                  _buildWeeklyChallenge(store),
                  const SizedBox(height: 20),
                  _buildStatsRow(store),
                  const SizedBox(height: 20),
                  _buildScoreCard(store.userScore),
                  const SizedBox(height: 24),
                  _buildAlertasProximos(store),
                  const SizedBox(height: 24),
                  _buildEducativeTips(),
                  const SizedBox(height: 24),
                  _buildDesafioDoDia(store),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoRow(UserScore score) {
    return Row(
      children: [
        const AppLogo(size: 40),
        const SizedBox(width: 12),
        const Text(
          'SAFE',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${score.safetyScore}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(UserScore score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bom dia,',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                CurrentUserProfile.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${score.streak} dias de sequência',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaioAmareloBanner(SafeAppStore store) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MAIO AMARELO',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'No trânsito, escolha a vida.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.bgPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        store.campaignCountdownLabel,
                        style: const TextStyle(
                          color: AppColors.bgPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.campaign_rounded,
            size: 48,
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(SafeAppStore store) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.accent,
            value: _formatNumber(store.trafficPointsThisMonth),
            label: 'pontos no mês',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag_outlined,
            iconColor: AppColors.purple,
            value: _formatNumber(store.reportsThisMonth),
            label: 'denúncias no mês',
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChallenge(SafeAppStore store) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flag_circle_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desafio semanal',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  store.weeklyChallengeTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            store.weeklyChallengeProgressLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(UserScore score) {
    final earnedBadges = Badges.allBadges
        .where((badge) => score.badges.containsKey(badge.id))
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: AppColors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Score do motorista',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score.safetyScore / 100,
                      strokeWidth: 7,
                      backgroundColor: AppColors.bgCardLight,
                      color: AppColors.accent,
                    ),
                    Center(
                      child: Text(
                        '${score.safetyScore}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score.safetyLevel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${score.totalPoints} pts • ${score.quizzesCompleted} quizzes concluídos',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: earnedBadges.isEmpty
                ? [_buildBadgeChip('Meta', 'Complete o quiz de hoje')]
                : earnedBadges
                      .map((badge) => _buildBadgeChip(badge.emoji, badge.name))
                      .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$emoji $label',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAlertasProximos(SafeAppStore store) {
    final alerts = store.trafficPointsByCategory(null).take(2).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alertas próximos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onOpenMap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver mapa',
                style: TextStyle(color: AppColors.accent, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final alert in alerts) ...[
          _buildAlertItem(alert),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildAlertItem(TrafficPoint point) {
    final color = _categoryColor(point.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(point.category), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  point.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${point.confirmations} ok',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEducativeTips() {
    final contents = EducativeDatabase.getRecent(count: 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feed educativo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (final content in contents) ...[
          _buildEducativeCard(
            emoji: content.emoji,
            title: content.title,
            description: content.description,
            category: content.category,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildEducativeCard({
    required String emoji,
    required String title,
    required String description,
    required String category,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesafioDoDia(SafeAppStore store) {
    final challenge = store.dailyChallenge;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1800), Color(0xFF2D2500)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: AppColors.accent,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'DESAFIO DO DIA',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onOpenQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bgPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Responder agora',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(TrafficPointCategory category) {
    return switch (category) {
      TrafficPointCategory.accident => AppColors.red,
      TrafficPointCategory.pothole => AppColors.orange,
      TrafficPointCategory.signal => AppColors.purple,
      TrafficPointCategory.construction => AppColors.accent,
      TrafficPointCategory.phone => AppColors.purpleLight,
      TrafficPointCategory.redLight => AppColors.red,
      TrafficPointCategory.speeding => AppColors.green,
    };
  }

  IconData _categoryIcon(TrafficPointCategory category) {
    return switch (category) {
      TrafficPointCategory.accident => Icons.car_crash_rounded,
      TrafficPointCategory.pothole => Icons.warning_amber_rounded,
      TrafficPointCategory.signal => Icons.traffic_rounded,
      TrafficPointCategory.construction => Icons.construction_rounded,
      TrafficPointCategory.phone => Icons.phone_android_rounded,
      TrafficPointCategory.redLight => Icons.traffic_rounded,
      TrafficPointCategory.speeding => Icons.speed_rounded,
    };
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
