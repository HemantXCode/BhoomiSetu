from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone

from app.models.user import User, State, District, Agency
from app.utils.hash import hash_password
from app.utils.identity_util import mask_official_id
from app.services.audit_service import log_audit_event
from app.config.settings import settings

VALID_ROLES = ["CENTRAL_MINISTRY", "STATE_GOVERNMENT", "DISTRICT_AUTHORITY", "PROJECT_AGENCY", "FIELD_OFFICER"]
VALID_IDENTITY_STATUSES = ["PENDING", "UNDER_REVIEW", "VERIFIED", "REJECTED", "SUSPENDED"]
VALID_OFFICIAL_ID_TYPES = ["STATE_REVENUE_EMP_ID", "NHAI_OFFICER_ID", "NIC_GOV_ID", "MINISTRY_OFFICIAL_ID", "OTHER_OFFICIAL_ID"]

def create_user(db: Session, user_data: Dict[str, Any], creator_user: Optional[User] = None) -> Dict[str, Any]:
    email = user_data["email"].strip().lower()

    # Reject test accounts in production runtime
    if settings.APP_ENV == "production" and ("@test.gov.in" in email or "test." in email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Automated test domains (@test.gov.in) and synthetic test identities are strictly prohibited in production environment."
        )

    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"User with email '{email}' already registered."
        )

    role = user_data.get("role", "FIELD_OFFICER")
    if role not in VALID_ROLES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid role '{role}'. Must be one of {VALID_ROLES}."
        )

    official_id = user_data.get("official_id")
    if official_id:
        official_id = official_id.strip()
        existing_id = db.query(User).filter(User.official_id == official_id).first()
        if existing_id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Official ID '{official_id}' already registered."
            )

    pwd = user_data["password"]
    if len(pwd) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 6 characters long."
        )

    # Initial identity status is always PENDING for real accounts
    identity_status = "PENDING"
    is_demo = bool(user_data.get("is_demo", False))

    new_user = User(
        name=user_data["name"].strip(),
        email=email,
        password_hash=hash_password(pwd),
        role=role,
        state_id=user_data.get("state_id"),
        district_id=user_data.get("district_id"),
        agency_id=user_data.get("agency_id"),
        official_id=official_id,
        official_id_type=user_data.get("official_id_type", "OTHER_OFFICIAL_ID"),
        identity_status=identity_status,
        department=user_data.get("department"),
        designation=user_data.get("designation"),
        phone=user_data.get("phone"),
        is_active=True,
        is_demo=is_demo
    )

    db.add(new_user)
    db.flush()

    # Log audit event
    log_audit_event(
        db=db,
        action="USER_CREATED",
        user_id=creator_user.id if creator_user else new_user.id,
        user_role=creator_user.role if creator_user else new_user.role,
        entity_type="USER",
        entity_id=str(new_user.id),
        new_value={
            "id": new_user.id,
            "email": new_user.email,
            "role": new_user.role,
            "identity_status": new_user.identity_status,
            "is_demo": new_user.is_demo
        }
    )

    db.commit()
    db.refresh(new_user)

    return {
        "id": new_user.id,
        "name": new_user.name,
        "email": new_user.email,
        "role": new_user.role,
        "official_id_masked": mask_official_id(new_user.official_id),
        "official_id_type": new_user.official_id_type,
        "identity_status": new_user.identity_status,
        "department": new_user.department,
        "designation": new_user.designation,
        "district_id": new_user.district_id,
        "is_active": new_user.is_active,
        "is_demo": new_user.is_demo,
        "created_at": new_user.created_at.isoformat() if new_user.created_at else None
    }

