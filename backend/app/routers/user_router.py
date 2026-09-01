from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional

from app.database.session import get_db
from app.auth.dependencies import get_current_user, require_roles
from app.schemas.auth_schema import UserCreateRequest, UserVerifyRequest
from app.services import user_service
from app.utils.response import api_response

router = APIRouter(prefix="/users", tags=["Users & Identity Management"])

@router.post("")
def register_user(
    request: UserCreateRequest,
    current_user = Depends(require_roles("CENTRAL_MINISTRY", "STATE_GOVERNMENT", "DISTRICT_AUTHORITY")),
    db: Session = Depends(get_db)
):
    created_user = user_service.create_user(db, request.model_dump(), creator_user=current_user)
    return api_response(
        status_code=201,
        success=True,
        message="User registered successfully with identity verification pending.",
        data=created_user
    )

@router.get("")
def list_users(
    role: Optional[str] = Query(None),
    identity_status: Optional[str] = Query(None),
    include_demo: bool = Query(True),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    users = user_service.get_users_list(
        db=db,
        current_user=current_user,
        role=role,
        identity_status=identity_status,
        include_demo=include_demo
    )
    return api_response(
        status_code=200,
        success=True,
        message="Users retrieved successfully.",
        data=users
    )

@router.get("/{user_id}")
def get_user(
    user_id: int,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user_data = user_service.get_user_by_id(db, user_id, current_user)
    return api_response(
        status_code=200,
        success=True,
        message="User profile retrieved.",
        data=user_data
    )

@router.post("/{user_id}/verify")
def verify_user(
    user_id: int,
    request: UserVerifyRequest,
    current_user = Depends(require_roles("DISTRICT_AUTHORITY", "STATE_GOVERNMENT", "CENTRAL_MINISTRY")),
    db: Session = Depends(get_db)
):
    result = user_service.verify_user_identity(
        db=db,
        target_user_id=user_id,
        decision=request.decision,
        authority_user=current_user,
        notes=request.notes,
        verification_method=request.verification_method,
        verification_reference=request.verification_reference
    )
    return api_response(
        status_code=200,
        success=True,
        message=f"User identity status updated to {request.decision}.",
        data=result
    )
