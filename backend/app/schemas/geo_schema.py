from pydantic import BaseModel
from typing import Optional

class StateSchema(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class DistrictSchema(BaseModel):
    id: int
    state_id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class AgencySchema(BaseModel):
    id: int
    name: str
    type: str
    state_id: Optional[int] = None

    class Config:
        from_attributes = True
