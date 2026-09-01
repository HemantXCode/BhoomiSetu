from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.utils.jwt_util import decode_access_token
from app.models.user import User

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)) -> User:
    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token or token expired.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    try:
        user_id = int(payload.get("sub"))
    except (ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid user token subject."
        )

    user = db.query(User).filter(User.id == user_id, User.is_active == True).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User profile not found or account deactivated."
        )
    
    return user

def require_roles(*allowed_roles: str):
    def role_checker(user: User = Depends(get_current_user)) -> User:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. User role '{user.role}' is not authorized for this operation."
            )
        return user
    return role_checker

def require_verified_officer(user: User = Depends(get_current_user)) -> User:
    if user.role != "FIELD_OFFICER":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Only Field Officers can perform this operation."
        )
    if user.identity_status != "VERIFIED":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="IDENTITY_VERIFICATION_REQUIRED: Official personnel identity verification is pending with District/State Authority. Official field operations are restricted until verified."
        )
    return user

def verify_jurisdiction(user: User, state_id: int = None, district_id: int = None, agency_id: int = None):
    if user.role == "CENTRAL_MINISTRY":
        return True
    
    if user.role == "STATE_GOVERNMENT":
        if state_id and state_id != user.state_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. You are only authorized to access data within your assigned state."
            )
    
    if user.role == "DISTRICT_AUTHORITY":
        if district_id and district_id != user.district_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. You are only authorized to access data within your assigned district."
            )
        if state_id and state_id != user.state_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. State scope mismatch."
            )

    if user.role == "PROJECT_AGENCY":
        if agency_id and agency_id != user.agency_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. You are only authorized to access projects belonging to your agency."
            )

    if user.role == "FIELD_OFFICER":
        if district_id and district_id != user.district_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. Task or parcel is outside your assigned field division."
            )

    return True
