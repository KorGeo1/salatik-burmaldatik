import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../models/reward_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Color _leagueColor(String league) {
    switch (league) {
      case 'Gold':
        return AppTheme.gold;
      case 'Silver':
        return AppTheme.silver;
      case 'Bronze':
        return AppTheme.bronze;
      case 'Platinum':
        return const Color(0xFF00BCD4);
      case 'Diamond':
        return AppTheme.legendaryPurple;
      default:
        return AppTheme.silver;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = state.leaderboard;
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Лидерборд',
              style: GoogleFonts.manrope(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Соревнуйся и поднимайся в лигах',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // Текущая лига
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _leagueColor(state.user.league),
                    _leagueColor(state.user.league).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.military_tech_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.user.league} лига',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Топ-3 проходят в следующую лигу',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Пьедестал (топ-3)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _podium(top3[1], 2, 90)),
                Expanded(child: _podium(top3[0], 1, 120)),
                Expanded(child: _podium(top3[2], 3, 70)),
              ],
            ),
            const SizedBox(height: 24),
            // Остальные
            ...rest.map((e) => _row(e)),
          ],
        ),
      ),
    );
  }

  Widget _podium(LeaderboardEntry e, int place, double height) {
    final colors = {
      1: AppTheme.gold,
      2: AppTheme.silver,
      3: AppTheme.bronze,
    };
    final color = colors[place]!;
    return Column(
      children: [
        CircleAvatar(
          radius: place == 1 ? 30 : 24,
          backgroundColor: color,
          child: Text(
            e.name[0],
            style: GoogleFonts.manrope(
              fontSize: place == 1 ? 24 : 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          e.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          '${e.xp} XP',
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '$place',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(LeaderboardEntry e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: e.isCurrentUser
            ? AppTheme.primary.withOpacity(0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: e.isCurrentUser
            ? Border.all(color: AppTheme.primary, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${e.rank}',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: e.isCurrentUser
                ? AppTheme.primary
                : AppTheme.textHint.withOpacity(0.5),
            child: Text(
              e.name[0],
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              e.isCurrentUser ? '${e.name} (Ты)' : e.name,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${e.xp} XP',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}