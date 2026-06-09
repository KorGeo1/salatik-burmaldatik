# SKS Quest — Flutter API Integration

## Структура новых файлов

```
lib/
├── api/
│   ├── api_client.dart       ← HTTP-клиент с JWT, 401-обработкой
│   ├── api_config.dart       ← Все URL в одном месте
│   ├── api_exception.dart    ← Типизированные ошибки
│   └── token_storage.dart    ← Персистентное хранение JWT
├── dto/
│   ├── auth_dto.dart         ← Register/Login request + TokenResponse
│   ├── user_dto.dart         ← GET /users/me → UserModel
│   ├── quest_dto.dart        ← GET /quests + CompleteQuestResponse
│   └── achievement_reward_dto.dart ← Achievements, Rewards, Leaderboard, Wheel
├── models/
│   └── reward_item.dart      ← Модель товара магазина (новая)
├── services/
│   └── services.dart         ← AuthService, UserService, QuestService,
│                                AchievementService, RewardService,
│                                LeaderboardService, WheelService
├── state/
│   └── app_state.dart        ← Полностью переписан: AuthStatus + API вызовы
├── screens/
│   ├── login_screen.dart     ← Вкладки Login + Register, реальный API
│   ├── quests_screen.dart    ← Pull-to-refresh, реальный claimQuest
│   └── profile_screen.dart   ← Logout через AppState.logout()
├── main.dart                 ← _AuthGate: роутинг по AuthStatus
└── gamify_api.dart           ← Barrel export

pubspec.yaml                  ← Добавлены: http ^1.2.2, shared_preferences ^2.3.2
```

---

## Установка

### 1. Добавить зависимости

```bash
flutter pub add http shared_preferences
# или просто:
flutter pub get   # pubspec.yaml уже обновлён
```

### 2. Скопировать файлы в проект

| Источник | Назначение в проекте |
|---|---|
| `lib/api/*` | `lib/api/` (новая папка) |
| `lib/dto/*` | `lib/dto/` (новая папка) |
| `lib/services/services.dart` | `lib/services/` (новая папка) |
| `lib/models/reward_item.dart` | `lib/models/reward_item.dart` |
| `lib/state/app_state.dart` | **заменить** `lib/state/app_state.dart` |
| `lib/main.dart` | **заменить** `lib/main.dart` |
| `lib/screens/login_screen.dart` | **заменить** `lib/screens/login_screen.dart` |
| `lib/screens/quests_screen.dart` | **заменить** `lib/screens/quests_screen.dart` |
| `lib/screens/profile_screen.dart` | **заменить** `lib/screens/profile_screen.dart` |

---

## Как это работает

### Auth Flow

```
App start
  └─> AppState() → _tryRestoreSession()
        ├─ token в SharedPreferences?
        │     └─ YES → GET /users/me
        │               ├─ 200 → AuthStatus.authenticated → MainShell
        │               └─ 401 → clear token → AuthStatus.unauthenticated → LoginScreen
        └─ NO  → AuthStatus.unauthenticated → LoginScreen

LoginScreen
  ├─ Tab "Вход"      → AppState.login(email, password)
  └─ Tab "Регистрация" → AppState.register(username, email, password)
        └─ оба: POST /auth/login → сохранить JWT → GET /users/me
                 → AuthStatus.authenticated → _AuthGate → MainShell (автоматически)

ProfileScreen "Выйти"
  └─ AppState.logout() → clear token → AuthStatus.unauthenticated → LoginScreen
```

### JWT

`ApiClient` автоматически добавляет заголовок ко всем защищённым запросам:
```
Authorization: Bearer <token>
```

При получении **401** от любого эндпоинта вызывается `onUnauthorized`,
что вызывает `AppState._forceLogout()` и перенаправляет на LoginScreen.

### Смена URL (dev → prod)

В `lib/api/api_config.dart`:
```dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://127.0.0.1:8000', // ← поменять для прода
);
```

Или при сборке:
```bash
flutter run --dart-define=API_URL=https://api.yourapp.com
flutter build apk --dart-define=API_URL=https://api.yourapp.com
```

---

## Обновление остальных экранов

### DailyCheckIn widget
```dart
// Заменить вызов state.claimDaily(coins, xp) на:
final ok = await context.read<AppState>().claimDailyReward();
```

### WheelScreen
```dart
// Заменить state.applyWheelPrize(prize) на:
final prize = await context.read<AppState>().spinWheel();
if (prize != null) { /* показать анимацию с prize.label */ }
```

### ShopScreen
```dart
// Загрузка товаров (уже в _loadInitialData):
final rewards = context.watch<AppState>().rewards; // List<RewardItem>

// Покупка:
final ok = await context.read<AppState>().purchaseReward(item);
```

### LeaderboardScreen
```dart
final leaderboard = context.watch<AppState>().leaderboard; // List<LeaderboardEntry>
// Структура LeaderboardEntry не изменилась — экран работает без правок
```

### AchievementsScreen / BadgesScreen
```dart
final badges = context.watch<AppState>().badges; // List<BadgeModel>
// BadgeModel не изменился — экран работает без правок
```

---

## Обработка ошибок в UI

```dart
// Универсальный паттерн для любого экрана:
ElevatedButton(
  onPressed: () async {
    final ok = await context.read<AppState>().someAction();
    if (!mounted) return;
    if (!ok) {
      final err = context.read<AppState>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Ошибка')),
      );
      context.read<AppState>().clearError();
    }
  },
)
```

---

## Требования к бэкенду

Все эндпоинты уже поддерживаются согласно документации.  
Для корректной работы убедись, что ответы соответствуют схемам:

| Endpoint | Ожидаемые поля |
|---|---|
| `GET /users/me` | `id, username, email, xp, level, coins, streak, league, badges[]` |
| `GET /quests` | `id, title, description, xp_reward, coin_reward, type, current, target, claimed` |
| `POST /quests/{id}/complete` | `xp_earned, coins_earned, message` |
| `POST /auth/daily-reward` | `coins, xp, streak, message` |
| `POST /wheel/spin` | `label, value, is_coins` |
| `GET /rewards` | `id, title, description, price, image_url, available` |
| `POST /rewards/{id}/purchase` | `new_balance, message` |
| `GET /leaderboard` | `rank, username, xp, league, is_current_user` |
| `GET /achievements` | `id, slug, title, description, xp_required, unlocked` |
