// ── Request DTOs ─────────────────────────────────────────────────────────────

class RegisterRequest {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

// ── Response DTOs ─────────────────────────────────────────────────────────────

class TokenResponse {
  final String accessToken;
  final String tokenType;

  const TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
      );
}

class DailyRewardResponse {
  final int coins;
  final int xp;
  final int streak;
  final String message;

  const DailyRewardResponse({
    required this.coins,
    required this.xp,
    required this.streak,
    required this.message,
  });

  factory DailyRewardResponse.fromJson(Map<String, dynamic> json) =>
      DailyRewardResponse(
        coins: (json['coins'] as num?)?.toInt() ?? 0,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        message: json['message'] as String? ?? '',
      );
}
