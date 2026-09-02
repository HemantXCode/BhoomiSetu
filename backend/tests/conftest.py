import os
import sys
import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

os.environ["APP_ENV"] = "test"
from app.config.settings import settings
settings.APP_ENV = "test"

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import date, datetime, timezone

from app.main import app
from app.database.session import Base, get_db
from app.models.user import State, District, Agency, User
from app.models.project import Project
from app.models.parcel import LandParcel
from app.models.compensation import Award, Notification
from app.models.field import FieldTask
from app.utils.hash import hash_password

from app.database.session import Base, engine, SessionLocal, get_db

TestingSessionLocal = SessionLocal

def seed_test_db(db):
    if db.query(User).first():
        return

    states_data = [
        State(id=1, name="Maharashtra", code="MH"),
        State(id=2, name="Gujarat", code="GJ")
    ]
    db.add_all(states_data)
    db.commit()

    districts_data = [
        District(id=1, state_id=1, name="Pune", code="PUN"),
        District(id=2, state_id=1, name="Nagpur", code="NGP")
    ]
    db.add_all(districts_data)
    db.commit()

    agencies_data = [
        Agency(id=1, name="National Highways Authority of India (NHAI)", type="CENTRAL_PSU", state_id=None),
        Agency(id=2, name="Dedicated Freight Corridor Corporation of India (DFCCIL)", type="CENTRAL_PSU", state_id=None)
    ]
    db.add_all(agencies_data)
    db.commit()

    pwd_hash = hash_password("Demo@12345")
    users_data = [
        User(id=1, name="Dr. Rajesh Verma", email="central.demo@example.com", password_hash=pwd_hash, role="CENTRAL_MINISTRY", state_id=None, district_id=None, agency_id=None),
        User(id=2, name="Shri Anand Kulkarni", email="state.demo@example.com", password_hash=pwd_hash, role="STATE_GOVERNMENT", state_id=1, district_id=None, agency_id=None),
        User(id=3, name="Smt. Sujata Deshmukh", email="district.demo@example.com", password_hash=pwd_hash, role="DISTRICT_AUTHORITY", state_id=1, district_id=1, agency_id=None),
        User(id=4, name="Er. Vikram Malhotra", email="agency.demo@example.com", password_hash=pwd_hash, role="PROJECT_AGENCY", state_id=None, district_id=None, agency_id=1),
        User(id=5, name="Suresh Patil", email="field.demo@example.com", password_hash=pwd_hash, role="FIELD_OFFICER", state_id=1, district_id=1, agency_id=1)
    ]
    db.add_all(users_data)
    db.commit()

    projects_data = [
        Project(id=1, project_name="Pune Ring Road Express Corridor (Phase-I)", description="Bypass project", agency_id=1, state_id=1, district_id=1, proposed_area=485.50, status="COMPENSATION_IN_PROGRESS", start_date=date(2025, 1, 15), expected_end_date=date(2026, 12, 31), created_by=4)
    ]
    db.add_all(projects_data)
    db.commit()

    parcels_data = [
        LandParcel(id=1, project_id=1, ulpin="ULPIN-MH-PUN-001", survey_number="Gat No. 142/3A", village="Haveli", state_id=1, district_id=1, area_hectares=12.50, classification="AGRICULTURAL", owner_name="Ramesh Chandra Patil", status="IDENTIFIED"),
        LandParcel(id=2, project_id=1, ulpin="ULPIN-MH-PUN-002", survey_number="Gat No. 89/1B", village="Mulshi", state_id=1, district_id=1, area_hectares=8.20, classification="AGRICULTURAL", owner_name="Sunita Deshmukh", status="SURVEYED")
    ]
    db.add_all(parcels_data)
    db.commit()

    tasks_data = [
        FieldTask(id=101, project_id=1, parcel_id=1, assigned_to_user_id=5, task_type="Ground Boundary Delineation", priority="HIGH", due_date=datetime.now(timezone.utc), status="PENDING"),
        FieldTask(id=102, project_id=1, parcel_id=2, assigned_to_user_id=5, task_type="Structure & Tree Enumeration", priority="MEDIUM", due_date=datetime.now(timezone.utc), status="IN_PROGRESS")
    ]
    db.add_all(tasks_data)
    db.commit()

@pytest.fixture(scope="session", autouse=True)
def setup_test_database():
    try:
        Base.metadata.create_all(bind=engine)
    except Exception:
        pass
    db = TestingSessionLocal()
    seed_test_db(db)
    db.close()
    yield

@pytest.fixture
def db_session():
    db = TestingSessionLocal()
    yield db
    db.close()

@pytest.fixture
def client(db_session):
    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
