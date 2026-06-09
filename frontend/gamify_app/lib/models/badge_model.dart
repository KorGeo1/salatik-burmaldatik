import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final int xpRequired;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
    this.xpRequired = 0,
  });

  static List<BadgeModel> demoList() => [
        const BadgeModel(
          id: 'first_login',
          title: 'Первый шаг',
          description: 'Первый вход в приложение',
          icon: Icons.flag_rounded,
          color: Color(0xFF00C853),
          unlocked: true,
        ),
        const BadgeModel(
          id: 'week_streak',
          title: 'Неделя силы',
          description: '7 дней подряд в приложении',
          icon: Icons.local_fire_department_rounded,
          color: Color(0xFFE8002D),
          unlocked: true,
        ),
        const BadgeModel(
          id: 'quest_master',
          title: 'Мастер квестов',
          description: 'Выполни 10 квестов',
          icon: Icons.emoji_events_rounded,
          color: Color(0xFFFFB800),
          unlocked: true,
        ),
        const BadgeModel(
          id: 'high_roller',
          title: 'Везунчик',
          description: 'Выиграй джекпот в колесе',
          icon: Icons.casino_rounded,
          color: Color(0xFF7C4DFF),
          unlocked: false,
        ),
        const BadgeModel(
          id: 'level_10',
          title: 'Профи',
          description: 'Достигни 10 уровня',
          icon: Icons.workspace_premium_rounded,
          color: Color(0xFF2979FF),
          unlocked: false,
          xpRequired: 5000,
        ),
        const BadgeModel(
          id: 'top_league',
          title: 'Легенда',
          description: 'Войди в Алмазную лигу',
          icon: Icons.diamond_rounded,
          color: Color(0xFF00BCD4),
          unlocked: false,
        ),
      ];
}