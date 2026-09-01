from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status, Query, Request
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import Optional
import os

from app.database.session import get_db
from app.auth.dependencies import get_current_user
from app.storage import file_storage
from app.models.document import Document
from app.models.user import User
from app.services.audit_service import log_audit_event
from app.utils.response import api_response

router = APIRouter(prefix="/documents", tags=["Document Management"])

@router.post("/upload")
def upload_document(
    req: Request,
    file: UploadFile = File(...),
    related_entity: str = Form("GENERAL"),
    related_entity_id: Optional[int] = Form(None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    client_ip = req.client.host if req.client else None
    saved = file_storage.save_uploaded_file(file, related_entity=related_entity, related_entity_id=related_entity_id)

    # Persist document metadata in PostgreSQL with strict JWT user ownership
    db_doc = Document(
        id=saved["document_id"],
        document_name=saved["file_name"],
        file_type=saved["file_type"],
        file_size=saved["file_size"],
        storage_path=saved["storage_path"],
        uploaded_by=user.id,  # STRICTLY from authenticated JWT context
        related_entity=related_entity,
        related_entity_id=related_entity_id
    )
    db.add(db_doc)
    db.flush()

    # Log audit event
    log_audit_event(
        db=db,
        action="DOCUMENT_UPLOADED",
        user_id=user.id,
        user_role=user.role,
        entity_type="DOCUMENT",
        entity_id=db_doc.id,
        request_ip=client_ip,
        new_value={
            "document_id": db_doc.id,
            "document_name": db_doc.document_name,
            "file_size": db_doc.file_size,
            "related_entity": related_entity,
            "related_entity_id": related_entity_id
        }
    )

    db.commit()
    db.refresh(db_doc)

    return api_response(
        status_code=201,
        success=True,
        message="Document uploaded and persisted in PostgreSQL successfully.",
        data={
            "document_id": db_doc.id,
            "document_name": db_doc.document_name,
            "file_type": db_doc.file_type,
            "file_size": db_doc.file_size,
            "url": f"/api/v1/documents/{db_doc.id}/download",
            "related_entity": db_doc.related_entity,
            "related_entity_id": db_doc.related_entity_id,
            "uploaded_by": db_doc.uploaded_by,
            "created_at": db_doc.created_at.isoformat() if db_doc.created_at else None
        }
    )

@router.get("")
def list_documents(
    related_entity: Optional[str] = Query(None),
    related_entity_id: Optional[int] = Query(None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Document)
    if related_entity:
        query = query.filter(Document.related_entity == related_entity)
    if related_entity_id is not None:
        query = query.filter(Document.related_entity_id == related_entity_id)

    docs = query.order_by(Document.created_at.desc()).all()
    results = []
    for d in docs:
        uploader = db.query(User).filter(User.id == d.uploaded_by).first() if d.uploaded_by else None
        results.append({
            "id": d.id,
            "document_name": d.document_name,
            "file_type": d.file_type,
            "file_size": d.file_size,
            "url": f"/api/v1/documents/{d.id}/download",
            "related_entity": d.related_entity,
            "related_entity_id": d.related_entity_id,
            "uploaded_by_id": d.uploaded_by,
            "uploaded_by_name": uploader.name if uploader else "System",
            "created_at": d.created_at.isoformat() if d.created_at else None
        })

    return api_response(
        status_code=200,
        success=True,
        message="Documents retrieved successfully.",
        data=results
    )

@router.get("/{document_id}")
def get_document_metadata(
    document_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    doc = db.query(Document).filter(Document.id == document_id).first()
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document '{document_id}' not found in database."
        )

    uploader = db.query(User).filter(User.id == doc.uploaded_by).first() if doc.uploaded_by else None

    return api_response(
        status_code=200,
        success=True,
        message="Document metadata retrieved.",
        data={
            "id": doc.id,
            "document_name": doc.document_name,
            "file_type": doc.file_type,
            "file_size": doc.file_size,
            "url": f"/api/v1/documents/{doc.id}/download",
            "related_entity": doc.related_entity,
            "related_entity_id": doc.related_entity_id,
            "uploaded_by_id": doc.uploaded_by,
            "uploaded_by_name": uploader.name if uploader else "System",
            "created_at": doc.created_at.isoformat() if doc.created_at else None
        }
    )

@router.get("/{document_id}/download")
def download_document(
    document_id: str,
    req: Request,
    db: Session = Depends(get_db)
):
    doc = db.query(Document).filter(Document.id == document_id).first()
    if not doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Document '{document_id}' not found."
        )

    client_ip = req.client.host if req.client else None
    log_audit_event(
        db=db,
        action="DOCUMENT_ACCESSED",
        user_id=None,
        entity_type="DOCUMENT",
        entity_id=doc.id,
        request_ip=client_ip,
        new_value={"document_id": doc.id, "document_name": doc.document_name}
    )
    db.commit()

    file_path = file_storage.get_file_path(doc.storage_path)
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Physical document file missing from storage."
        )

    media_type = "application/octet-stream"
    if doc.file_type == "application/pdf":
        media_type = "application/pdf"
    elif doc.file_type in ["image/jpeg", "image/jpg"]:
        media_type = "image/jpeg"
    elif doc.file_type == "image/png":
        media_type = "image/png"

    return FileResponse(
        path=file_path,
        media_type=media_type,
        filename=doc.document_name
    )
