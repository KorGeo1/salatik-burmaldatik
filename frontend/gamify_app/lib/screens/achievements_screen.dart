import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/milestones_data.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  int get _totalUnlocked =>
      milestones.fold(0, (sum, m) => sum + m.unlockedCount);

  int get _totalAchievements =>
      milestones.fold(0, (sum, m) => sum + m.achievements.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Достижения',
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Открыто $_totalUnlocked из $_totalAchievements достижений',
                style: GoogleFonts.manrope(
                    fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _totalUnlocked / _totalAchievements,
                  minHeight: 10,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: milestones.length,
                  itemBuilder: (context, i) =>
                      _MilestoneCard(milestone: milestones[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Milestone card ───────────────────────────────────────────────────────────

class _MilestoneCard extends StatefulWidget {
  final Milestone milestone;
  const _MilestoneCard({required this.milestone});

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MilestoneSheet(milestone: widget.milestone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.milestone;
    final unlocked = m.unlockedCount;
    final total = m.achievements.length;
    final progress = unlocked / total;
    final completed = m.completed;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _open();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: completed
                ? Border.all(color: m.color.withOpacity(0.45), width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              completed
                  ? Image.asset(m.imagePath,
                      width: 72, height: 72, fit: BoxFit.contain)
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.25, 0.25, 0.25, 0, 0,
                        0.25, 0.25, 0.25, 0, 0,
                        0.25, 0.25, 0.25, 0, 0,
                        0,    0,    0,    0.35, 0,
                      ]),
                      child: Image.asset(m.imagePath,
                          width: 72, height: 72, fit: BoxFit.contain),
                    ),
              const Spacer(),
              Text(
                m.name,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$unlocked / $total',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation(m.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Milestone bottom sheet ───────────────────────────────────────────────────

class _MilestoneSheet extends StatelessWidget {
  final Milestone milestone;
  const _MilestoneSheet({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final m = milestone;
    final unlocked = m.unlockedCount;
    final total = m.achievements.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.93,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textHint.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Image.asset(m.imagePath,
                      width: 56, height: 56, fit: BoxFit.contain),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.fullTitle,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$unlocked из $total открыто',
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: m.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unlocked/$total',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: m.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: unlocked / total,
                  minHeight: 8,
                  backgroundColor: AppTheme.background,
                  valueColor: AlwaysStoppedAnimation(m.color),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: m.achievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _AchievementTile(
                  achievement: m.achievements[i],
                  color: m.color,
                  index: i,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Achievement tile ─────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final Color color;
  final int index;

  const _AchievementTile({
    required this.achievement,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final done = a.current >= a.target;
    final progress =
        (a.target > 0 ? a.current / a.target : 0.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? color.withOpacity(0.06) : AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: done
            ? Border.all(color: color.withOpacity(0.25), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : AppTheme.textHint.withOpacity(0.12),
            ),
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor:
                              AppTheme.textHint.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(
                              done ? color : color.withOpacity(0.55)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      done ? 'Выполнено' : '${a.current} / ${a.target}',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: done ? color : AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}