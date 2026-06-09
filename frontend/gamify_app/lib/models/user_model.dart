class UserModel {
  final String id;
  final String name;
  final String phone;
  int xp;
  int level;
  int coins;
  int streak; // consecutive daily logins
  DateTime? lastLoginDate;
  List<String> badges;
  String league; // Bronze, Silver, Gold, Platinum, Diamond

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.xp = 0,
    this.level = 1,
    this.coins = 0,
    this.streak = 0,
    this.lastLoginDate,
    List<String>? badges,
    this.league = 'Bronze',
  }) : badges = badges ?? [];

  int get xpForNextLevel => level * 500;
  double get xpProgress => (xp % xpForNextLevel) / xpForNextLevel;
  int get currentLevelXp => xp % xpForNextLevel;

  static UserModel demo() => UserModel(
        id: '1',
        name: 'Алексей К.',
        phone: '+7 999 123-45-67',
        xp: 1240,
        level: 4,
        coins: 350,
        streak: 7,
        lastLoginDate: DateTime.now(),
        badges: ['first_login', 'week_streak', 'quest_master'],
        league: 'Silver',
      );
}