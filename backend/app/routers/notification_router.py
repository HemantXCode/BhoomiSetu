from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.models.compensation import Notification
from app.utils.response import api_response

router = APIRouter(prefix="/notifications", tags=["Gazette Notifications"])

@router.get("")
def get_notifications(project_id: Optional[int] = Query(None), user = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(Notification)
    if project_id:
        query = query.filter(Notification.project_id == project_id)
    notifications = query.all()
    data = [{
        "id": n.id,
        "project_id": n.project_id,
        "notification_type": n.notification_type,
        "gazette_number": n.gazette_number,
        "issue_date": n.issue_date.isoformat() if n.issue_date else None,
        "document_url": n.document_url
    } for n in notifications]
    return api_response(status_code=200, success=True, message="Notifications retrieved.", data=data)
