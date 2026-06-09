import base64
import datetime
import hashlib
import hmac
import json
import time
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import select
from database import get_db
from config import settings
from tabels.user import User
from schemas.user import UserCreate, UserResponse, TokenResponse, UserLogin

router = APIRouter(prefix="/auth", tags=["Authentication"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


# Утилиты безопасности
def get_password_hash(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return get_password_hash(plain_password) == hashed_password


def create_access_token(data: dict) -> str:
    payload = data.copy()
    expire = time.time() + (settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60)
    payload.update({"exp": expire})

    header = {"alg": "HS256", "typ": "JWT"}
    header_bytes = json.dumps(header).encode()
    payload_bytes = json.dumps(payload).encode()

    header_b64 = (
        base64.urlsafe_b64encode(header_bytes).decode().replace("=", "")
    )
    payload_b64 = (
        base64.urlsafe_b64encode(payload_bytes).decode().replace("=", "")
    )

    signing_input = f"{header_b64}.{payload_b64}".encode()
    signature = hmac.new(
        settings.SECRET_KEY.encode(), signing_input, hashlib.sha256
    ).digest()
    signature_b64 = (
        base64.urlsafe_b64encode(signature).decode().replace("=", "")
    )

    return f"{header_b64}.{payload_b64}.{signature_b64}"


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Не удалось валидировать токен доступа.",
    )
    try:
        parts = token.split(".")
        if len(parts) != 3:
            raise credentials_exception
        header_b64, payload_b64, sig_b64 = parts

        signing_input = f"{header_b64}.{payload_b64}".encode()
        expected_sig = hmac.new(
            settings.SECRET_KEY.encode(), signing_input, hashlib.sha256
        ).digest()
        expected_sig_b64 = (
            base64.urlsafe_b64encode(expected_sig).decode().replace("=", "")
        )

        if not hmac.compare_digest(sig_b64, expected_sig_b64):
            raise credentials_exception

        rem = len(payload_b64) % 4
        if rem:
            payload_b64 += "=" * (4 - rem)
        payload_data = json.loads(
            base64.urlsafe_b64decode(payload_b64.encode()).decode()
        )

        if payload_data.get("exp", 0) < time.time():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Срок действия токена истек",
            )

        username: str = payload_data.get("sub")
        if username is None:
            raise credentials_exception
    except Exception:
        raise credentials_exception

    user = db.scalar(select(User).where(User.username == username))
    if user is None:
        raise credentials_exception
    return user


def require_role(allowed_roles: list[str]):

    def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Недостаточно прав для выполнения операции.",
            )
        return current_user

    return role_checker


@router.post("/register", response_model=UserResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = db.scalar(
        select(User).where(
            (User.username == user_in.username) | (User.email == user_in.email)
        )
    )
    if existing:
        raise HTTPException(status_code=400, detail="Пользователь уже существует")

    db_user = User(
        username=user_in.username,
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        telegram_id=user_in.telegram_id,
        role="client",
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/login", response_model=TokenResponse)
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.username == user_in.username))
    if not user or not verify_password(user_in.password, user.password_hash):
        raise HTTPException(
            status_code=400, detail="Неверное имя пользователя или пароль"
        )

    token = create_access_token(data={"sub": user.username, "role": user.role})
    return {"access_token": token, "token_type": "bearer"}

@router.post("/link-telegram", tags=["Authentication"])
def link_telegram(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    raw = uuid.uuid4().hex.upper()
    link_code = f"{raw[:4]}-{raw[4:8]}"
 
    current_user.telegram_link_code = link_code
    db.commit()
 
    return {"link_code": link_code}