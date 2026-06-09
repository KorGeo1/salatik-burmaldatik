import '../models/user_model.dart';

/// DTO that maps the JSON from GET /users/me to the existing [UserModel].
class UserDto {
  final int id;
  final String username;
  final String email;
  final String phone;
  final int xp;
  final int level;
  final int coins;
  final int streak;
  final String league;
  final List<String> badges;
  final DateTime? lastLoginDate;

  const UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.phone = '',
    required this.xp,
    required this.level,
    required this.coins,
    required this.streak,
    required this.league,
    required this.badges,
    this.lastLoginDate,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        coins: (json['coins'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        league: json['league'] as String? ?? 'Bronze',
        badges: (json['badges'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        lastLoginDate: json['last_login_date'] != null
            ? DateTime.tryParse(json['last_login_date'] as String)
            : null,
      );

  /// Convert to the existing [UserModel] used throughout the UI.
  UserModel toModel() => UserModel(
        id: id.toString(),
        name: username,
        phone: phone,
        xp: xp,
        level: level,
        coins: coins,
        streak: streak,
        lastLoginDate: lastLoginDate,
        badges: badges,
        league: league,
      );
}
