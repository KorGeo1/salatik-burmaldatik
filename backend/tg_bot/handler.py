from aiogram import Router, F
from aiogram.filters import CommandStart, Command, CommandObject
from aiogram.types import Message, ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove
from database import SessionLocal
from tabels.user import User
from services.quest_service import QuestService

router = Router()

# Главное меню — кнопки которые висят внизу экрана
main_keyboard = ReplyKeyboardMarkup(
    keyboard=[
        [KeyboardButton(text="👤 Профиль"), KeyboardButton(text="🎯 Квесты")],
        [KeyboardButton(text="🏆 Лидерборд"), KeyboardButton(text="📝 Помощь")],
        [KeyboardButton(text="🔗 Привязать аккаунт")],
    ],
    resize_keyboard=True,       # кнопки поменьше, не на полэкрана
    input_field_placeholder="Выбери действие...",
)


async def process_binding(message: Message, link_code: str):
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_link_code == link_code).first()

        if not user:
            await message.answer("❌ Ссылка для привязки устарела или недействительна.")
            return

        existing = db.query(User).filter(
            User.telegram_id == str(message.chat.id)
        ).first()

        if existing and existing.id != user.id:
            await message.answer(
                f"⚠️ Этот Telegram уже привязан к аккаунту <b>{existing.username}</b>.",
                parse_mode="HTML",
            )
            return

        user.telegram_id = str(message.chat.id)
        user.telegram_link_code = None
        db.commit()

        # После привязки сразу показываем меню
        await message.answer(
            f"✅ Аккаунт <b>{user.username}</b> успешно привязан к Telegram!\n\n"
            f"Теперь ты будешь получать уведомления о квестах и наградах. 🎯",
            parse_mode="HTML",
            reply_markup=main_keyboard,
        )


@router.message(CommandStart())
async def cmd_start(message: Message, command: CommandObject):
    link_code = command.args

    if link_code:
        if link_code.startswith("link_"):
            link_code = link_code.replace("link_", "")
        await process_binding(message, link_code)
        return

    await message.answer(
        "Привет! Я официальный бот СКС Квест. 🤖\n\n"
        "Чтобы привязать свой аккаунт и получать уведомления о квестах, "
        "зайди в личный кабинет в приложении и нажми кнопку «Привязать Telegram».",
        reply_markup=main_keyboard,
    )

@router.message(F.text == "📝Link account")
@router.message(Command("link"))
async def cmd_link(message: Message, command: CommandObject):
    link_code = command.args
    if not link_code:
        await message.answer(
            "⚠️ Укажи код после команды, например:\n<code>/link A1B2-C3D4</code>",
            parse_mode="HTML",
        )
        return

    await process_binding(message, link_code)

@router.message(F.text == "🔗 Привязать аккаунт")
async def btn_link(message: Message):
    await message.answer(
        "Чтобы привязать аккаунт, нажми «Привязать Telegram» в приложении — "
        "оно откроет этого бота автоматически.\n\n"
        "Или введи код вручную:\n<code>/link A1B2-C3D4</code>",
        parse_mode="HTML",
    )

# --- Обработчики кнопок (текст совпадает с KeyboardButton) ---

@router.message(F.text == "👤 Профиль")
@router.message(Command("profile"))
async def cmd_profile(message: Message):
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_id == str(message.chat.id)).first()
        if not user:
            await message.answer(
                "❌ Твой аккаунт не привязан. Нажми «Привязать Telegram» в приложении."
            )
            return

        await message.answer(
            f"👤 <b>Профиль:</b> {user.username}\n"
            f"💰 <b>Бонусы:</b> {user.bonus_balance}\n"
            f"🔥 <b>Серия входов:</b> {user.streak_days} дней",
            parse_mode="HTML",
            reply_markup=main_keyboard,
        )


@router.message(F.text == "🎯 Квесты")
@router.message(Command("quests"))
async def cmd_quests(message: Message):
    with SessionLocal() as db:
        user = db.query(User).filter(User.telegram_id == str(message.chat.id)).first()
        if not user:
            await message.answer("❌ Твой аккаунт не привязан.")
            return

        active_quests = QuestService.get_active_quests(db)

        if not active_quests:
            await message.answer("Сейчас нет доступных квестов.")
            return

        text = "🎯 <b>Доступные квесты:</b>\n\n"
        for q in active_quests:
            text += f"🔸 <b>{q.title}</b> (+{q.reward_amount} бонусов)\n<i>{q.description}</i>\n\n"

        await message.answer(text, parse_mode="HTML", reply_markup=main_keyboard)


@router.message(F.text == "🏆 Лидерборд")
@router.message(Command("leaderboard"))
async def cmd_leaderboard(message: Message):
    with SessionLocal() as db:
        top_users = db.query(User).order_by(User.bonus_balance.desc()).limit(10).all()

        if not top_users:
            await message.answer("Список лидеров пока пуст.")
            return

        text = "🏆 <b>ТОП-10 лучших игроков:</b>\n\n"
        for index, player in enumerate(top_users, start=1):
            text += f"{index}. <b>{player.username}</b> — {player.bonus_balance} бонусов\n"

        await message.answer(text, parse_mode="HTML", reply_markup=main_keyboard)


@router.message(F.text == "📝 Помощь")
@router.message(Command("help"))
async def cmd_help(message: Message):
    await message.answer(
        "📝 <b>Доступные команды бота:</b>\n\n"
        "/link <code>КОД</code> — Привязать аккаунт вручную\n"
        "/profile — Посмотреть мой профиль\n"
        "/quests — Список доступных квестов\n"
        "/leaderboard — ТОП-10 игроков проекта\n"
        "/help — Показать эту справку",
        parse_mode="HTML",
        reply_markup=main_keyboard,
    )