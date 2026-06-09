import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../models/reward_model.dart';
import '../models/reward_item.dart';

// ── Achievements ─────────────────────────────────────────────────────────────

class AchievementDto {
  final int id;
  final String slug;
  final String title;
  final String description;
  final int xpRequired;
  final bool unlocked;

  const AchievementDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.xpRequired,
    required this.unlocked,
  });

  factory AchievementDto.fromJson(Map<String, dynamic> json) => AchievementDto(
        id: (json['id'] as num).toInt(),
        slug: json['slug'] as String? ?? json['id'].toString(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        xpRequired: (json['xp_required'] as num?)?.toInt() ?? 0,
        unlocked: json['unlocked'] as bool? ?? false,
      );

  BadgeModel toModel() => BadgeModel(
        id: slug,
        title: title,
        description: description,
        icon: _iconForSlug(slug),
        color: _colorForSlug(slug),
        unlocked: unlocked,
        xpRequired: xpRequired,
      );

  static IconData _iconForSlug(String slug) => switch (slug) {
        'first_login' => Icons.flag_rounded,
        'week_streak' => Icons.local_fire_department_rounded,
        'quest_master' => Icons.emoji_events_rounded,
        'high_roller' => Icons.casino_rounded,
        'level_10' => Icons.workspace_premium_rounded,
        'top_league' => Icons.diamond_rounded,
        _ => Icons.military_tech_rounded,
      };

  static Color _colorForSlug(String slug) => switch (slug) {
        'first_login' => const Color(0xFF00C853),
        'week_streak' => const Color(0xFFE8002D),
        'quest_master' => const Color(0xFFFFB800),
        'high_roller' => const Color(0xFF7C4DFF),
        'level_10' => const Color(0xFF2979FF),
        'top_league' => const Color(0xFF00BCD4),
        _ => const Color(0xFF9E9E9E),
      };
}

// ── Rewards / Shop ────────────────────────────────────────────────────────────

class RewardDto {
  final int id;
  final String title;
  final String description;
  final int price;
  final String? imageUrl;
  final bool available;

  const RewardDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.available,
  });

  factory RewardDto.fromJson(Map<String, dynamic> json) => RewardDto(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        imageUrl: json['image_url'] as String?,
        available: json['available'] as bool? ?? true,
      );

  RewardItem toModel() => RewardItem(
        id: id.toString(),
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
        available: available,
      );
}

class PurchaseResponse {
  final int newBalance;
  final String message;

  const PurchaseResponse({required this.newBalance, required this.message});

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseResponse(
        newBalance: (json['new_balance'] as num?)?.toInt() ?? 0,
        message: json['message'] as String? ?? '',
      );
}

// ── Leaderboard ───────────────────────────────────────────────────────────────

class LeaderboardEntryDto {
  final int rank;
  final String username;
  final int xp;
  final String league;
  final bool isCurrentUser;

  const LeaderboardEntryDto({
    required this.rank,
    required this.username,
    required this.xp,
    required this.league,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryDto(
        rank: (json['rank'] as num).toInt(),
        username: json['username'] as String? ?? '',
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        league: json['league'] as String? ?? 'Bronze',
        isCurrentUser: json['is_current_user'] as bool? ?? false,
      );

  LeaderboardEntry toModel() => LeaderboardEntry(
        rank: rank,
        name: username,
        xp: xp,
        league: league,
        isCurrentUser: isCurrentUser,
      );
}

// ── Wheel ─────────────────────────────────────────────────────────────────────

class WheelSpinResponse {
  final String label;
  final int value;
  final bool isCoins;

  const WheelSpinResponse({
    required this.label,
    required this.value,
    required this.isCoins,
  });

  factory WheelSpinResponse.fromJson(Map<String, dynamic> json) =>
      WheelSpinResponse(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toInt() ?? 0,
        isCoins: json['is_coins'] as bool? ?? true,
      );
}