from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.schemas.auth_schema import LoginRequest
from app.services import auth_service
from app.auth.dependencies import get_current_user
from app.utils.identity_util import mask_official_id
from app.utils.response import api_response

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login")
def login(request: LoginRequest, req: Request, db: Session = Depends(get_db)):
    client_ip = req.client.host if req.client else None
    auth_data = auth_service.authenticate_user(db, request.email, request.password, client_ip=client_ip)
    return api_response(
        status_code=200,
        success=True,
        message="Authentication successful.",
        data=auth_data
    )

@router.get("/me")
def get_me(user = Depends(get_current_user)):
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
    return api_response(
        status_code=200,
        success=True,
        message="User profile retrieved.",
        data=user_payload
    )
