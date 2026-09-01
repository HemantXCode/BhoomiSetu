from pydantic import BaseModel, ConfigDict
from typing import Optional

class LoginRequest(BaseModel):
    email: str
    password: str

class UserCreateRequest(BaseModel):
    name: str
    email: str
    password: str
    role: str = "FIELD_OFFICER"
    official_id: Optional[str] = None
    official_id_type: Optional[str] = "OTHER_OFFICIAL_ID"
    department: Optional[str] = None
    designation: Optional[str] = None
    phone: Optional[str] = None
    state_id: Optional[int] = None
    district_id: Optional[int] = None
    agency_id: Optional[int] = None
    is_demo: Optional[bool] = False

class UserVerifyRequest(BaseModel):
    decision: str  # VERIFIED, REJECTED, SUSPENDED, UNDER_REVIEW
    verification_method: Optional[str] = "MANUAL_AUTHORITY_REVIEW"  # MANUAL_AUTHORITY_REVIEW, GOVERNMENT_API, GOVERNMENT_PORTAL_REFERENCE
    verification_reference: Optional[str] = None
    notes: Optional[str] = None

class UserSchema(BaseModel):
    id: int
    name: str
    email: str
    role: str
    official_id_masked: Optional[str] = None
    official_id_type: Optional[str] = None
    identity_status: Optional[str] = "PENDING"
    department: Optional[str] = None
    designation: Optional[str] = None
    phone: Optional[str] = None
    state_id: Optional[int] = None
    state_name: Optional[str] = None
    state_code: Optional[str] = None
    district_id: Optional[int] = None
    district_name: Optional[str] = None
    district_code: Optional[str] = None
    agency_id: Optional[int] = None
    agency_name: Optional[str] = None
    agency_type: Optional[str] = None
    is_demo: Optional[bool] = False

    model_config = ConfigDict(from_attributes=True)

class LoginResponseData(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserSchema
