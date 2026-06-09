import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/token_storage.dart';
import '../dto/auth_dto.dart';
import '../dto/user_dto.dart';
import '../dto/quest_dto.dart';
import '../dto/achievement_reward_dto.dart';
import '../models/user_model.dart';
import '../models/quest_model.dart';
import '../models/badge_model.dart';
import '../models/reward_item.dart';
import '../models/reward_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _client = ApiClient.instance;
  final _storage = TokenStorage.instance;

  /// Register and immediately log in (saves token).
  Future<UserModel> register(RegisterRequest req) async {
    await _client.post(ApiConfig.register, body: req.toJson());
    // Auto-login after registration
    return login(LoginRequest(email: req.email, password: req.password));
  }

  /// Login, persist token, return user profile.
  Future<UserModel> login(LoginRequest req) async {
    final data = await _client.post(ApiConfig.login, body: req.toJson());
    final token = TokenResponse.fromJson(data as Map<String, dynamic>);
    _client.setToken(token.accessToken);
    await _storage.save(token.accessToken);
    return UserService.instance.getMe();
  }

  /// Restore session from stored token. Returns null if invalid/expired.
  Future<UserModel?> tryRestoreSession() async {
    final token = await _storage.load();
    if (token == null || token.isEmpty) return null;
    _client.setToken(token);
    try {
      return await UserService.instance.getMe();
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    _client.clearToken();
    await _storage.clear();
  }

  Future<DailyRewardResponse> claimDailyReward() async {
    final data = await _client.post(ApiConfig.dailyReward);
    return DailyRewardResponse.fromJson(data as Map<String, dynamic>);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserService
// ─────────────────────────────────────────────────────────────────────────────

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final _client = ApiClient.instance;

  Future<UserModel> getMe() async {
    final data = await _client.get(ApiConfig.me);
    return UserDto.fromJson(data as Map<String, dynamic>).toModel();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QuestService
// ─────────────────────────────────────────────────────────────────────────────

class QuestService {
  QuestService._();
  static final QuestService instance = QuestService._();

  final _client = ApiClient.instance;

  Future<List<QuestModel>> getQuests() async {
    final data = await _client.get(ApiConfig.quests);
    return (data as List<dynamic>)
        .map((e) => QuestDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }

  Future<CompleteQuestResponse> completeQuest(int id) async {
    final data = await _client.post(ApiConfig.questComplete(id));
    return CompleteQuestResponse.fromJson(data as Map<String, dynamic>);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AchievementService
// ─────────────────────────────────────────────────────────────────────────────

class AchievementService {
  AchievementService._();
  static final AchievementService instance = AchievementService._();

  final _client = ApiClient.instance;

  Future<List<BadgeModel>> getAllAchievements() async {
    final data = await _client.get(ApiConfig.achievements);
    return (data as List<dynamic>)
        .map((e) =>
            AchievementDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }

  Future<List<BadgeModel>> getMyAchievements() async {
    final data = await _client.get(ApiConfig.myAchievements);
    return (data as List<dynamic>)
        .map((e) =>
            AchievementDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RewardService
// ─────────────────────────────────────────────────────────────────────────────

class RewardService {
  RewardService._();
  static final RewardService instance = RewardService._();

  final _client = ApiClient.instance;

  Future<List<RewardItem>> getRewards() async {
    final data = await _client.get(ApiConfig.rewards);
    return (data as List<dynamic>)
        .map((e) => RewardDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }

  Future<PurchaseResponse> purchaseReward(int id) async {
    final data = await _client.post(ApiConfig.rewardPurchase(id));
    return PurchaseResponse.fromJson(data as Map<String, dynamic>);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardService
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  final _client = ApiClient.instance;

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final data = await _client.get(ApiConfig.leaderboard);
    return (data as List<dynamic>)
        .map((e) =>
            LeaderboardEntryDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WheelService
// ─────────────────────────────────────────────────────────────────────────────

class WheelService {
  WheelService._();
  static final WheelService instance = WheelService._();

  final _client = ApiClient.instance;

  Future<WheelSpinResponse> spin() async {
    final data = await _client.post(ApiConfig.wheelSpin);
    return WheelSpinResponse.fromJson(data as Map<String, dynamic>);
  }
}
