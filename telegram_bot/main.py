import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from pydantic import BaseModel

from bot import build_bot_app, BOT_TOKEN
from store import get_all_chat_ids

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global reference to the telegram bot application
bot_app = None
bot_task = None


class NotifyRequest(BaseModel):
    sender: str
    body: str
    risk_level: str
    explanation: str


def _format_message(req: NotifyRequest) -> str:
    risk_emoji = {
        "medium": "🟡",
        "high": "🔴",
        "critical": "🔴",
    }.get(req.risk_level, "⚪")

    body_preview = req.body[:300] + ("..." if len(req.body) > 300 else "")

    return (
        f"⚠️ CẢNH BÁO LỪA ĐẢO\n\n"
        f"📱 Từ: {req.sender}\n"
        f"📝 Nội dung: \"{body_preview}\"\n"
        f"{risk_emoji} Mức độ: {req.risk_level.upper()}\n"
        f"🤖 Phân tích: {req.explanation}\n\n"
        f"— Justful Scam Shield"
    )


async def _run_bot():
    global bot_app
    bot_app = build_bot_app()
    await bot_app.initialize()
    await bot_app.start()
    await bot_app.updater.start_polling(drop_pending_updates=True)
    logger.info("Telegram bot polling started")
    # Keep running until cancelled
    try:
        while True:
            await asyncio.sleep(3600)
    except asyncio.CancelledError:
        pass
    finally:
        await bot_app.updater.stop()
        await bot_app.stop()
        await bot_app.shutdown()


@asynccontextmanager
async def lifespan(app: FastAPI):
    global bot_task
    bot_task = asyncio.create_task(_run_bot())
    yield
    bot_task.cancel()
    try:
        await bot_task
    except asyncio.CancelledError:
        pass


app = FastAPI(title="Justful Telegram Bot", version="1.0.0", lifespan=lifespan)


@app.get("/health")
async def health():
    users = get_all_chat_ids()
    return {"status": "ok", "registered_users": len(users)}


@app.post("/notify")
async def notify(req: NotifyRequest):
    chat_ids = get_all_chat_ids()
    if not chat_ids:
        logger.warning("No registered users — skipping notification")
        return {"sent": 0, "failed": 0, "reason": "no_users"}

    text = _format_message(req)
    sent = 0
    failed = 0

    for chat_id in chat_ids:
        try:
            await bot_app.bot.send_message(chat_id=chat_id, text=text)
            sent += 1
            logger.info("Sent alert to %s", chat_id)
        except Exception as e:
            failed += 1
            logger.error("Failed to send to %s: %s", chat_id, e)

    logger.info("Notification complete: sent=%d failed=%d", sent, failed)
    return {"sent": sent, "failed": failed}
