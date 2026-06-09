import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Achievement ──────────────────────────────────────────────────────────────

class Achievement {
  final String title;
  final int target;
  final int current;
  const Achievement(this.title, this.target, this.current);
}

// ─── Milestone ────────────────────────────────────────────────────────────────

class Milestone {
  final String name;
  final String fullTitle;
  final String imagePath;
  final Color color;
  final List<Achievement> achievements;

  const Milestone({
    required this.name,
    required this.fullTitle,
    required this.imagePath,
    required this.color,
    required this.achievements,
  });

  int get unlockedCount =>
      achievements.where((a) => a.current >= a.target).length;

  bool get completed => unlockedCount == achievements.length;
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const milestones = [
  Milestone(
    name: 'Активность',
    fullTitle: 'Ежедневная активность',
    imagePath: 'assets/images/activity.png',
    color: AppTheme.legendaryPurple,
    achievements: [
      Achievement('Первый вход в приложение',  1,   1),
      Achievement('Вход 3 дня подряд',         3,   3),
      Achievement('Вход 7 дней подряд',        7,   7),
      Achievement('Вход 14 дней подряд',       14,  7),
      Achievement('Вход 30 дней подряд',       30,  7),
      Achievement('Вход 60 дней подряд',       60,  7),
      Achievement('Вход 90 дней подряд',       90,  7),
      Achievement('Вход 180 дней подряд',      180, 7),
      Achievement('Вход 365 дней подряд',      365, 7),
    ],
  ),
  Milestone(
    name: 'Квесты',
    fullTitle: 'Выполнение квестов',
    imagePath: 'assets/images/quests.png',
    color: AppTheme.xpBlue,
    achievements: [
      Achievement('Выполнить 1 квест',      1,    1),
      Achievement('Выполнить 10 квестов',   10,   10),
      Achievement('Выполнить 25 квестов',   25,   10),
      Achievement('Выполнить 50 квестов',   50,   10),
      Achievement('Выполнить 100 квестов',  100,  10),
      Achievement('Выполнить 250 квестов',  250,  10),
      Achievement('Выполнить 500 квестов',  500,  10),
      Achievement('Выполнить 1000 квестов', 1000, 10),
      Achievement('Выполнить 2500 квестов', 2500, 10),
    ],
  ),
  Milestone(
    name: 'Удача',
    fullTitle: 'Колесо фортуны и удача',
    imagePath: 'assets/images/image.png',
    color: AppTheme.primary,
    achievements: [
      Achievement('Прокрутить колесо впервые',     1,  1),
      Achievement('Прокрутить колесо 10 раз',      10, 1),
      Achievement('Прокрутить колесо 50 раз',      50, 1),
      Achievement('Выиграть редкий приз',          1,  0),
      Achievement('Выиграть 5 призов подряд',      5,  0),
      Achievement('Получить максимальную награду', 1,  0),
      Achievement('Выиграть крупный приз',         1,  0),
      Achievement('Выиграть джекпот',              1,  0),
      Achievement('Выиграть джекпот 5 раз',        5,  0),
    ],
  ),
  Milestone(
    name: 'Уровень',
    fullTitle: 'Уровень аккаунта',
    imagePath: 'assets/images/lvl.png',
    color: AppTheme.questGreen,
    achievements: [
      Achievement('Достичь 5 уровня',             5,   4),
      Achievement('Достичь 10 уровня',            10,  4),
      Achievement('Достичь 20 уровня',            20,  4),
      Achievement('Достичь 30 уровня',            30,  4),
      Achievement('Достичь 40 уровня',            40,  4),
      Achievement('Достичь 50 уровня',            50,  4),
      Achievement('Достичь 75 уровня',            75,  4),
      Achievement('Достичь 100 уровня',           100, 4),
      Achievement('Достичь максимального уровня', 200, 4),
    ],
  ),
  Milestone(
    name: 'Лиги',
    fullTitle: 'Ранги и лиги',
    imagePath: 'assets/images/league.png',
    color: AppTheme.gold,
    achievements: [
      Achievement('Войти в Бронзовую лигу',            1,  1),
      Achievement('Войти в Серебряную лигу',           1,  1),
      Achievement('Войти в Золотую лигу',              1,  0),
      Achievement('Войти в Платиновую лигу',           1,  0),
      Achievement('Войти в Алмазную лигу',             1,  0),
      Achievement('Провести 7 дней в Алмазной лиге',   7,  0),
      Achievement('Провести 30 дней в Алмазной лиге',  30, 0),
      Achievement('Попасть в топ-10 рейтинга',         1,  0),
      Achievement('Занять 1 место в рейтинге',         1,  0),
    ],
  ),
];