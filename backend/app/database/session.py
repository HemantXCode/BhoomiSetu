from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from app.config.settings import settings

db_url = settings.DATABASE_URL

# Exclusively configure PostgreSQL engine (Zero SQLite runtime fallback)
if "sqlite" in db_url.lower():
    raise RuntimeError(
        "CRITICAL ERROR: SQLite database is decommissioned. BhoomiSetu requires a valid PostgreSQL connection URL."
    )

engine = create_engine(
    db_url,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def check_database_health() -> bool:
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
