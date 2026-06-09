import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/quest_model.dart';
import '../models/badge_model.dart';
import '../models/reward_model.dart';
import '../models/reward_item.dart';
import '../dto/auth_dto.dart';
import '../api/api_client.dart';
import '../services/services.dart';

// ── Auth status ───────────────────────────────────────────────────────────────

enum AuthStatus { unknown, authenticated, unauthenticated }

// ── AppState ──────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  // ── Auth ──────────────────────────────────────────────────────────────────
  AuthStatus _authStatus = AuthStatus.unknown;
  AuthStatus get authStatus => _authStatus;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  // ── User ────────────────────────────────────────────────────────────────���─
  UserModel? _user;
  UserModel get user => _user ?? UserModel.demo();

  // ── Remote data ───────────────────────────────────────────────────────────
  List<QuestModel> quests = [];
  List<BadgeModel> badges = [];
  List<RewardItem> rewards = [];
  List<LeaderboardEntry> leaderboard = [];
  final List<RewardHistoryItem> history = [];

  // ── UI states ─────────────────────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  bool dailyClaimedToday = false;
  bool wheelSpinAvailable = true;

  AppState() {
    ApiClient.instance.onUnauthorized = () => _forceLogout();
    _tryRestoreSession();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _tryRestoreSession() async {
    _setLoading(true);
    try {
      final user = await AuthService.instance.tryRestoreSession();
      if (user != null) {
        _user = user;
        _authStatus = AuthStatus.authenticated;
        await _loadInitialData();
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    errorMessage = null;
    try {
      _user = await AuthService.instance
          .login(LoginRequest(email: email, password: password));
      _authStatus = AuthStatus.authenticated;
      await _loadInitialData();
      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      _authStatus = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    errorMessage = null;
    try {
      _user = await AuthService.instance.register(
          RegisterRequest(username: username, email: email, password: password));
      _authStatus = AuthStatus.authenticated;
      await _loadInitialData();
      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _forceLogout();
  }

  void _forceLogout() {
    _user = null;
    _authStatus = AuthStatus.unauthenticated;
    quests = [];
    badges = [];
    rewards = [];
    leaderboard = [];
    history.clear();
    dailyClaimedToday = false;
    wheelSpinAvailable = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initial data load
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadInitialData() async {
    await Future.wait([
      refreshQuests(),
      refreshAchievements(),
      refreshLeaderboard(),
      refreshRewards(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Quests
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshQuests() async {
    try {
      quests = await QuestService.instance.getQuests();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<bool> claimQuest(QuestModel quest) async {
    if (!quest.isCompleted || quest.claimed) return false;
    try {
      final res =
          await QuestService.instance.completeQuest(int.parse(quest.id));
      quest.claimed = true;
      _user?.coins += res.coinsEarned;
      _user?.xp += res.xpEarned;
      _checkLevelUp();
      history.insert(
        0,
        RewardHistoryItem(
          title: 'Квест выполнен',
          subtitle: quest.title,
          amount: res.xpEarned,
          isCoins: false,
          icon: Icons.emoji_events_rounded,
          color: quest.color,
          date: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Daily reward
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> claimDailyReward() async {
    if (dailyClaimedToday) return false;
    try {
      final res = await AuthService.instance.claimDailyReward();
      dailyClaimedToday = true;
      _user?.coins += res.coins;
      _user?.xp += res.xp;
      _user?.streak = res.streak;
      _checkLevelUp();
      history.insert(
        0,
        RewardHistoryItem(
          title: 'Ежедневный вход',
          subtitle: 'Серия ${res.streak} дней',
          amount: res.coins,
          isCoins: true,
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFFE8002D),
          date: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Wheel
  // ─────────────────────────────────────────────────────────────────────────

  Future<WheelPrize?> spinWheel() async {
    if (!wheelSpinAvailable) return null;
    try {
      final res = await WheelService.instance.spin();
      wheelSpinAvailable = false;
      final prize = WheelPrize(
        label: res.label,
        value: res.value,
        isCoins: res.isCoins,
        color: res.isCoins
            ? const Color(0xFFFFB800)
            : const Color(0xFF2979FF),
      );
      if (prize.isCoins) {
        _user?.coins += prize.value;
      } else {
        _user?.xp += prize.value;
        _checkLevelUp();
      }
      history.insert(
        0,
        RewardHistoryItem(
          title: 'Колесо фортуны',
          subtitle: 'Выигрыш: ${prize.label}',
          amount: prize.value,
          isCoins: prize.isCoins,
          icon: Icons.casino_rounded,
          color: prize.color,
          date: DateTime.now(),
        ),
      );
      notifyListeners();
      return prize;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  /// Apply wheel prize directly (used by WheelScreen local spin)
  void applyWheelPrize(WheelPrize prize) {
    wheelSpinAvailable = false;
    if (prize.isCoins) {
      _user?.coins += prize.value;
    } else {
      _user?.xp += prize.value;
      _checkLevelUp();
    }
    history.insert(
      0,
      RewardHistoryItem(
        title: 'Колесо фортуны',
        subtitle: 'Выигрыш: ${prize.label}',
        amount: prize.value,
        isCoins: prize.isCoins,
        icon: Icons.casino_rounded,
        color: prize.color,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shop
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshRewards() async {
    try {
      rewards = await RewardService.instance.getRewards();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<bool> purchaseReward(RewardItem item) async {
    if ((_user?.coins ?? 0) < item.price) return false;
    try {
      final res =
          await RewardService.instance.purchaseReward(int.parse(item.id));
      _user?.coins = res.newBalance;
      item.purchased = true;
      history.insert(
        0,
        RewardHistoryItem(
          title: 'Покупка в магазине',
          subtitle: item.title,
          amount: -item.price,
          isCoins: true,
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFF9E9E9E),
          date: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  /// Spend coins locally (used by ShopScreen for local items)
  void spendCoins(int amount) {
    if (_user == null) return;
    if (_user!.coins < amount) return;
    _user!.coins -= amount;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Achievements & Leaderboard
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshAchievements() async {
    try {
      badges = await AchievementService.instance.getAllAchievements();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> refreshLeaderboard() async {
    try {
      leaderboard = await LeaderboardService.instance.getLeaderboard();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _checkLevelUp() {
    if (_user == null) return;
    while (_user!.xp >= _user!.level * 500) {
      _user!.level += 1;
    }
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  void _handleError(Object e) {
    errorMessage = _friendlyError(e);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('401') || s.contains('Unauthorized')) {
      return 'Неверный логин или пароль';
    }
    if (s.contains('422')) return 'Проверьте введённые данные';
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'Нет соединения с сервером';
    }
    return 'Что-то пошло не так. Попробуйте ещё раз.';
  }
}