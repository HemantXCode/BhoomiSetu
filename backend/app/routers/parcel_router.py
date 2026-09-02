from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.models.parcel import LandParcel
from app.utils.response import api_response

router = APIRouter(tags=["Land & Parcels"])

@router.get("/parcels")
@router.get("/land")
def get_land_parcels(
    project_id: Optional[int] = Query(None),
    district_id: Optional[int] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(LandParcel)
    if project_id:
        query = query.filter(LandParcel.project_id == project_id)
    if district_id:
        query = query.filter(LandParcel.district_id == district_id)
    parcels = query.all()

    data = []
    for p in parcels:
        data.append({
            "id": p.id,
            "project_id": p.project_id,
            "ulpin": p.ulpin,
            "parcel_number": p.ulpin,
            "survey_number": p.survey_number,
            "village": p.village,
            "area_hectares": float(p.area_hectares) if p.area_hectares else 0.0,
            "classification": p.classification,
            "owner_name": p.owner_name,
            "status": p.status
        })

    return api_response(status_code=200, success=True, message="Land parcels retrieved successfully.", data=data)
