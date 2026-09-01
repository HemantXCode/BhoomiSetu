from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user, require_roles
from app.schemas.project_schema import ProjectCreateSchema
from app.services import project_service
from app.utils.response import api_response

router = APIRouter(prefix="/projects", tags=["Projects"])

@router.get("")
def list_projects(
    status: Optional[str] = Query(None),
    state_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    projects = project_service.get_scoped_projects(db, user, status_filter=status, state_filter=state_id, search=search)
    return api_response(
        status_code=200,
        success=True,
        message="Projects retrieved successfully.",
        data=projects
    )

@router.get("/{project_id}")
def get_project(
    project_id: int,
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    project = project_service.get_project_by_id(db, project_id, user)
    return api_response(
        status_code=200,
        success=True,
        message="Project details retrieved successfully.",
        data=project
    )

@router.post("")
def create_project(
    project_data: ProjectCreateSchema,
    user = Depends(require_roles("PROJECT_AGENCY", "CENTRAL_MINISTRY")),
    db: Session = Depends(get_db)
):
    created = project_service.create_project(db, user, project_data.model_dump())
    return api_response(
        status_code=201,
        success=True,
        message="Project proposal created successfully.",
        data=created
    )
