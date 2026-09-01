from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.models.compensation import Award, CompensationAssessment, CompensationPayment
from app.utils.response import api_response

router = APIRouter(prefix="/compensation", tags=["Compensation & Awards"])

@router.get("/awards")
def get_awards(project_id: Optional[int] = Query(None), user = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(Award)
    if project_id:
        query = query.filter(Award.project_id == project_id)
    awards = query.all()
    data = [{
        "id": a.id,
        "project_id": a.project_id,
        "award_number": a.award_number,
        "total_compensation_cr": float(a.total_compensation_cr),
        "award_date": a.award_date.isoformat() if a.award_date else None,
        "status": a.status
    } for a in awards]
    return api_response(status_code=200, success=True, message="Awards retrieved.", data=data)

@router.get("/assessments")
def get_assessments(parcel_id: Optional[int] = Query(None), user = Depends(get_current_user), db: Session = Depends(get_db)):
    query = db.query(CompensationAssessment)
    if parcel_id:
        query = query.filter(CompensationAssessment.parcel_id == parcel_id)
    items = query.all()
    data = [{
        "id": c.id,
        "parcel_id": c.parcel_id,
        "land_value": float(c.land_value),
        "structure_value": float(c.structure_value),
        "solatium": float(c.solatium),
        "total_amount": float(c.total_amount),
        "status": c.status
    } for c in items]
    return api_response(status_code=200, success=True, message="Compensation assessments retrieved.", data=data)
