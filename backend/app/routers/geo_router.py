from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.models.user import State, District, Agency
from app.models.parcel import LandParcel
from app.models.project import Project
from app.auth.dependencies import get_current_user
from app.utils.response import api_response

router = APIRouter(prefix="/geo", tags=["Geographic & GIS"])

@router.get("/states")
def get_states(db: Session = Depends(get_db)):
    states = db.query(State).all()
    data = [{"id": s.id, "name": s.name, "code": s.code} for s in states]
    return api_response(status_code=200, success=True, message="States retrieved successfully.", data=data)

@router.get("/districts")
def get_districts(state_id: Optional[int] = Query(None), db: Session = Depends(get_db)):
    query = db.query(District)
    if state_id:
        query = query.filter(District.state_id == state_id)
    districts = query.all()
    data = [{"id": d.id, "state_id": d.state_id, "name": d.name, "code": d.code} for d in districts]
    return api_response(status_code=200, success=True, message="Districts retrieved successfully.", data=data)

@router.get("/agencies")
def get_agencies(state_id: Optional[int] = Query(None), db: Session = Depends(get_db)):
    query = db.query(Agency)
    if state_id:
        query = query.filter((Agency.state_id == state_id) | (Agency.state_id == None))
    agencies = query.all()
    data = [{"id": a.id, "name": a.name, "type": a.type, "state_id": a.state_id} for a in agencies]
    return api_response(status_code=200, success=True, message="Agencies retrieved successfully.", data=data)

@router.get("/projects")
def get_gis_projects(user = Depends(get_current_user), db: Session = Depends(get_db)):
    projects = db.query(Project).all()
    features = []
    for p in projects:
        features.append({
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [73.8567 if p.id % 2 == 1 else 72.8777, 18.5204 if p.id % 2 == 1 else 19.0760]
            },
            "properties": {
                "id": p.id,
                "project_name": p.project_name,
                "status": p.status,
                "proposed_area": float(p.proposed_area)
            }
        })
    geojson = {
        "type": "FeatureCollection",
        "features": features
    }
    return api_response(status_code=200, success=True, message="GIS Project layers retrieved.", data=geojson)

@router.get("/parcels")
def get_gis_parcels(
    district_id: Optional[int] = Query(None),
    project_id: Optional[int] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(LandParcel)
    if district_id:
        query = query.filter(LandParcel.district_id == district_id)
    if project_id:
        query = query.filter(LandParcel.project_id == project_id)
    parcels = query.all()

    features = []
    for parcel in parcels:
        features.append({
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [73.8567, 18.5204],
                    [73.8575, 18.5210],
                    [73.8580, 18.5200],
                    [73.8567, 18.5204]
                ]]
            },
            "properties": {
                "id": parcel.id,
                "parcel_number": parcel.parcel_number,
                "survey_number": parcel.survey_number,
                "owner_name": parcel.owner_name,
                "area_hectares": float(parcel.area_hectares),
                "status": parcel.status
            }
        })

    geojson = {
        "type": "FeatureCollection",
        "features": features
    }
    return api_response(status_code=200, success=True, message="GIS Land Parcel layers retrieved.", data=geojson)
