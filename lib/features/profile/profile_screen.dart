import 'package:flutter/material.dart' hide Badge;
import 'package:safe/core/constants/app_colors.dart';
import 'package:safe/core/models/user_score.dart';
import 'package:safe/shared/services/current_user_profile.dart';
import 'package:safe/shared/services/safe_app_store.dart';
import 'package:safe/shared/widgets/app_logo.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenQuiz;
  final VoidCallback? onOpenMap;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.onOpenQuiz,
    this.onOpenMap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final store = SafeAppStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final score = store.userScore;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(),
                  const SizedBox(height: 22),
                  _buildProfileCard(score),
                  const SizedBox(height: 18),
                  _buildStatsGrid(score, store),
                  const SizedBox(height: 22),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  _buildLogoutButton(),
                  const SizedBox(height: 22),
                  _buildProgressCard(score),
                  const SizedBox(height: 22),
                  _buildBadges(score),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return const Row(
      children: [
        AppLogo(size: 36),
        SizedBox(width: 12),
        Text(
          'Perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserScore score) {
    final photoUrl = CurrentUserProfile.photoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildAvatar(photoUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrentUserProfile.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (CurrentUserProfile.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    CurrentUserProfile.email!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  score.safetyLevel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    '${score.streak} dias de sequência',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            height: 70,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    final fallback = Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          CurrentUserProfile.initial,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (photoUrl == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.network(
        photoUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _buildStatsGrid(UserScore score, SafeAppStore store) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        final aspectRatio = (tileWidth / 112).clamp(1.55, 5.5).toDouble();

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: aspectRatio,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatTile(
              Icons.workspace_premium_rounded,
              '${score.totalPoints}',
              'pontos',
              AppColors.accent,
            ),
            _buildStatTile(
              Icons.quiz_rounded,
              '${score.quizzesCompleted}',
              'quizzes',
              AppColors.purple,
            ),
            _buildStatTile(
              Icons.check_circle_rounded,
              '${score.correctAnswers}',
              'acertos',
              AppColors.green,
            ),
            _buildStatTile(
              Icons.flag_rounded,
              '${store.reports.length}',
              'relatórios',
              AppColors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatTile(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.quiz_rounded,
            label: 'Responder quiz',
            onTap: onOpenQuiz,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.map_rounded,
            label: 'Ver mapa',
            onTap: onOpenMap,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sair da conta'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.75)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bgPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProgressCard(UserScore score) {
    final totalAnswers = score.quizzesCompleted * 5;
    final accuracy = totalAnswers == 0
        ? 0
        : ((score.correctAnswers / totalAnswers) * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução de segurança',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            'Aproveitamento nos quizzes',
            '$accuracy%',
            accuracy / 100,
          ),
          const SizedBox(height: 14),
          _buildProgressRow(
            'Melhor sequência',
            '${score.maxStreak} dias',
            (score.maxStreak / 30).clamp(0, 1).toDouble(),
          ),
          const SizedBox(height: 14),
          _buildProgressRow(
            'Badges conquistadas',
            '${score.badges.length}/${Badges.allBadges.length}',
            (score.badges.length / Badges.allBadges.length).clamp(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: AppColors.accent,
            backgroundColor: AppColors.bgCardLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(UserScore score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (final badge in Badges.allBadges) ...[
          _buildBadgeTile(badge, score.badges.containsKey(badge.id)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildBadgeTile(Badge badge, bool earned) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: earned ? AppColors.accentLight : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? AppColors.accent.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    color: earned
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  badge.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            earned ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: earned ? AppColors.green : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
