from fastapi import APIRouter, Depends, Query, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
from typing import Optional
from app.database.session import get_db
from app.auth.dependencies import get_current_user, require_verified_officer
from app.schemas.field_schema import VisitCreateSchema, VerificationCreateSchema, BatchSyncRequest
from app.services import field_service
from app.services.audit_service import log_audit_event
from app.storage import file_storage
from app.models.document import Document
from app.utils.response import api_response

router = APIRouter(prefix="/field", tags=["Field Operations"])

@router.get("/tasks")
def get_field_tasks(
    status: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    tasks_data = field_service.get_assigned_field_tasks(db, user, status_filter=status, page=page, limit=limit)
    return api_response(
        status_code=200,
        success=True,
        message="Field tasks retrieved successfully.",
        data=tasks_data
    )

@router.get("/tasks/{task_id}")
def get_field_task(
    task_id: int,
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = field_service.get_field_task_by_id(db, task_id, user)
    return api_response(
        status_code=200,
        success=True,
        message="Task details retrieved.",
        data=task
    )

@router.post("/visits")
def start_field_visit(
    visit_data: VisitCreateSchema,
    req: Request,
    user = Depends(require_verified_officer),
    db: Session = Depends(get_db)
):
    client_ip = req.client.host if req.client else None
    created = field_service.create_field_visit(db, user, visit_data.model_dump(), request_ip=client_ip)
    return api_response(
        status_code=201,
        success=True,
        message="Field visit initiated.",
        data=created
    )

@router.get("/visits")
def list_field_visits(
    task_id: Optional[int] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    visits = field_service.get_field_visits(db, user, task_id=task_id)
    return api_response(
        status_code=200,
        success=True,
        message="Field visits retrieved successfully.",
        data=visits
    )

@router.get("/visits/{visit_id}")
def get_field_visit(
    visit_id: int,
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    visit = field_service.get_field_visit_by_id(db, visit_id, user)
    return api_response(
        status_code=200,
        success=True,
        message="Field visit details retrieved.",
        data=visit
    )

@router.post("/photos")
def upload_field_photo(
    req: Request,
    file: UploadFile = File(...),
    related_entity_id: Optional[int] = Form(None),
    user = Depends(require_verified_officer),
    db: Session = Depends(get_db)
):
    client_ip = req.client.host if req.client else None
    saved = file_storage.save_uploaded_file(file, related_entity="FIELD_PHOTO", related_entity_id=related_entity_id)
    
    # Persist photo metadata in PostgreSQL documents table with strict JWT uploader ownership
    db_doc = Document(
        id=saved["document_id"],
        document_name=saved["file_name"],
        file_type=saved["file_type"],
        file_size=saved["file_size"],
        storage_path=saved["storage_path"],
        uploaded_by=user.id,  # STRICTLY from authenticated JWT user
        related_entity="FIELD_PHOTO",
        related_entity_id=related_entity_id
    )
    db.add(db_doc)
    db.flush()

    # Log audit event
    log_audit_event(
        db=db,
        action="PHOTO_UPLOADED",
        user_id=user.id,
        user_role=user.role,
        entity_type="DOCUMENT",
        entity_id=db_doc.id,
        request_ip=client_ip,
        new_value={
            "document_id": db_doc.id,
            "document_name": db_doc.document_name,
            "file_size": db_doc.file_size,
            "related_entity": "FIELD_PHOTO",
            "related_entity_id": related_entity_id
        }
    )

    db.commit()
    db.refresh(db_doc)

    return api_response(
        status_code=201,
        success=True,
        message="Field photo uploaded and persisted in PostgreSQL successfully.",
        data={
            "document_id": db_doc.id,
            "photo_id": db_doc.id,
            "file_name": db_doc.document_name,
            "file_type": db_doc.file_type,
            "file_size": db_doc.file_size,
            "url": f"/api/v1/documents/{db_doc.id}/download",
            "related_entity": db_doc.related_entity,
            "related_entity_id": db_doc.related_entity_id,
            "created_at": db_doc.created_at.isoformat() if db_doc.created_at else None
        }
    )

@router.get("/photos")
def list_field_photos(
    related_entity_id: Optional[int] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    photos = field_service.get_field_photos(db, user, related_entity_id=related_entity_id)
    return api_response(
        status_code=200,
        success=True,
        message="Field photos retrieved.",
        data=photos
    )

@router.post("/verifications")
def submit_verification(
    verification_data: VerificationCreateSchema,
    req: Request,
    user = Depends(require_verified_officer),
    db: Session = Depends(get_db)
):
    client_ip = req.client.host if req.client else None
    result = field_service.submit_field_verification(db, user, verification_data.model_dump(), request_ip=client_ip)
    return api_response(
        status_code=201,
        success=True,
        message="Field verification submitted successfully.",
        data=result
    )

@router.get("/verifications")
def list_field_verifications(
    task_id: Optional[int] = Query(None),
    user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    verifications = field_service.get_field_verifications(db, user, task_id=task_id)
    return api_response(
        status_code=200,
        success=True,
        message="Field verifications retrieved.",
        data=verifications
    )

@router.post("/sync")
def sync_offline_events(
    sync_request: BatchSyncRequest,
    req: Request,
    user = Depends(require_verified_officer),
    db: Session = Depends(get_db)
):
    client_ip = req.client.host if req.client else None
    sync_result = field_service.process_batch_sync(db, user, sync_request.model_dump(), request_ip=client_ip)
    return api_response(
        status_code=200,
        success=True,
        message="Synchronization completed.",
        data=sync_result
    )
