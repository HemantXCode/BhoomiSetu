from sqlalchemy import Column, Integer, String, Text, Numeric, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.types import TypeDecorator
from geoalchemy2 import Geometry
from datetime import datetime, timezone
from app.database.session import Base

class SpatialPoint(TypeDecorator):
    impl = Text
    cache_ok = True
    spatial_index = False
    name = "geometry"

    def load_dialect_impl(self, dialect):
        if dialect is not None and dialect.name == "postgresql":
            return dialect.type_descriptor(Geometry(geometry_type='POINT', srid=4326, spatial_index=False))
        return dialect.type_descriptor(Text) if dialect is not None else Text()

class FieldTask(Base):
    __tablename__ = "field_tasks"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)
    parcel_id = Column(Integer, ForeignKey("land_parcels.id", ondelete="CASCADE"), nullable=False, index=True)
    assigned_to_user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    task_type = Column(String(100), nullable=False)
    priority = Column(String(20), default="NORMAL")
    due_date = Column(DateTime(timezone=True), nullable=True)
    status = Column(String(50), default="PENDING", index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class FieldVisit(Base):
    __tablename__ = "field_visits"

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("field_tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    field_officer_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    visit_start = Column(DateTime(timezone=True), nullable=False)
    visit_end = Column(DateTime(timezone=True), nullable=True)
    location_point = Column(SpatialPoint, nullable=True)
    latitude = Column(Numeric(10, 6), nullable=True)
    longitude = Column(Numeric(10, 6), nullable=True)
    accuracy_meters = Column(Numeric(6, 2), nullable=True)
    status = Column(String(50), default="IN_PROGRESS")
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class FieldVerification(Base):
    __tablename__ = "field_verifications"

    id = Column(Integer, primary_key=True, index=True)
    visit_id = Column(Integer, ForeignKey("field_visits.id", ondelete="CASCADE"), nullable=False)
    task_id = Column(Integer, ForeignKey("field_tasks.id", ondelete="CASCADE"), nullable=False)
    parcel_id = Column(Integer, ForeignKey("land_parcels.id", ondelete="CASCADE"), nullable=False)
    checklist_data = Column(JSON, nullable=True)
    remarks = Column(Text, nullable=True)
    client_event_id = Column(String(100), nullable=False, unique=True, index=True)
    device_id = Column(String(100), nullable=True)
    verified_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class SyncEvent(Base):
    __tablename__ = "sync_events"

    client_event_id = Column(String(100), primary_key=True, index=True)
    event_type = Column(String(100), nullable=False)
    device_id = Column(String(100), nullable=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    payload = Column(JSON, nullable=False)
    status = Column(String(50), default="PROCESSED")
    processed_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
