from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class VisitCreateSchema(BaseModel):
    task_id: int
    visit_start: datetime
    latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)
    accuracy_meters: Optional[float] = Field(None, ge=0.0)

class VerificationCreateSchema(BaseModel):
    client_event_id: str
    device_id: Optional[str] = None
    task_id: int
    visit_id: int
    parcel_id: int
    latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)
    accuracy_meters: Optional[float] = Field(None, ge=0.0)
    checklist_data: Optional[Dict[str, Any]] = None
    remarks: Optional[str] = None
    photos: Optional[List[str]] = None

class SyncEventItem(BaseModel):
    client_event_id: str
    client_created_at: str
    event_type: str
    payload: Dict[str, Any]

class BatchSyncRequest(BaseModel):
    device_id: Optional[str] = None
    sync_timestamp: Optional[str] = None
    events: List[SyncEventItem]
