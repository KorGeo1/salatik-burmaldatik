/// Central place for all API configuration.
/// Override [baseUrl] with an env variable or build flavor if needed.
class ApiConfig {
  ApiConfig._();

  /// In development: http://127.0.0.1:8000
  /// In production : replace with your real domain.
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000');

  // ── Endpoint constants ────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String dailyReward = '/auth/daily-reward';

  static const String me = '/users/me';

  static const String quests = '/quests';
  static String questComplete(int id) => '/quests/$id/complete';

  static const String achievements = '/achievements';
  static const String myAchievements = '/achievements/my';

  static const String rewards = '/rewards';
  static String rewardPurchase(int id) => '/rewards/$id/purchase';

  static const String leaderboard = '/leaderboard';

  static const String wheelSpin = '/wheel/spin';
}
