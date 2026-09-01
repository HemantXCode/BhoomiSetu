from app.database.session import SessionLocal
from app.models.user import User
from app.utils.hash import hash_password

def add_operational_authorities():
    db = SessionLocal()
    try:
        authorities = [
            {
                "name": "Competent Authority Land Acquisition (CALA Pune)",
                "email": "cala.pune@maharashtra.gov.in",
                "role": "DISTRICT_AUTHORITY",
                "official_id": "GOV-MH-CALA-001",
                "official_id_type": "STATE_REVENUE_EMP_ID",
                "department": "Office of the District Collectorate, Pune",
                "designation": "Competent Authority & Land Acquisition Officer",
                "phone": "+91-20-26123456",
                "state_id": 1,
                "district_id": 1,
                "is_demo": False,
                "is_active": True,
                "identity_status": "VERIFIED",
                "verification_method": "MANUAL_AUTHORITY_REVIEW"
            },
            {
                "name": "National Land Portal Administrator (MoRTH/NHAI)",
                "email": "nodal.nhai@morth.gov.in",
                "role": "CENTRAL_MINISTRY",
                "official_id": "GOV-IND-NHAI-001",
                "official_id_type": "MINISTRY_OFFICIAL_ID",
                "department": "Ministry of Road Transport and Highways",
                "designation": "Joint Secretary & National Nodal Officer",
                "phone": "+91-11-23717731",
                "is_demo": False,
                "is_active": True,
                "identity_status": "VERIFIED",
                "verification_method": "MANUAL_AUTHORITY_REVIEW"
            },
            {
                "name": "Principal Secretary (Revenue & Forest Dept)",
                "email": "secretary.revenue@maharashtra.gov.in",
                "role": "STATE_GOVERNMENT",
                "official_id": "GOV-MH-REV-001",
                "official_id_type": "STATE_REVENUE_EMP_ID",
                "department": "Revenue and Forest Department, Mantralaya",
                "designation": "Principal Secretary (Land Acquisition)",
                "phone": "+91-22-22025555",
                "state_id": 1,
                "is_demo": False,
                "is_active": True,
                "identity_status": "VERIFIED",
                "verification_method": "MANUAL_AUTHORITY_REVIEW"
            }
        ]

        pwd_hash = hash_password("OperationalPass@2026")

        for auth in authorities:
            existing = db.query(User).filter(User.email == auth["email"]).first()
            if not existing:
                new_u = User(
                    name=auth["name"],
                    email=auth["email"],
                    password_hash=pwd_hash,
                    role=auth["role"],
                    official_id=auth["official_id"],
                    official_id_type=auth["official_id_type"],
                    department=auth["department"],
                    designation=auth["designation"],
                    phone=auth["phone"],
                    state_id=auth.get("state_id"),
                    district_id=auth.get("district_id"),
                    is_demo=False,
                    is_active=True,
                    identity_status="VERIFIED",
                    verification_method="MANUAL_AUTHORITY_REVIEW"
                )
                db.add(new_u)
                print(f"Added operational authority: {auth['email']} ({auth['role']})")
            else:
                existing.is_active = True
                existing.is_demo = False
                existing.identity_status = "VERIFIED"
                print(f"Operational authority already exists: {auth['email']}")

        db.commit()
        print("Operational authorities successfully active in PostgreSQL.")
    finally:
        db.close()

if __name__ == "__main__":
    add_operational_authorities()
