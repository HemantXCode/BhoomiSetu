import sqlite3
import os
import json
from sqlalchemy import create_engine, text, inspect
from app.config.settings import settings
from app.database.session import Base
import app.models # Register all models

def migrate():
    sqlite_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "bhoomisetu_local.db")
    print(f"Reading legacy SQLite from: {sqlite_path}")
    if not os.path.exists(sqlite_path):
        print(f"SQLite file not found at {sqlite_path}, skipping seed migration.")
        return

    sqlite_conn = sqlite3.connect(sqlite_path)
    sqlite_cursor = sqlite_conn.cursor()

    pg_url = settings.DATABASE_URL
    print("Connecting to Supabase PostgreSQL...")
    pg_engine = create_engine(pg_url, pool_pre_ping=True)

    with pg_engine.connect() as conn:
        # Try enabling postgis if supported
        try:
            conn.execute(text("CREATE EXTENSION IF NOT EXISTS postgis;"))
            conn.commit()
            print("PostGIS extension ensured.")
        except Exception as e:
            print("PostGIS extension notice:", e)

    print("Creating all tables in PostgreSQL if not present...")
    Base.metadata.create_all(bind=pg_engine)
    print("All PostgreSQL tables initialized.")

    # Tables in topological order for foreign key constraints
    tables_order = [
        "states",
        "districts",
        "agencies",
        "users",
        "projects",
        "project_milestones",
        "land_parcels",
        "parcel_surveys",
        "notifications",
        "awards",
        "compensation_assessments",
        "compensation_payments",
        "affected_families",
        "displaced_families",
        "rehabilitation_records",
        "resettlement_records",
        "field_tasks",
        "field_visits",
        "field_verifications",
        "documents",
        "sync_events",
        "alerts",
        "audit_logs"
    ]

    inspector = inspect(pg_engine)
    pg_tables = inspector.get_table_names()
    print(f"PostgreSQL tables: {pg_tables}")

    for table in tables_order:
        # Check if table exists in SQLite
        sqlite_cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}';")
        if not sqlite_cursor.fetchone():
            print(f"Table '{table}' not in SQLite, skipping.")
            continue

        with pg_engine.begin() as pg_conn:
            # Check existing count in PG
            pg_count = pg_conn.execute(text(f'SELECT count(*) FROM "{table}";')).fetchone()[0]
            if pg_count > 0:
                print(f"Table '{table}' already contains {pg_count} records in PostgreSQL. Skipping insert.")
                continue

            # Read columns and data from SQLite
            sqlite_cursor.execute(f"PRAGMA table_info({table});")
            col_info = sqlite_cursor.fetchall()
            col_names = [c[1] for c in col_info]

            sqlite_cursor.execute(f"SELECT * FROM {table};")
            rows = sqlite_cursor.fetchall()
            print(f"Migrating {len(rows)} records for '{table}'...")

            if rows:
                cols_str = ", ".join([f'"{c}"' for c in col_names])
                placeholders = ", ".join([f":{c}" for c in col_names])
                insert_sql = text(f'INSERT INTO "{table}" ({cols_str}) VALUES ({placeholders})')

                row_dicts = []
                for row in rows:
                    r_dict = {}
                    for i, col in enumerate(col_names):
                        val = row[i]
                        # Handle boolean conversion
                        if col in ["is_active", "is_acknowledged", "is_read", "dispute_flag"] and val is not None:
                            val = bool(val)
                        # Handle JSON types
                        elif col in ["checklist_data", "payload"] and val is not None:
                            if not isinstance(val, str):
                                val = json.dumps(val)
                        r_dict[col] = val
                    row_dicts.append(r_dict)

                pg_conn.execute(insert_sql, row_dicts)

            # Update serial sequence if integer id exists
            if "id" in col_names:
                try:
                    pg_conn.execute(text(f"SELECT setval(pg_get_serial_sequence('\"{table}\"', 'id'), coalesce(max(id), 1)) FROM \"{table}\";"))
                except Exception:
                    pass

    print("\n--- POSTGRESQL TABLE COUNTS POST-MIGRATION ---")
    with pg_engine.connect() as conn:
        for t in tables_order:
            if t in pg_tables:
                cnt = conn.execute(text(f'SELECT count(*) FROM "{t}";')).fetchone()[0]
                print(f"PostgreSQL '{t}': {cnt} rows")

    sqlite_conn.close()
    print("\nMigration completed successfully!")

if __name__ == "__main__":
    migrate()
