# Backend
## Instructions
1. Убедись, что все файлы разложены согласно структуре каталогов.
2. Подними базу данных PostgreSQL или переключи DATABASE_URL в config.py на "sqlite:///./sks_quest.db" для автономного запуска.
3. Выполни команду запуска сервера из директории backend/:
uvicorn rest:app --reload
4. Открой интерактивную документацию API Swagger по адресу: http://127.0.0.1:8000/docs.
### Structure

Структура проекта:

```
backend/
│
├── rest.py                 # точка входа FastAPI
├── database.py             # создание engine, SessionLocal, Base
├── config.py
│
├── models/
│   ├── user.py
│   ├── quest.py
│   ├── reward.py
│   ├── achievement.py
│   ├── leaderboard.py
│   └── notification.py
│
├── schemas/
│   ├── user.py
│   ├── quest.py
│   ├── reward.py
│   └── achievement.py
│
├── routers/
│   ├── auth.py
│   ├── users.py
│   ├── quests.py
│   ├── rewards.py
│   ├── achievements.py
│   ├── leaderboard.py
│   ├── wheel.py
│   └── notifications.py
│
├── services/
│   ├── quest_service.py
│   ├── reward_service.py
│   ├── wheel_service.py
│   ├── leaderboard_service.py
│   └── notification_service.py
│
└── requirements.txt
```

## Database
Работа с PostgreSQL
Для создания базы данных PostgreSQL с помощью SQLAlchemy удобнее всего использовать библиотеку SQLAlchemy-Utils, которая добавляет функции проверки и создания базы прямо из Python-скрипта.
Установите пакеты через терминал (потребуется драйвер psycopg2 для связи Python и Postgres):
`pip install sqlalchemy sqlalchemy-utils psycopg2-binary`

## Endpoints (routers)

Роутер	Метод	Путь	Доступ	Описание
---
auth	POST	/auth/register	all	Регистрация

auth	POST	/auth/login	all	JWT-логин

auth	POST	/auth/daily-reward	client	Ежедневный бонус + streak

users	GET	/users/me	client	Профиль текущего пользователя

quests	POST	/quests	marketing	Создать квест

quests	GET	/quests	client	Список доступных квестов

quests	POST	/quests/{id}/complete	client	Выполнить квест

achievements	GET	/achievements	client	Все достижения

achievements	GET	/achievements/my	client	Мои достижения

achievements	POST	/achievements	admin	Создать достижение

rewards	GET	/rewards	client	Список наград магазина

rewards	POST	/rewards	admin	Добавить награду

rewards	POST	/rewards/{id}/purchase	client	Купить награду

leaderboard	GET	/leaderboard	client	Лидерборд текущего месяца

wheel	POST	/wheel/spin	client	Вращение колеса фортуны

notifications	–	–	–	(внутренний сервис, без роутера)
