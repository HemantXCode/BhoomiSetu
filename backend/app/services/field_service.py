from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone

from app.models.field import FieldTask, FieldVisit, FieldVerification, SyncEvent
from app.models.parcel import LandParcel
from app.models.project import Project
from app.models.user import User
from app.models.document import Document
from app.services.audit_service import log_audit_event

def get_assigned_field_tasks(db: Session, user: User, status_filter: Optional[str] = None, page: int = 1, limit: int = 20):
    query = db.query(FieldTask)

    if user.role == "FIELD_OFFICER":
        # Strict server-side filtering: officer only sees their own assigned tasks
        query = query.filter(FieldTask.assigned_to_user_id == user.id)
    elif user.role == "DISTRICT_AUTHORITY" and user.district_id:
        query = query.join(Project, FieldTask.project_id == Project.id).filter(Project.district_id == user.district_id)

    if status_filter:
        query = query.filter(FieldTask.status == status_filter)

    total = query.count()
    tasks = query.order_by(FieldTask.id.asc()).offset((page - 1) * limit).limit(limit).all()

    task_list = []
    for t in tasks:
        parcel = db.query(LandParcel).filter(LandParcel.id == t.parcel_id).first()
        project = db.query(Project).filter(Project.id == t.project_id).first()
        assigned_user = db.query(User).filter(User.id == t.assigned_to_user_id).first() if t.assigned_to_user_id else None

        task_list.append({
            "id": t.id,
            "project_id": t.project_id,
            "project_name": project.project_name if project else None,
            "parcel_id": t.parcel_id,
            "parcel_number": parcel.parcel_number if parcel else None,
            "survey_number": parcel.survey_number if parcel else None,
            "village": parcel.village if parcel else None,
            "owner_name": parcel.owner_name if parcel else None,
            "assigned_to_user_id": t.assigned_to_user_id,
            "assigned_officer_name": assigned_user.name if assigned_user else "Unassigned",
            "task_type": t.task_type,
            "priority": t.priority,
            "due_date": t.due_date.isoformat() if t.due_date else None,
            "status": t.status,
            "target_latitude": 18.5204,
            "target_longitude": 73.8567
        })

    return {
        "total": total,
        "page": page,
        "limit": limit,
        "tasks": task_list
    }

def get_field_task_by_id(db: Session, task_id: int, user: User):
    task = db.query(FieldTask).filter(FieldTask.id == task_id).first()
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Field task #{task_id} not found in database."
        )

    # Server-side Task Ownership Check
    if user.role == "FIELD_OFFICER" and task.assigned_to_user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. This field task is not assigned to your officer account."
        )

    parcel = db.query(LandParcel).filter(LandParcel.id == task.parcel_id).first()
    project = db.query(Project).filter(Project.id == task.project_id).first()

    if user.role in ["FIELD_OFFICER", "DISTRICT_AUTHORITY"] and project and user.district_id and project.district_id != user.district_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Task belongs to another district jurisdiction."
        )

    return {
        "id": task.id,
        "project_id": task.project_id,
        "project_name": project.project_name if project else None,
        "parcel": {
            "id": parcel.id,
            "parcel_number": parcel.parcel_number,
            "survey_number": parcel.survey_number,
            "village": parcel.village,
            "area_hectares": float(parcel.area_hectares) if parcel.area_hectares else 0.0,
            "owner_name": parcel.owner_name,
            "classification": parcel.classification,
            "boundary_coordinates": [
                [73.8567, 18.5204],
                [73.8575, 18.5210],
                [73.8580, 18.5200],
                [73.8567, 18.5204]
            ]
        } if parcel else None,
        "task_type": task.task_type,
        "checklist_schema": [
            { "id": "boundary_verified", "label": "Boundary Markers Verified", "type": "BOOLEAN" },
            { "id": "structure_count", "label": "Number of Structures Identified", "type": "NUMBER" },
            { "id": "tree_count", "label": "Number of Trees Enumerated", "type": "NUMBER" },
            { "id": "dispute_flag", "label": "Local Dispute / Objection Raised", "type": "BOOLEAN" }
        ],
        "priority": task.priority,
        "due_date": task.due_date.isoformat() if task.due_date else None,
        "status": task.status
    }

