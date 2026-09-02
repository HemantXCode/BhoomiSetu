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

@router.get("/corridors")
def get_gis_corridors(project_id: Optional[int] = Query(None), user = Depends(get_current_user), db: Session = Depends(get_db)):
    # Pune Ring Road & Pune-Nashik Rail Corridor segment geometries
    pune_ring_road_segments = [
        {
            "id": "PRR-SEG-01",
            "project_id": 1,
            "project_name": "Pune Ring Road Express Corridor (Phase-I)",
            "name": "Urse - Hinjawadi Sector",
            "status": "ACQUIRED",
            "length_km": 14.2,
            "land_area_ha": 165.50,
            "coordinates": [[73.6540, 18.7180], [73.6820, 18.6850], [73.7050, 18.6520]]
        },
        {
            "id": "PRR-SEG-02",
            "project_id": 1,
            "project_name": "Pune Ring Road Express Corridor (Phase-I)",
            "name": "Hinjawadi - Lavale Sector",
            "status": "ACQUIRED",
            "length_km": 12.8,
            "land_area_ha": 123.78,
            "coordinates": [[73.7050, 18.6520], [73.7210, 18.6180], [73.7290, 18.5720], [73.7314, 18.5362]]
        },
        {
            "id": "PRR-SEG-03",
            "project_id": 1,
            "project_name": "Pune Ring Road Express Corridor (Phase-I)",
            "name": "Pirangut - Bhugaon Sector",
            "status": "IN_PROGRESS",
            "length_km": 11.5,
            "land_area_ha": 96.20,
            "coordinates": [[73.7314, 18.5362], [73.6845, 18.5124], [73.7468, 18.4982], [73.7780, 18.4612]]
        },
        {
            "id": "PRR-SEG-04",
            "project_id": 1,
            "project_name": "Pune Ring Road Express Corridor (Phase-I)",
            "name": "Dhayari - Khed Shivapur Sector",
            "status": "PENDING",
            "length_km": 16.5,
            "land_area_ha": 100.02,
            "coordinates": [[73.7780, 18.4612], [73.8120, 18.4230], [73.8450, 18.3890], [73.8650, 18.3540]]
        }
    ]

    pune_nashik_rail_segments = [
        {
            "id": "PNR-SEG-01",
            "project_id": 2,
            "project_name": "Pune-Nashik Semi-High Speed Rail Corridor",
            "name": "Hadapsar - Bhosari Sector",
            "status": "ACQUIRED",
            "length_km": 28.5,
            "land_area_ha": 240.0,
            "coordinates": [[73.9280, 18.5089], [73.8820, 18.5850], [73.8450, 18.6250]]
        },
        {
            "id": "PNR-SEG-02",
            "project_id": 2,
            "project_name": "Pune-Nashik Semi-High Speed Rail Corridor",
            "name": "Chakan - Rajgurunagar Sector",
            "status": "ACQUIRED",
            "length_km": 34.0,
            "land_area_ha": 190.0,
            "coordinates": [[73.8450, 18.6250], [73.8590, 18.7610], [73.8850, 18.8580]]
        },
        {
            "id": "PNR-SEG-03",
            "project_id": 2,
            "project_name": "Pune-Nashik Semi-High Speed Rail Corridor",
            "name": "Manchar - Narayangaon Sector",
            "status": "IN_PROGRESS",
            "length_km": 42.0,
            "land_area_ha": 140.0,
            "coordinates": [[73.8850, 18.8580], [73.9400, 19.0060], [73.9780, 19.1250]]
        },
        {
            "id": "PNR-SEG-04",
            "project_id": 2,
            "project_name": "Pune-Nashik Semi-High Speed Rail Corridor",
            "name": "Sangamner - Sinnar - Nashik Sector",
            "status": "PENDING",
            "length_km": 55.5,
            "land_area_ha": 150.0,
            "coordinates": [[73.9780, 19.1250], [74.2050, 19.5720], [73.9920, 19.8450], [73.7890, 19.9975]]
        }
    ]

    all_segments = pune_ring_road_segments + pune_nashik_rail_segments
    if project_id:
        all_segments = [s for s in all_segments if s["project_id"] == project_id]

    features = []
    for s in all_segments:
        features.append({
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": s["coordinates"]
            },
            "properties": {
                "segment_id": s["id"],
                "project_id": s["project_id"],
                "project_name": s["project_name"],
                "segment_name": s["name"],
                "status": s["status"],
                "length_km": s["length_km"],
                "land_area_ha": s["land_area_ha"]
            }
        })

    return api_response(status_code=200, success=True, message="Corridor segments retrieved.", data={"type": "FeatureCollection", "features": features})

@router.get("/parcels")
def get_gis_parcels(
    district_id: Optional[int] = Query(None),
    project_id: Optional[int] = Query(None),
    ulpin: Optional[str] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(LandParcel)
    if district_id:
        query = query.filter(LandParcel.district_id == district_id)
    if project_id:
        query = query.filter(LandParcel.project_id == project_id)
    if ulpin:
        query = query.filter(LandParcel.ulpin.ilike(f"%{ulpin}%"))
    parcels = query.all()

    features = []
    for parcel in parcels:
        # Base anchor coordinates around Pune district
        base_lat = 18.5204 + (parcel.id * 0.012)
        base_lng = 73.8567 + (parcel.id * 0.009)
        features.append({
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [base_lng, base_lat],
                    [base_lng + 0.004, base_lat + 0.003],
                    [base_lng + 0.006, base_lat - 0.002],
                    [base_lng + 0.002, base_lat - 0.004],
                    [base_lng, base_lat]
                ]]
            },
            "properties": {
                "id": parcel.id,
                "ulpin": parcel.ulpin,
                "parcel_number": parcel.ulpin,
                "survey_number": parcel.survey_number,
                "village": parcel.village,
                "project_id": parcel.project_id,
                "district_id": parcel.district_id,
                "state_id": parcel.state_id,
                "owner_name": parcel.owner_name,
                "area_hectares": float(parcel.area_hectares),
                "classification": parcel.classification,
                "status": parcel.status
            }
        })

    geojson = {
        "type": "FeatureCollection",
        "features": features
    }
    return api_response(status_code=200, success=True, message="GIS Land Parcel layers retrieved.", data=geojson)
