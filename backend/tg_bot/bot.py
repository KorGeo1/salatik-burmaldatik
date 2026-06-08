import os
from aiogram import Bot, Dispatcher
from dotenv import load_dotenv

load_dotenv()
BOT_TOKEN = os.getenv("TOKEN", "SIX-SEVEN?")

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()