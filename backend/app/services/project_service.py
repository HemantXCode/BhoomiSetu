from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import Optional, Dict, Any, List
from app.models.project import Project
from app.models.user import User
from app.auth.dependencies import verify_jurisdiction

def get_scoped_projects(db: Session, user: User, status_filter: Optional[str] = None, state_filter: Optional[int] = None, search: Optional[str] = None):
    query = db.query(Project)

    # Data scope filtering
    if user.role == "STATE_GOVERNMENT":
        query = query.filter(Project.state_id == user.state_id)
    elif user.role == "DISTRICT_AUTHORITY":
        query = query.filter(Project.district_id == user.district_id)
    elif user.role == "PROJECT_AGENCY":
        query = query.filter(Project.agency_id == user.agency_id)
    elif user.role == "FIELD_OFFICER":
        query = query.filter(Project.district_id == user.district_id)

    if status_filter:
        query = query.filter(Project.status == status_filter)
    if state_filter:
        query = query.filter(Project.state_id == state_filter)
    if search:
        query = query.filter(Project.project_name.ilike(f"%{search}%"))

    projects = query.all()
    
    result = []
    for p in projects:
        result.append({
            "id": p.id,
            "project_name": p.project_name,
            "description": p.description,
            "agency_id": p.agency_id,
            "agency_name": p.agency.name if p.agency else None,
            "state_id": p.state_id,
            "state_name": p.state.name if p.state else None,
            "district_id": p.district_id,
            "district_name": p.district.name if p.district else None,
            "proposed_area": float(p.proposed_area) if p.proposed_area else 0.0,
            "status": p.status,
            "start_date": p.start_date.isoformat() if p.start_date else None,
            "expected_end_date": p.expected_end_date.isoformat() if p.expected_end_date else None,
            "created_at": p.created_at.isoformat() if p.created_at else None
        })
    return result

def get_project_by_id(db: Session, project_id: int, user: User):
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Project #{project_id} not found."
        )

    verify_jurisdiction(
        user=user,
        state_id=project.state_id,
        district_id=project.district_id,
        agency_id=project.agency_id
    )

    return {
        "id": project.id,
        "project_name": project.project_name,
        "description": project.description,
        "agency_id": project.agency_id,
        "agency_name": project.agency.name if project.agency else None,
        "state_id": project.state_id,
        "state_name": project.state.name if project.state else None,
        "district_id": project.district_id,
        "district_name": project.district.name if project.district else None,
        "proposed_area": float(project.proposed_area) if project.proposed_area else 0.0,
        "status": project.status,
        "start_date": project.start_date.isoformat() if project.start_date else None,
        "expected_end_date": project.expected_end_date.isoformat() if project.expected_end_date else None,
        "created_at": project.created_at.isoformat() if project.created_at else None
    }

def create_project(db: Session, user: User, project_data: Dict[str, Any]):
    agency_id = project_data.get("agency_id")
    if user.role == "PROJECT_AGENCY":
        agency_id = user.agency_id

    if not agency_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Agency ID is required to create a project proposal."
        )

    verify_jurisdiction(
        user=user,
        state_id=project_data.get("state_id"),
        district_id=project_data.get("district_id"),
        agency_id=agency_id
    )

    new_project = Project(
        project_name=project_data["project_name"],
        description=project_data.get("description"),
        agency_id=agency_id,
        state_id=project_data["state_id"],
        district_id=project_data["district_id"],
        proposed_area=project_data["proposed_area"],
        status=project_data.get("status", "PROPOSED"),
        start_date=project_data.get("start_date"),
        expected_end_date=project_data.get("expected_end_date"),
        created_by=user.id
    )

    db.add(new_project)
    db.commit()
    db.refresh(new_project)

    return get_project_by_id(db, new_project.id, user)
