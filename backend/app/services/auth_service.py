from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.config.settings import settings
from app.models.user import User
from app.utils.hash import verify_password
from app.utils.jwt_util import create_access_token
from app.utils.identity_util import mask_official_id
from app.services.audit_service import log_audit_event

def authenticate_user(db: Session, email: str, password: str, client_ip: str = None):
    email_clean = email.strip().lower()
    user = db.query(User).filter(User.email == email_clean).first()
    
    if not user or not verify_password(password, user.password_hash):
        if user:
            log_audit_event(
                db=db,
                action="LOGIN_FAILURE",
                user_id=user.id,
                user_role=user.role,
                entity_type="AUTH",
                request_ip=client_ip,
                new_value={"email": email_clean, "reason": "INVALID_PASSWORD"}
            )
            db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )
    
    # Block decommissioned demo accounts in production runtime
    if user.is_demo and settings.APP_ENV == "production":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Demo credentials are decommissioned. Please authenticate using authorized government personnel credentials."
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account has been deactivated. Please contact system administrator."
        )

    # Check if account is suspended or rejected
    if user.identity_status == "SUSPENDED":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account suspended by Departmental Authority. Reason: " + (user.suspension_reason or "Pending inquiry.")
        )
    elif user.identity_status == "REJECTED":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account registration rejected by Authority. Reason: " + (user.rejection_reason or "Invalid credentials.")
        )

    token = create_access_token({
        "sub": str(user.id),
        "role": user.role,
        "identity_status": user.identity_status
    })

    log_audit_event(
        db=db,
        action="LOGIN_SUCCESS",
        user_id=user.id,
        user_role=user.role,
        entity_type="AUTH",
        request_ip=client_ip,
        new_value={"email": user.email, "identity_status": user.identity_status}
    )
    db.commit()
    
    user_payload = {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "official_id_masked": mask_official_id(user.official_id),
        "official_id_type": user.official_id_type,
        "identity_status": user.identity_status,
        "department": user.department or "Department of Land Revenue",
        "designation": user.designation or user.role.replace("_", " ").title(),
        "phone": user.phone,
        "state_id": user.state_id,
        "state_name": user.state.name if user.state else None,
        "state_code": user.state.code if user.state else None,
        "district_id": user.district_id,
        "district_name": user.district.name if user.district else None,
        "district_code": user.district.code if user.district else None,
        "agency_id": user.agency_id,
        "agency_name": user.agency.name if user.agency else None,
        "agency_type": user.agency.type if user.agency else None,
        "is_demo": user.is_demo
    }

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": user_payload
    }
