import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/milestones_data.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _BadgeData {
  final String imagePath;
  final String name;
  final String condition;
  final Color color;
  final int milestoneIndex;

  const _BadgeData({
    required this.imagePath,
    required this.name,
    required this.condition,
    required this.color,
    required this.milestoneIndex,
  });
}

const _badgeData = [
  _BadgeData(
    imagePath: 'assets/images/activity.png',
    name: 'Активист',
    condition: 'Закройте веху «Ежедневная активность»',
    color: AppTheme.legendaryPurple,
    milestoneIndex: 0,
  ),
  _BadgeData(
    imagePath: 'assets/images/quests.png',
    name: 'Мастер квестов',
    condition: 'Закройте веху «Выполнение квестов»',
    color: AppTheme.xpBlue,
    milestoneIndex: 1,
  ),
  _BadgeData(
    imagePath: 'assets/images/image.png',
    name: 'Везунчик',
    condition: 'Закройте веху «Колесо фортуны и удача»',
    color: AppTheme.primary,
    milestoneIndex: 2,
  ),
  _BadgeData(
    imagePath: 'assets/images/lvl.png',
    name: 'Легенда',
    condition: 'Закройте веху «Уровень аккаунта»',
    color: AppTheme.questGreen,
    milestoneIndex: 3,
  ),
  _BadgeData(
    imagePath: 'assets/images/league.png',
    name: 'Чемпион лиг',
    condition: 'Закройте веху «Ранги и лиги»',
    color: AppTheme.gold,
    milestoneIndex: 4,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnedCount =
        _badgeData.where((b) => milestones[b.milestoneIndex].completed).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Мои бейджи',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.2),
                          width: 1.5),
                    ),
                    child: Text(
                      '$earnedCount / ${_badgeData.length}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Закрывай вехи достижений — получай бейджи',
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: earnedCount / _badgeData.length,
                  minHeight: 8,
                  backgroundColor: AppTheme.textHint.withOpacity(0.15),
                  valueColor:
                      const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                itemCount: _badgeData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final badge = _badgeData[i];
                  final milestone = milestones[badge.milestoneIndex];
                  final earned = milestone.completed;
                  return _BadgeTile(
                    badge: badge,
                    earned: earned,
                    milestone: milestone,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge tile ───────────────────────────────────────────────────────────────

class _BadgeTile extends StatelessWidget {
  final _BadgeData badge;
  final bool earned;
  final Milestone milestone;

  const _BadgeTile({
    required this.badge,
    required this.earned,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = milestone.unlockedCount;
    final total = milestone.achievements.length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: earned
            ? Border.all(color: badge.color.withOpacity(0.35), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: earned
                ? badge.color.withOpacity(0.10)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _BadgeIcon(
                imagePath: badge.imagePath,
                color: badge.color,
                earned: earned),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badge.name,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: earned
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (earned) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badge.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Получен',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badge.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    badge.condition,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: earned
                          ? badge.color.withOpacity(0.09)
                          : AppTheme.textHint.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          earned
                              ? Icons.check_circle_rounded
                              : Icons.lock_outline_rounded,
                          size: 11,
                          color:
                              earned ? badge.color : AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          earned
                              ? 'Веха закрыта'
                              : '$unlocked / $total выполнено',
                          style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: earned ? badge.color : AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge icon ───────────────────────────────────────────────────────────────

class _BadgeIcon extends StatelessWidget {
  final String imagePath;
  final Color color;
  final bool earned;

  const _BadgeIcon({
    required this.imagePath,
    required this.color,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    if (earned) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(imagePath,
            width: 64, height: 64, fit: BoxFit.contain),
      );
    }

    return SizedBox(
      width: 64,
      height: 64,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.25, 0.25, 0.25, 0, 0,
          0.25, 0.25, 0.25, 0, 0,
          0.25, 0.25, 0.25, 0, 0,
          0,    0,    0,    0.3, 0,
        ]),
        child: Image.asset(imagePath,
            width: 64, height: 64, fit: BoxFit.contain),
      ),
    );
  }
}