def verify_user_identity(
    db: Session,
    target_user_id: int,
    decision: str,
    authority_user: User,
    notes: Optional[str] = None,
    verification_method: Optional[str] = "MANUAL_AUTHORITY_REVIEW",
    verification_reference: Optional[str] = None
) -> Dict[str, Any]:
    # Authority Permission Check
    allowed_authority_roles = ["DISTRICT_AUTHORITY", "STATE_GOVERNMENT", "CENTRAL_MINISTRY"]
    if authority_user.role not in allowed_authority_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Only District Collectorate, State or Central Authority can verify official personnel identity."
        )

    decision_clean = decision.strip().upper()
    if decision_clean not in ["VERIFIED", "REJECTED", "SUSPENDED", "UNDER_REVIEW"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid decision '{decision}'. Must be one of VERIFIED, REJECTED, SUSPENDED, UNDER_REVIEW."
        )

    # Self-verification prevention
    if authority_user.id == target_user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Security policy violation: Personnel cannot verify their own official identity."
        )

    target_user = db.query(User).filter(User.id == target_user_id).first()
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User #{target_user_id} not found."
        )

    # Jurisdiction Scope Check
    if authority_user.role == "DISTRICT_AUTHORITY":
        if target_user.district_id and authority_user.district_id and target_user.district_id != authority_user.district_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. You can only verify personnel assigned to your district division."
            )

    old_status = target_user.identity_status
    target_user.identity_status = decision_clean
    target_user.verified_by = authority_user.id
    target_user.verified_at = datetime.now(timezone.utc)
    target_user.verification_method = verification_method or "MANUAL_AUTHORITY_REVIEW"
    target_user.verification_reference = verification_reference
    target_user.verification_notes = notes

    if decision_clean == "REJECTED":
        target_user.rejection_reason = notes or "Identity credentials could not be authenticated against departmental records."
    elif decision_clean == "SUSPENDED":
        target_user.suspension_reason = notes or "Official personnel account suspended pending inquiry."

    # Audit Logging
    audit_action = f"USER_{decision_clean}"
    log_audit_event(
        db=db,
        action=audit_action,
        user_id=authority_user.id,
        user_role=authority_user.role,
        entity_type="USER",
        entity_id=str(target_user.id),
        old_value={"identity_status": old_status},
        new_value={
            "identity_status": decision_clean,
            "verified_by": authority_user.id,
            "verification_method": target_user.verification_method,
            "verification_reference": verification_reference,
            "notes": notes
        }
    )

    db.commit()
    db.refresh(target_user)

    return {
        "id": target_user.id,
        "name": target_user.name,
        "email": target_user.email,
        "role": target_user.role,
        "official_id_masked": mask_official_id(target_user.official_id),
        "identity_status": target_user.identity_status,
        "verified_by": target_user.verified_by,
        "verified_by_name": authority_user.name,
        "verification_method": target_user.verification_method,
        "verification_reference": target_user.verification_reference,
        "verified_at": target_user.verified_at.isoformat() if target_user.verified_at else None,
        "notes": notes
    }

def get_users_list(
    db: Session,
    current_user: User,
    role: Optional[str] = None,
    identity_status: Optional[str] = None,
    include_demo: bool = True
) -> List[Dict[str, Any]]:
    query = db.query(User)

    if not include_demo:
        query = query.filter(User.is_demo == False)

    if role:
        query = query.filter(User.role == role)

    if identity_status:
        query = query.filter(User.identity_status == identity_status)

    # District Scope Filtering
    if current_user.role == "DISTRICT_AUTHORITY" and current_user.district_id:
        query = query.filter((User.district_id == current_user.district_id) | (User.district_id == None))
    elif current_user.role == "STATE_GOVERNMENT" and current_user.state_id:
        query = query.filter((User.state_id == current_user.state_id) | (User.state_id == None))

    users = query.order_by(User.id.asc()).all()

    return [
        {
            "id": u.id,
            "name": u.name,
            "email": u.email,
            "role": u.role,
            "official_id_masked": mask_official_id(u.official_id),
            "official_id_type": u.official_id_type,
            "identity_status": u.identity_status,
            "department": u.department or "Department of Land Revenue",
            "designation": u.designation or u.role.replace("_", " ").title(),
            "phone": u.phone,
            "state_id": u.state_id,
            "district_id": u.district_id,
            "is_active": u.is_active,
            "is_demo": u.is_demo,
            "verified_at": u.verified_at.isoformat() if u.verified_at else None,
            "created_at": u.created_at.isoformat() if u.created_at else None
        }
        for u in users
    ]

def get_user_by_id(db: Session, user_id: int, current_user: User) -> Dict[str, Any]:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User #{user_id} not found."
        )

    verifier = db.query(User).filter(User.id == user.verified_by).first() if user.verified_by else None

    return {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "official_id_masked": mask_official_id(user.official_id),
        "official_id_type": user.official_id_type,
        "identity_status": user.identity_status,
        "department": user.department,
        "designation": user.designation,
        "phone": user.phone,
        "state_id": user.state_id,
        "district_id": user.district_id,
        "is_active": user.is_active,
        "is_demo": user.is_demo,
        "verified_by_name": verifier.name if verifier else None,
        "verified_at": user.verified_at.isoformat() if user.verified_at else None,
        "created_at": user.created_at.isoformat() if user.created_at else None
    }
