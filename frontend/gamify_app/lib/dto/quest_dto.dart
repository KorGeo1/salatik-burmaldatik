import 'package:flutter/material.dart';
import '../models/quest_model.dart';

class QuestDto {
  final int id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final String type; // "daily" | "weekly" | "special"
  final int current;
  final int target;
  final bool claimed;

  const QuestDto({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    required this.type,
    required this.current,
    required this.target,
    required this.claimed,
  });

  factory QuestDto.fromJson(Map<String, dynamic> json) => QuestDto(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
        coinReward: (json['coin_reward'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? 'daily',
        current: (json['current'] as num?)?.toInt() ?? 0,
        target: (json['target'] as num?)?.toInt() ?? 1,
        claimed: json['claimed'] as bool? ?? false,
      );

  QuestModel toModel() => QuestModel(
        id: id.toString(),
        title: title,
        description: description,
        xpReward: xpReward,
        coinReward: coinReward,
        icon: _iconForType(type),
        color: _colorForType(type),
        type: _questType(type),
        current: current,
        target: target,
        claimed: claimed,
      );

  static QuestType _questType(String t) => switch (t) {
        'weekly' => QuestType.weekly,
        'special' => QuestType.special,
        _ => QuestType.daily,
      };

  static IconData _iconForType(String t) => switch (t) {
        'weekly' => Icons.local_fire_department_rounded,
        'special' => Icons.star_rounded,
        _ => Icons.emoji_events_rounded,
      };

  static Color _colorForType(String t) => switch (t) {
        'weekly' => const Color(0xFFE8002D),
        'special' => const Color(0xFF7C4DFF),
        _ => const Color(0xFF00C853),
      };
}

class CompleteQuestResponse {
  final int xpEarned;
  final int coinsEarned;
  final String message;

  const CompleteQuestResponse({
    required this.xpEarned,
    required this.coinsEarned,
    required this.message,
  });

  factory CompleteQuestResponse.fromJson(Map<String, dynamic> json) =>
      CompleteQuestResponse(
        xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
        coinsEarned: (json['coins_earned'] as num?)?.toInt() ?? 0,
        message: json['message'] as String? ?? '',
      );
}
