import os
from pydantic_settings import BaseSettings

current_dir = os.path.dirname(os.path.abspath(__file__))
# .env is in the parent directory of 'app' (which is the root of scamshield_api)
env_path = os.path.join(os.path.dirname(current_dir), ".env")

class Settings(BaseSettings):
    gemma_api_key: str
    telegram_bot_url: str = "http://localhost:8086"

    model_config = {"env_file": env_path}


settings = Settings()
