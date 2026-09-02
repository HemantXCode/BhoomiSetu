from sqlalchemy.orm import Session
from datetime import date, datetime, timezone
from app.database.session import SessionLocal, engine, Base
from app.models.user import State, District, Agency, User
from app.models.project import Project, ProjectMilestone
from app.models.parcel import LandParcel
from app.models.compensation import Award, Notification
from app.models.field import FieldTask
from app.utils.hash import hash_password

def seed_database():
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Metadata create_all notice: {e}")

    db: Session = SessionLocal()

    try:
        # 1. STATES
        if db.query(State).count() == 0:
            states_data = [
                State(id=1, name="Maharashtra", code="MH"),
                State(id=2, name="Gujarat", code="GJ"),
                State(id=3, name="Karnataka", code="KA"),
                State(id=4, name="Rajasthan", code="RJ"),
                State(id=5, name="Uttar Pradesh", code="UP"),
                State(id=6, name="Tamil Nadu", code="TN")
            ]
            db.add_all(states_data)
            db.commit()

        # 2. DISTRICTS
        if db.query(District).count() == 0:
            districts_data = [
                District(id=1, state_id=1, name="Pune", code="PUN"),
                District(id=2, state_id=1, name="Nagpur", code="NGP"),
                District(id=3, state_id=1, name="Thane", code="THN"),
                District(id=4, state_id=1, name="Nashik", code="NSK"),
                District(id=5, state_id=2, name="Ahmedabad", code="AMD"),
                District(id=6, state_id=2, name="Surat", code="SRT"),
                District(id=7, state_id=2, name="Vadodara", code="BRD"),
                District(id=8, state_id=3, name="Bengaluru Urban", code="BLR"),
                District(id=9, state_id=3, name="Mysuru", code="MYS"),
                District(id=10, state_id=4, name="Jaipur", code="JPR"),
                District(id=11, state_id=5, name="Lucknow", code="LKO"),
                District(id=12, state_id=6, name="Chennai", code="CHN")
            ]
            db.add_all(districts_data)
            db.commit()

        # 3. AGENCIES
        if db.query(Agency).count() == 0:
            agencies_data = [
                Agency(id=1, name="National Highways Authority of India (NHAI)", type="CENTRAL_PSU", state_id=None),
                Agency(id=2, name="Dedicated Freight Corridor Corporation of India (DFCCIL)", type="CENTRAL_PSU", state_id=None),
                Agency(id=3, name="Maharashtra State Road Development Corporation (MSRDC)", type="STATE_PSU", state_id=1),
                Agency(id=4, name="Gujarat Industrial Development Corporation (GIDC)", type="STATE_PSU", state_id=2),
                Agency(id=5, name="Bangalore Metro Rail Corporation Limited (BMRCL)", type="STATE_JOINT_PSU", state_id=3)
            ]
            db.add_all(agencies_data)
            db.commit()

        # 4. USERS (Password: Demo@12345)
        if db.query(User).count() == 0:
            demo_password_hash = hash_password("Demo@12345")
            users_data = [
                User(id=1, name="Dr. Rajesh Verma (Joint Secretary)", email="central.demo@example.com", password_hash=demo_password_hash, role="CENTRAL_MINISTRY", state_id=None, district_id=None, agency_id=None),
                User(id=2, name="Shri Anand Kulkarni (Principal Secretary, Revenue)", email="state.demo@example.com", password_hash=demo_password_hash, role="STATE_GOVERNMENT", state_id=1, district_id=None, agency_id=None),
                User(id=3, name="Smt. Sujata Deshmukh (District Collector & LAO)", email="district.demo@example.com", password_hash=demo_password_hash, role="DISTRICT_AUTHORITY", state_id=1, district_id=1, agency_id=None),
                User(id=4, name="Er. Vikram Malhotra (Chief Project Manager, NHAI)", email="agency.demo@example.com", password_hash=demo_password_hash, role="PROJECT_AGENCY", state_id=None, district_id=None, agency_id=1),
                User(id=5, name="Suresh Patil (Sub-Divisional Field Officer)", email="field.demo@example.com", password_hash=demo_password_hash, role="FIELD_OFFICER", state_id=1, district_id=1, agency_id=1)
            ]
            db.add_all(users_data)
            db.commit()

        # 5. PROJECTS
        if db.query(Project).count() == 0:
            projects_data = [
                Project(id=1, project_name="Pune Ring Road Express Corridor (Phase-I)", description="Acquisition of bypass land corridor spanning Haveli and Mulshi talukas.", agency_id=1, state_id=1, district_id=1, proposed_area=485.50, status="COMPENSATION_IN_PROGRESS", start_date=date(2025, 1, 15), expected_end_date=date(2026, 12, 31), created_by=4),
                Project(id=2, project_name="Pune-Nashik Semi High-Speed Rail Corridor", description="Linear greenfield land acquisition across 12 villages.", agency_id=3, state_id=1, district_id=1, proposed_area=310.20, status="NOTIFICATION_IN_PROGRESS", start_date=date(2025, 3, 1), expected_end_date=date(2027, 6, 30), created_by=4),
                Project(id=3, project_name="Nagpur Metro Rail Phase-II Extension", description="Urban and peri-urban land parcels for terminal expansion.", agency_id=1, state_id=1, district_id=2, proposed_area=142.80, status="SURVEY_IN_PROGRESS", start_date=date(2025, 2, 10), expected_end_date=date(2026, 10, 15), created_by=4),
                Project(id=4, project_name="Thane-Borivali Twin Tunnel Approach Expressway", description="Forest and revenue land acquisition for western bypass.", agency_id=3, state_id=1, district_id=3, proposed_area=95.40, status="DELAYED", start_date=date(2024, 8, 1), expected_end_date=date(2026, 3, 31), created_by=4),
                Project(id=5, project_name="Ahmedabad-Dholera SIR Expressway", description="Greenfield expressway connectivity to Dholera Industrial Hub.", agency_id=1, state_id=2, district_id=5, proposed_area=620.00, status="POSSESSION_IN_PROGRESS", start_date=date(2024, 11, 1), expected_end_date=date(2026, 8, 30), created_by=4)
            ]
            db.add_all(projects_data)
            db.commit()

        # 6. LAND PARCELS
        if db.query(LandParcel).count() == 0:
            parcels_data = [
                LandParcel(id=1, project_id=1, ulpin="ULPIN-MH-PUN-001", survey_number="Gat No. 142/3A", village="Haveli", state_id=1, district_id=1, area_hectares=12.50, classification="AGRICULTURAL", owner_name="Ramesh Chandra Patil", status="IDENTIFIED"),
                LandParcel(id=2, project_id=1, ulpin="ULPIN-MH-PUN-002", survey_number="Gat No. 89/1B", village="Mulshi", state_id=1, district_id=1, area_hectares=8.20, classification="AGRICULTURAL", owner_name="Sunita Deshmukh", status="SURVEYED"),
                LandParcel(id=3, project_id=2, ulpin="ULPIN-MH-PUN-003", survey_number="Survey No. 45/2", village="Bhosari", state_id=1, district_id=1, area_hectares=15.80, classification="COMMERCIAL", owner_name="Mahesh Pawar", status="NOTIFICATION_ISSUED")
            ]
            db.add_all(parcels_data)
            db.commit()

        # 7. FIELD TASKS
        if db.query(FieldTask).count() == 0:
            tasks_data = [
                FieldTask(id=101, project_id=1, parcel_id=1, assigned_to_user_id=5, task_type="Ground Boundary Delineation", priority="HIGH", due_date=datetime.now(timezone.utc), status="PENDING"),
                FieldTask(id=102, project_id=1, parcel_id=2, assigned_to_user_id=5, task_type="Structure & Tree Enumeration", priority="MEDIUM", due_date=datetime.now(timezone.utc), status="IN_PROGRESS"),
                FieldTask(id=103, project_id=2, parcel_id=3, assigned_to_user_id=5, task_type="Land Title Document Verification", priority="NORMAL", due_date=datetime.now(timezone.utc), status="PENDING")
            ]
            db.add_all(tasks_data)
            db.commit()

        # 8. AWARDS & NOTIFICATIONS
        if db.query(Award).count() == 0:
            db.add(Award(id=1, project_id=1, award_number="AWD-MH-PUN-2026-01", total_compensation_cr=45.80, award_date=date(2026, 4, 15), status="DECLARED"))
        if db.query(Notification).count() == 0:
            db.add(Notification(id=1, project_id=1, notification_type="SECTION_11", gazette_number="MH-GAZ-2026-889", issue_date=date(2026, 2, 10), document_url="/storage/gazette_sec11.pdf"))
        db.commit()

        print("Database seed successful!")
        db.commit()

        print("Database seed successful!")

    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
