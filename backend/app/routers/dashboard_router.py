from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.services import dashboard_service
from app.utils.response import api_response

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

@router.get("/stats")
def get_dashboard_stats(
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    stats = dashboard_service.get_dashboard_stats(db, user)
    return api_response(
        status_code=200,
        success=True,
        message="Dashboard statistics retrieved successfully.",
        data=stats
    )
