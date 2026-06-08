from aiogram import Router, F
from aiogram.filters import CommandStart, Command, CommandObject
from aiogram.types import Message
from database import SessionLocal
from tabels.user import User
from services.quest_service import QuestService

router = Router()

@router.message(CommandStart())
async def cmd_start(message: Message, command: CommandObject):
    # Если пользователь перешел по ссылке формата t.me/bot?start=ABCD-1234
    # то в command.args будет лежать "ABCD-1234"
    link_code = command.args
    if not link_code:
        await message.answer(
            "Привет!🤖\n\n"
            "Чтобы привязать свой аккаунт и получать уведомления о квестах, "
            "зайди в личный кабинет в приложении и нажми кнопку 'Привязать Telegram'."
        )
        return
    
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_link_code == link_code).first()
        
        # Если пользователь с таким кодом найден
        if user:
            # Записываем его настоящий Telegram ID в базу данных
            user.telegram_id = str(message.chat.id)
            # Очищаем временный код, так как он одноразовый
            user.telegram_link_code = None
            # Сохраняем изменения в PostgreSQL
            db.commit()
            
            await message.answer(
                f"✅ Аккаунт <b>{user.username}</b> успешно привязан к Telegram!", 
                parse_mode="HTML"
            )
        else:
            await message.answer("❌ Ссылка для привязки устарела или недействительна.")

@router.message(Command("profile"))
async def cmd_profile(message: Message):
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_id == str(message.chat.id)).first()
        if not user:
            await message.answer("Твой аккаунт не привязан. Нажми 'Привязать Telegram' в приложении.")
            return
            
        await message.answer(
            f"👤 <b>Профиль:</b> {user.username}\n"
            f"💰 <b>Бонусы:</b> {user.bonus_balance}\n"
            f"🔥 <b>Серия входов:</b> {user.streak_days} дней",
            parse_mode="HTML"
        )

@router.message(Command("quests"))
async def cmd_quests(message: Message):
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_id == str(message.chat.id)).first()
        if not user:
            await message.answer("❌ Твой аккаунт не привязан.")
            return
            
        # Бот напрямую использует тот же сервис, что и FastAPI!
        active_quests = QuestService.get_active_quests(db)
        
        if not active_quests:
            await message.answer("Сейчас нет доступных квестов.")
            return
            
        text = "🎯 <b>Доступные квесты:</b>\n\n"
        for q in active_quests:
            text += f"🔸 <b>{q.title}</b> (+{q.reward_amount} бонусов)\n<i>{q.description}</i>\n\n"
            
        await message.answer(text, parse_mode="HTML")

@router.message(Command("leaderboard"))
async def cmd_leaderboard(message: Message):
    with SessionLocal() as db:
        top_users = db.query(User).order_by(User.bonus_balance.desc()).limit(10).all()
        
        if not top_users:
            await message.answer("Список лидеров пока пуст.")
            return
            
        text = "🏆 <b>ТОП-10 лучших:</b>\n\n"
        for index, player in enumerate(top_users, start=1):
            text += f"{index}. <b>{player.username}</b> — {player.bonus_balance} бонусов\n"
            
        await message.answer(text, parse_mode="HTML")


@router.message(Command("help"))
async def cmd_help(message: Message):
    await message.answer(
        "Доступные команды:\n"
        "/profile - Мой профиль\n"
        "/quests - Доступные квесты\n"
        "/leaderboard - ТОП игроков\n"
    )