def create_field_visit(db: Session, user: User, visit_data: Dict[str, Any], request_ip: Optional[str] = None):
    task_id = visit_data["task_id"]
    task = db.query(FieldTask).filter(FieldTask.id == task_id).first()
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cannot start visit: Task #{task_id} does not exist."
        )

    # Server-enforced task assignment check
    if task.assigned_to_user_id and task.assigned_to_user_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot start visit: Task is assigned to another officer."
        )

    new_visit = FieldVisit(
        task_id=task_id,
        field_officer_id=user.id,  # STRICTLY from authenticated JWT user context
        visit_start=visit_data["visit_start"],
        latitude=visit_data.get("latitude"),
        longitude=visit_data.get("longitude"),
        accuracy_meters=visit_data.get("accuracy_meters"),
        status="IN_PROGRESS"
    )
    db.add(new_visit)
    db.flush()

    # Log audit event
    log_audit_event(
        db=db,
        action="FIELD_VISIT_CREATED",
        user_id=user.id,
        user_role=user.role,
        entity_type="FIELD_VISIT",
        entity_id=str(new_visit.id),
        request_ip=request_ip,
        new_value={
            "visit_id": new_visit.id,
            "task_id": task_id,
            "latitude": float(new_visit.latitude) if new_visit.latitude else None,
            "longitude": float(new_visit.longitude) if new_visit.longitude else None
        }
    )

    db.commit()
    db.refresh(new_visit)

    return {
        "visit_id": new_visit.id,
        "task_id": new_visit.task_id,
        "field_officer_id": new_visit.field_officer_id,
        "status": new_visit.status,
        "latitude": float(new_visit.latitude) if new_visit.latitude else None,
        "longitude": float(new_visit.longitude) if new_visit.longitude else None,
        "accuracy_meters": float(new_visit.accuracy_meters) if new_visit.accuracy_meters else None,
        "visit_start": new_visit.visit_start.isoformat() if new_visit.visit_start else None
    }

def get_field_visits(db: Session, user: User, task_id: Optional[int] = None):
    query = db.query(FieldVisit)
    if user.role == "FIELD_OFFICER":
        query = query.filter(FieldVisit.field_officer_id == user.id)
    if task_id:
        query = query.filter(FieldVisit.task_id == task_id)

    visits = query.order_by(FieldVisit.visit_start.desc()).all()
    results = []
    for v in visits:
        task = db.query(FieldTask).filter(FieldTask.id == v.task_id).first()
        parcel = db.query(LandParcel).filter(LandParcel.id == task.parcel_id).first() if task else None
        officer = db.query(User).filter(User.id == v.field_officer_id).first()
        results.append({
            "id": v.id,
            "task_id": v.task_id,
            "parcel_id": parcel.id if parcel else None,
            "parcel_number": parcel.parcel_number if parcel else None,
            "village": parcel.village if parcel else None,
            "field_officer_id": v.field_officer_id,
            "officer_name": officer.name if officer else "Field Officer",
            "visit_start": v.visit_start.isoformat() if v.visit_start else None,
            "visit_end": v.visit_end.isoformat() if v.visit_end else None,
            "latitude": float(v.latitude) if v.latitude else None,
            "longitude": float(v.longitude) if v.longitude else None,
            "accuracy_meters": float(v.accuracy_meters) if v.accuracy_meters else None,
            "status": v.status,
            "created_at": v.created_at.isoformat() if v.created_at else None
        })
    return results

def get_field_visit_by_id(db: Session, visit_id: int, user: User):
    visit = db.query(FieldVisit).filter(FieldVisit.id == visit_id).first()
    if not visit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Field visit #{visit_id} not found."
        )

    if user.role == "FIELD_OFFICER" and visit.field_officer_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. This visit was conducted by another officer."
        )

    task = db.query(FieldTask).filter(FieldTask.id == visit.task_id).first()
    parcel = db.query(LandParcel).filter(LandParcel.id == task.parcel_id).first() if task else None
    officer = db.query(User).filter(User.id == visit.field_officer_id).first()
    verifications = db.query(FieldVerification).filter(FieldVerification.visit_id == visit.id).all()
    photos = db.query(Document).filter(
        Document.related_entity.in_(["FIELD_PHOTO", "FIELD_VISIT"]),
        Document.related_entity_id.in_([visit.id, task.id if task else 0])
    ).all()

    return {
        "id": visit.id,
        "task_id": visit.task_id,
        "parcel_id": parcel.id if parcel else None,
        "parcel_number": parcel.parcel_number if parcel else None,
        "village": parcel.village if parcel else None,
        "officer_id": visit.field_officer_id,
        "officer_name": officer.name if officer else "Field Officer",
        "visit_start": visit.visit_start.isoformat() if visit.visit_start else None,
        "visit_end": visit.visit_end.isoformat() if visit.visit_end else None,
        "latitude": float(visit.latitude) if visit.latitude else None,
        "longitude": float(visit.longitude) if visit.longitude else None,
        "accuracy_meters": float(visit.accuracy_meters) if visit.accuracy_meters else None,
        "status": visit.status,
        "verifications_count": len(verifications),
        "photos": [
            {
                "id": p.id,
                "document_name": p.document_name,
                "url": f"/api/v1/documents/{p.id}/download",
                "file_size": p.file_size,
                "created_at": p.created_at.isoformat() if p.created_at else None
            }
            for p in photos
        ]
    }

