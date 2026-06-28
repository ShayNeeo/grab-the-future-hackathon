import os
import json
import logging
from pathlib import Path

DATA_DIR = Path(__file__).parent / "data"
USERS_FILE = DATA_DIR / "registered_users.json"

logger = logging.getLogger(__name__)


def _ensure_data_dir():
    DATA_DIR.mkdir(exist_ok=True)


def load_users() -> dict[int, dict]:
    _ensure_data_dir()
    if not USERS_FILE.exists():
        return {}
    try:
        with open(USERS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            return {int(k): v for k, v in data.items()}
    except (json.JSONDecodeError, ValueError):
        return {}


def save_users(users: dict[int, dict]):
    _ensure_data_dir()
    with open(USERS_FILE, "w", encoding="utf-8") as f:
        json.dump({str(k): v for k, v in users.items()}, f, ensure_ascii=False, indent=2)


def add_user(chat_id: int, username: str | None, first_name: str | None):
    users = load_users()
    users[chat_id] = {
        "username": username,
        "first_name": first_name,
        "registered_at": __import__("datetime").datetime.now().isoformat(),
    }
    save_users(users)
    logger.info("Registered user %s (%s)", chat_id, first_name or username)


def remove_user(chat_id: int):
    users = load_users()
    if chat_id in users:
        del users[chat_id]
        save_users(users)
        logger.info("Unregistered user %s", chat_id)
        return True
    return False


def get_all_chat_ids() -> list[int]:
    return list(load_users().keys())
