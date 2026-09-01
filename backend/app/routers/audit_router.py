from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.auth.dependencies import get_current_user, require_roles
from app.models.audit import AuditLog
from app.utils.response import api_response

router = APIRouter(prefix="/audit", tags=["Audit Logs"])

@router.get("")
def get_audit_logs(user = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(AuditLog)
    if user.role == "FIELD_OFFICER":
        query = query.filter(AuditLog.user_id == user.id)
    elif user.role == "DISTRICT_AUTHORITY" and user.district_id:
        pass # District authority can view divisional logs

    logs = query.order_by(AuditLog.timestamp.desc()).limit(100).all()
    data = [{
        "id": l.id,
        "user_id": l.user_id,
        "user_role": l.user_role,
        "action": l.action,
        "entity_type": l.entity_type,
        "entity_id": l.entity_id,
        "timestamp": l.timestamp.isoformat() if l.timestamp else None
    } for l in logs]
    return api_response(status_code=200, success=True, message="Audit logs retrieved.", data=data)