def submit_field_verification(db: Session, user: User, verification_data: Dict[str, Any], request_ip: Optional[str] = None):
    client_event_id = verification_data["client_event_id"]

    # Check Idempotency in PostgreSQL
    existing = db.query(FieldVerification).filter(FieldVerification.client_event_id == client_event_id).first()
    if existing:
        log_audit_event(
            db=db,
            action="SYNC_DUPLICATE_REJECTED",
            user_id=user.id,
            user_role=user.role,
            entity_type="FIELD_VERIFICATION",
            entity_id=str(existing.id),
            request_ip=request_ip,
            new_value={"client_event_id": client_event_id, "note": "Duplicate replay rejected"}
        )
        db.commit()
        return {
            "verification_id": existing.id,
            "client_event_id": existing.client_event_id,
            "status": "SUBMITTED",
            "verified_at": existing.verified_at.isoformat() if existing.verified_at else None,
            "note": "Idempotent duplicate submission safely ignored."
        }

    task_id = verification_data["task_id"]
    task = db.query(FieldTask).filter(FieldTask.id == task_id).first()
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Task #{task_id} not found."
        )

    # Ensure valid visit_id foreign key in PostgreSQL
    visit_id = verification_data.get("visit_id")
    visit = db.query(FieldVisit).filter(FieldVisit.id == visit_id).first() if visit_id else None
    if not visit:
        latest_visit = db.query(FieldVisit).filter(FieldVisit.task_id == task_id).order_by(FieldVisit.id.desc()).first()
        if latest_visit:
            visit_id = latest_visit.id
        else:
            new_visit = FieldVisit(
                task_id=task_id,
                field_officer_id=user.id,
                visit_start=datetime.now(timezone.utc),
                latitude=verification_data.get("latitude", 18.5204),
                longitude=verification_data.get("longitude", 73.8567),
                status="COMPLETED"
            )
            db.add(new_visit)
            db.flush()
            visit_id = new_visit.id

    new_ver = FieldVerification(
        visit_id=visit_id,
        task_id=task_id,
        parcel_id=verification_data.get("parcel_id", task.parcel_id),
        checklist_data=verification_data.get("checklist_data"),
        remarks=verification_data.get("remarks"),
        client_event_id=client_event_id,
        device_id=verification_data.get("device_id")
    )
    db.add(new_ver)
    db.flush()

    # Update task status to SUBMITTED in PostgreSQL
    task.status = "SUBMITTED"

    # Log audit event
    log_audit_event(
        db=db,
        action="FIELD_VERIFICATION_SUBMITTED",
        user_id=user.id,
        user_role=user.role,
        entity_type="FIELD_VERIFICATION",
        entity_id=str(new_ver.id),
        request_ip=request_ip,
        new_value={
            "verification_id": new_ver.id,
            "task_id": task_id,
            "parcel_id": new_ver.parcel_id,
            "client_event_id": client_event_id
        }
    )

    db.commit()
    db.refresh(new_ver)

    return {
        "verification_id": new_ver.id,
        "client_event_id": new_ver.client_event_id,
        "task_id": new_ver.task_id,
        "visit_id": new_ver.visit_id,
        "status": "SUBMITTED",
        "verified_at": new_ver.verified_at.isoformat() if new_ver.verified_at else None
    }

def get_field_verifications(db: Session, user: User, task_id: Optional[int] = None):
    query = db.query(FieldVerification)
    if task_id:
        query = query.filter(FieldVerification.task_id == task_id)

    verifications = query.order_by(FieldVerification.verified_at.desc()).all()
    results = []
    for v in verifications:
        task = db.query(FieldTask).filter(FieldTask.id == v.task_id).first()
        parcel = db.query(LandParcel).filter(LandParcel.id == v.parcel_id).first()
        project = db.query(Project).filter(Project.id == task.project_id).first() if task else None
        visit = db.query(FieldVisit).filter(FieldVisit.id == v.visit_id).first()
        officer = db.query(User).filter(User.id == visit.field_officer_id).first() if visit else None

        # Attached photos
        photos = db.query(Document).filter(
            Document.related_entity.in_(["FIELD_PHOTO", "FIELD_VISIT"]),
            Document.related_entity_id.in_([v.visit_id, v.task_id, v.parcel_id])
        ).all()

        results.append({
            "id": v.id,
            "task_id": v.task_id,
            "task_type": task.task_type if task else "Field Verification",
            "project_name": project.project_name if project else None,
            "parcel_id": v.parcel_id,
            "parcel_number": parcel.parcel_number if parcel else None,
            "survey_number": parcel.survey_number if parcel else None,
            "village": parcel.village if parcel else None,
            "owner_name": parcel.owner_name if parcel else None,
            "visit_id": v.visit_id,
            "officer_name": officer.name if officer else "Field Officer",
            "officer_id": officer.id if officer else None,
            "latitude": float(visit.latitude) if visit and visit.latitude else 18.5204,
            "longitude": float(visit.longitude) if visit and visit.longitude else 73.8567,
            "checklist_data": v.checklist_data,
            "remarks": v.remarks,
            "client_event_id": v.client_event_id,
            "device_id": v.device_id,
            "verified_at": v.verified_at.isoformat() if v.verified_at else None,
            "status": task.status if task else "SUBMITTED",
            "photos": [
                {
                    "id": p.id,
                    "document_name": p.document_name,
                    "url": f"/api/v1/documents/{p.id}/download",
                    "file_size": p.file_size
                }
                for p in photos
            ]
        })
    return results

