import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

/// Карточка ежедневного входа с наградами за 7 дней
class DailyCheckIn extends StatelessWidget {
  const DailyCheckIn({super.key});

  static const List<int> rewards = [10, 20, 30, 40, 50, 75, 150];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final streak = state.user.streak;
    final claimed = state.dailyClaimedToday;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Ежедневный вход',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Серия: $streak 🔥',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 7 дней
          Row(
            children: List.generate(7, (i) {
              final day = i + 1;
              final isPast = day <= streak;
              final isToday = day == streak + 1 && !claimed;
              final isFuture = !isPast && !isToday;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  child: _DayCell(
                    day: day,
                    coins: rewards[i],
                    isPast: isPast,
                    isToday: isToday,
                    isFuture: isFuture,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Claim button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: claimed
                  ? null
                  : () async {
                      await context.read<AppState>().claimDailyReward();
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                backgroundColor:
                    claimed ? AppTheme.surface : AppTheme.primary,
                disabledBackgroundColor:
                    AppTheme.textHint.withValues(alpha: 0.15),
              ),
              child: Text(
                claimed ? '✓ Получено сегодня' : 'Получить награду',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: claimed ? AppTheme.textHint : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int coins;
  final bool isPast;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    required this.coins,
    required this.isPast,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget icon;

    if (isPast) {
      bgColor = AppTheme.questGreen.withValues(alpha: 0.15);
      textColor = AppTheme.questGreen;
      icon = const Icon(Icons.check_circle_rounded,
          color: AppTheme.questGreen, size: 18);
    } else if (isToday) {
      bgColor = AppTheme.primary.withValues(alpha: 0.12);
      textColor = AppTheme.primary;
      icon = Text(
        '🪙$coins',
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppTheme.primary,
        ),
      );
    } else {
      bgColor = AppTheme.background;
      textColor = AppTheme.textHint;
      icon = Text(
        '🪙$coins',
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppTheme.textHint,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppTheme.primary, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'День $day',
            style: GoogleFonts.manrope(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          icon,
        ],
      ),
    );
  }
}