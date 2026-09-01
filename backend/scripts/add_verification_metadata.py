from sqlalchemy import text
from app.database.session import engine

def add_columns():
    with engine.connect() as conn:
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_method VARCHAR(50) DEFAULT 'MANUAL_AUTHORITY_REVIEW';"))
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_reference VARCHAR(100);"))
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_notes VARCHAR(255);"))
        conn.commit()
    print("Verification columns successfully ensured in PostgreSQL.")

if __name__ == "__main__":
    add_columns()