def get_field_photos(db: Session, user: User, related_entity_id: Optional[int] = None):
    query = db.query(Document).filter(Document.related_entity.in_(["FIELD_PHOTO", "FIELD_VISIT"]))
    if related_entity_id is not None:
        query = query.filter(Document.related_entity_id == related_entity_id)

    photos = query.order_by(Document.created_at.desc()).all()
    results = []
    for p in photos:
        uploader = db.query(User).filter(User.id == p.uploaded_by).first() if p.uploaded_by else None
        results.append({
            "id": p.id,
            "photo_id": p.id,
            "file_name": p.document_name,
            "file_type": p.file_type,
            "file_size": p.file_size,
            "url": f"/api/v1/documents/{p.id}/download",
            "related_entity": p.related_entity,
            "related_entity_id": p.related_entity_id,
            "uploaded_by_name": uploader.name if uploader else "Field Officer",
            "created_at": p.created_at.isoformat() if p.created_at else None
        })
    return results

def process_batch_sync(db: Session, user: User, sync_data: Dict[str, Any], request_ip: Optional[str] = None):
    events = sync_data.get("events", [])
    device_id = sync_data.get("device_id")

    results = []
    processed_count = 0
    duplicate_count = 0
    failed_count = 0

    for event in events:
        client_event_id = event["client_event_id"]

        # Check idempotency in sync_events table in PostgreSQL
        existing_sync = db.query(SyncEvent).filter(SyncEvent.client_event_id == client_event_id).first()
        if existing_sync:
            duplicate_count += 1
            results.append({
                "client_event_id": client_event_id,
                "status": "ALREADY_PROCESSED",
                "server_entity_id": None
            })
            log_audit_event(
                db=db,
                action="SYNC_DUPLICATE_REJECTED",
                user_id=user.id,
                user_role=user.role,
                entity_type="SYNC_EVENT",
                entity_id=client_event_id,
                request_ip=request_ip,
                new_value={"client_event_id": client_event_id}
            )
            continue

        try:
            payload = event.get("payload", {})
            event_type = event.get("event_type")

            if event_type == "FIELD_VERIFICATION":
                verification_data = {
                    "client_event_id": client_event_id,
                    "device_id": device_id,
                    "task_id": payload.get("task_id", 101),
                    "visit_id": payload.get("visit_id", 1),
                    "parcel_id": payload.get("parcel_id", 1),
                    "checklist_data": payload.get("checklist_data"),
                    "remarks": payload.get("remarks")
                }
                res = submit_field_verification(db, user, verification_data, request_ip=request_ip)
                server_id = res["verification_id"]
            else:
                server_id = None

            sync_record = SyncEvent(
                client_event_id=client_event_id,
                event_type=event_type,
                device_id=device_id,
                user_id=user.id,
                payload=payload,
                status="PROCESSED"
            )
            db.add(sync_record)
            
            log_audit_event(
                db=db,
                action="SYNC_PROCESSED",
                user_id=user.id,
                user_role=user.role,
                entity_type="SYNC_EVENT",
                entity_id=client_event_id,
                request_ip=request_ip,
                new_value={"event_type": event_type, "server_id": server_id}
            )

            db.commit()

            processed_count += 1
            results.append({
                "client_event_id": client_event_id,
                "status": "PROCESSED",
                "server_entity_id": server_id
            })

        except Exception as e:
            db.rollback()
            failed_count += 1
            results.append({
                "client_event_id": client_event_id,
                "status": "FAILED",
                "error": str(e)
            })

    return {
        "processed_count": processed_count,
        "duplicate_count": duplicate_count,
        "failed_count": failed_count,
        "processed": processed_count,
        "duplicate": duplicate_count,
        "failed": failed_count,
        "results": results
    }
