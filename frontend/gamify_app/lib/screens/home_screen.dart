import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/stat_chip.dart';
import '../widgets/daily_checkin.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';
import 'badges_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ── Profile row ──────────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      user.name[0],
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Привет,',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        user.name,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.silver.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.military_tech_rounded,
                            color: AppTheme.silver, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          user.league,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Level card ───────────────────────────────────────────────────
            _LevelCard(),
            const SizedBox(height: 16),

            // ── Stat chips ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    emoji: '🪙',
                    color: AppTheme.gold,
                    value: '${user.coins}',
                    label: 'Монеты',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatChip(
                    icon: Icons.bolt_rounded,
                    color: AppTheme.xpBlue,
                    value: '${user.xp}',
                    label: 'Опыт (XP)',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatChip(
                    icon: Icons.local_fire_department_rounded,
                    color: AppTheme.primary,
                    value: '${user.streak}',
                    label: 'Дней подряд',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Quick-access banners: Shop + Badges ──────────────────────────
            _QuickAccessRow(),
            const SizedBox(height: 20),

            // ── Daily check-in ────────────────────────────────────────────────
            const DailyCheckIn(),
            const SizedBox(height: 24),

            // ── Bonus history ─────────────────────────────────────────────────
            Text(
              'История бонусов',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...state.history.map((item) => _HistoryTile(item: item)),
          ],
        ),
      ),
    );
  }
}

// ─── Quick-access row (Shop + Badges) ─────────────────────────────────────────

class _QuickAccessRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BannerCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8002D), Color(0xFFB8001F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconEmoji: '🛍️',
            title: 'Магазин',
            subtitle: 'Трать монеты\nна мерч',
            accentText: '10 товаров',
            accentIcon: Icons.arrow_forward_ios_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShopScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BannerCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFF5C35CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            iconEmoji: '🏅',
            title: 'Бейджи',
            subtitle: '1 из 5\nполучено',
            accentText: 'Смотреть',
            accentIcon: Icons.arrow_forward_ios_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BadgesScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatefulWidget {
  final LinearGradient gradient;
  final String iconEmoji;
  final String title;
  final String subtitle;
  final String accentText;
  final IconData accentIcon;
  final VoidCallback onTap;

  const _BannerCard({
    required this.gradient,
    required this.iconEmoji,
    required this.title,
    required this.subtitle,
    required this.accentText,
    required this.accentIcon,
    required this.onTap,
  });

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.38),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.iconEmoji,
                      style: const TextStyle(fontSize: 22)),
                  const Spacer(),
                  Icon(widget.accentIcon,
                      size: 14, color: Colors.white.withOpacity(0.7)),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                widget.subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 10.5,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Level card ───────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Уровень ${user.level}',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${user.currentLevelXp} / ${user.xpForNextLevel} XP',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: user.xpProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ещё ${user.xpForNextLevel - user.currentLevelXp} XP до уровня ${user.level + 1} 🚀',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── History tile ─────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final dynamic item;
  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final positive = item.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : ''}${item.amount} ${item.isCoins ? '🪙' : 'XP'}',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: positive ? AppTheme.questGreen : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}