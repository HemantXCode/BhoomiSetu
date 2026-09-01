from fastapi import APIRouter, Depends, Path
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.services.dashboard_service import get_dashboard_stats
from app.utils.response import api_response

router = APIRouter(prefix="/analytics", tags=["Analytics & MIS"])

@router.get("/national")
def get_national_analytics(user = Depends(get_current_user), db: Session = Depends(get_db)):
    stats = get_dashboard_stats(db, user)
    return api_response(status_code=200, success=True, message="National analytics retrieved.", data=stats)

@router.get("/state/{state_id}")
def get_state_analytics(state_id: int = Path(...), user = Depends(get_current_user), db: Session = Depends(get_db)):
    stats = get_dashboard_stats(db, user)
    return api_response(status_code=200, success=True, message="State analytics retrieved.", data=stats)

@router.get("/district/{district_id}")
def get_district_analytics(district_id: int = Path(...), user = Depends(get_current_user), db: Session = Depends(get_db)):
    stats = get_dashboard_stats(db, user)
    return api_response(status_code=200, success=True, message="District analytics retrieved.", data=stats)
