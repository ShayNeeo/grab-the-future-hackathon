import logging
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

from store import add_user, remove_user, load_users

logger = logging.getLogger(__name__)

BOT_TOKEN = "8865160272:AAF3zsQ0-fe81_qBU6SImYV4x8L9CiQ27SM"


async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.effective_user or not update.message:
        return
    user = update.effective_user
    add_user(user.id, user.username, user.first_name)
    await update.message.reply_text(
        f"Xin chào {user.first_name or ''}! 👋\n\n"
        "Bạn đã đăng ký nhận cảnh báo lừa đảo từ Justful.\n\n"
        "Khi phát hiện SMS lừa đảo, bạn sẽ nhận thông báo tại đây.\n\n"
        "Gõ /stop để hủy đăng ký.\n"
        "Gõ /status để kiểm tra trạng thái."
    )


async def cmd_stop(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.effective_user or not update.message:
        return
    user = update.effective_user
    if remove_user(user.id):
        await update.message.reply_text("Đã hủy đăng ký. Bạn sẽ không còn nhận cảnh báo.")
    else:
        await update.message.reply_text("Bạn chưa đăng ký.")


async def cmd_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.effective_user or not update.message:
        return
    users = load_users()
    if update.effective_user.id in users:
        await update.message.reply_text(f"Đang đăng ký nhận cảnh báo. ({len(users)} người dùng)")
    else:
        await update.message.reply_text("Chưa đăng ký. Gõ /start để đăng ký.")


def build_bot_app() -> Application:
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("stop", cmd_stop))
    app.add_handler(CommandHandler("status", cmd_status))
    return app
