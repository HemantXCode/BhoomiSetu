import sys, os
from sqlalchemy import create_engine, text

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from app.config.settings import settings

def migrate_identity_columns():
    print("Connecting to Supabase PostgreSQL to apply safe schema migration for users identity...")
    engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)

    statements = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS official_id VARCHAR(100);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS official_id_type VARCHAR(50);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS identity_status VARCHAR(20) DEFAULT 'PENDING';",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(150);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS designation VARCHAR(150);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP WITH TIME ZONE;",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_by INTEGER REFERENCES users(id) ON DELETE SET NULL;",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(255);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS suspension_reason VARCHAR(255);",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_demo BOOLEAN DEFAULT FALSE;",
        "CREATE INDEX IF NOT EXISTS idx_users_official_id ON users(official_id);",
        "CREATE INDEX IF NOT EXISTS idx_users_identity_status ON users(identity_status);",
        # Mark the existing 5 seed accounts as is_demo=True and identity_status='VERIFIED' for existing tests
        """
        UPDATE users 
        SET is_demo = TRUE, identity_status = 'VERIFIED'
        WHERE id IN (1, 2, 3, 4, 5);
        """
    ]

    with engine.begin() as conn:
        for stmt in statements:
            conn.execute(text(stmt))
            print(f"Executed: {stmt.strip()[:60]}...")

    print("PostgreSQL users table schema migration completed successfully!")

if __name__ == "__main__":
    migrate_identity_columns()
