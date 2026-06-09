import 'package:flutter/material.dart';

enum QuestType { daily, weekly, special }

class QuestModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final IconData icon;
  final Color color;
  final QuestType type;
  int current; // текущий прогресс
  final int target; // цель
  bool claimed; // награда забрана

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    required this.icon,
    required this.color,
    required this.type,
    this.current = 0,
    required this.target,
    this.claimed = false,
  });

  double get progress => (current / target).clamp(0.0, 1.0);
  bool get isCompleted => current >= target;

  static List<QuestModel> demoList() => [
        QuestModel(
          id: 'q1',
          title: 'Оплати 3 счёта',
          description: 'Оплати любые 3 счёта через приложение',
          xpReward: 150,
          coinReward: 50,
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF00C853),
          type: QuestType.daily,
          current: 2,
          target: 3,
        ),
        QuestModel(
          id: 'q2',
          title: 'Зайди 5 дней подряд',
          description: 'Серия ежедневных входов',
          xpReward: 300,
          coinReward: 100,
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFE8002D),
          type: QuestType.weekly,
          current: 5,
          target: 5,
        ),
        QuestModel(
          id: 'q3',
          title: 'Пригласи друга',
          description: 'Отправь приглашение и получи бонус',
          xpReward: 500,
          coinReward: 200,
          icon: Icons.person_add_rounded,
          color: const Color(0xFF2979FF),
          type: QuestType.special,
          current: 0,
          target: 1,
        ),
        QuestModel(
          id: 'q4',
          title: 'Заполни профиль',
          description: 'Добавь фото и контактные данные',
          xpReward: 100,
          coinReward: 30,
          icon: Icons.account_circle_rounded,
          color: const Color(0xFF7C4DFF),
          type: QuestType.daily,
          current: 1,
          target: 1,
        ),
      ];
}