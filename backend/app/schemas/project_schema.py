from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

class ProjectCreateSchema(BaseModel):
    project_name: str
    description: Optional[str] = None
    agency_id: Optional[int] = None
    state_id: int
    district_id: int
    proposed_area: float
    status: Optional[str] = "PROPOSED"
    start_date: Optional[date] = None
    expected_end_date: Optional[date] = None

class ProjectResponseSchema(BaseModel):
    id: int
    project_name: str
    description: Optional[str] = None
    agency_id: int
    agency_name: Optional[str] = None
    state_id: int
    state_name: Optional[str] = None
    district_id: int
    district_name: Optional[str] = None
    proposed_area: float
    status: str
    start_date: Optional[date] = None
    expected_end_date: Optional[date] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
