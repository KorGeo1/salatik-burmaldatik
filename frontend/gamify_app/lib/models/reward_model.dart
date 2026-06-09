import 'package:flutter/material.dart';

// ── Leaderboard entry ─────────────────────────────────────────────────────────

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final String league;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.league,
    required this.isCurrentUser,
  });
}

// ── Reward history item ───────────────────────────────────────────────────────

class RewardHistoryItem {
  final String title;
  final String subtitle;
  final int amount;
  final bool isCoins;
  final IconData icon;
  final Color color;
  final DateTime date;

  const RewardHistoryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCoins,
    required this.icon,
    required this.color,
    required this.date,
  });
}

// ── Wheel prize ───────────────────────────────────────────────────────────────

class WheelPrize {
  final String label;
  final int value;
  final bool isCoins;
  final Color color;

  const WheelPrize({
    required this.label,
    required this.value,
    required this.isCoins,
    required this.color,
  });
}