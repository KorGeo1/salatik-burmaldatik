import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                        ),
                      Text(
                        'Профиль',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.manrope(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.league} лига • Уровень ${user.level}',
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionTitle('Личные данные'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'Имя',
                        value: user.name),
                    _Divider(),
                    _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Телефон',
                        value: user.phone.isEmpty ? '—' : user.phone),
                  ]),
                  const SizedBox(height: 20),
                  _SectionTitle('Статистика'),
                  const SizedBox(height: 8),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.bolt_rounded,
                        label: 'Опыт (XP)',
                        value: '${user.xp} XP',
                        valueColor: AppTheme.xpBlue),
                    _Divider(),
                    _InfoRow(
                        icon: Icons.monetization_on_rounded,
                        label: 'Монеты',
                        value: '${user.coins} 🪙',
                        valueColor: AppTheme.gold),
                    _Divider(),
                    _InfoRow(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Серия входов',
                        value: '${user.streak} дней',
                        valueColor: AppTheme.primary),
                    _Divider(),
                    _InfoRow(
                        icon: Icons.military_tech_rounded,
                        label: 'Лига',
                        value: user.league),
                  ]),
                  const SizedBox(height: 32),
                  // ── Logout button ──────────────────────────────────────────
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<AppState>().logout();
                      // _AuthGate in main.dart handles redirect automatically
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.primary),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Выйти из аккаунта',
                      style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const Spacer(),
            Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppTheme.textPrimary)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 48);
}
