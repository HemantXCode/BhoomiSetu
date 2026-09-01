from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.models.rr import AffectedFamily, DisplacedFamily
from app.utils.response import api_response

router = APIRouter(prefix="/rr", tags=["Rehabilitation & Resettlement"])

@router.get("/affected-families")
def get_affected_families(project_id: Optional[int] = Query(None), user = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(AffectedFamily)
    if project_id:
        query = query.filter(AffectedFamily.project_id == project_id)
    items = query.all()
    data = [{
        "id": f.id,
        "project_id": f.project_id,
        "family_head": f.family_head,
        "total_members": f.total_members,
        "vulnerability_status": f.vulnerability_status
    } for f in items]
    return api_response(status_code=200, success=True, message="Affected families retrieved.", data=data)
