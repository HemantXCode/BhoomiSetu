import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "BhoomiSetu - National Land Acquisition & Management System"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "bhoomisetu_super_secret_jwt_key_2026_national_land_platform"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours
    
    APP_ENV: str = "production"  # development, test, production
    
    # PostgreSQL + PostGIS database connection
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/bhoomisetu"
    
    # Storage settings
    UPLOAD_DIR: str = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "storage", "documents")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

settings = Settings()
