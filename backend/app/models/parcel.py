from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.types import TypeDecorator
from geoalchemy2 import Geometry
from datetime import datetime, timezone
from app.database.session import Base

class SpatialPolygon(TypeDecorator):
    impl = Text
    cache_ok = True
    spatial_index = False
    name = "geometry"

    def load_dialect_impl(self, dialect):
        if dialect is not None and dialect.name == "postgresql":
            return dialect.type_descriptor(Geometry(geometry_type='POLYGON', srid=4326, spatial_index=False))
        return dialect.type_descriptor(Text) if dialect is not None else Text()

class LandParcel(Base):
    __tablename__ = "land_parcels"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)
    parcel_number = Column(String(100), nullable=False, unique=True)
    survey_number = Column(String(100), nullable=False)
    village = Column(String(100), nullable=False)
    state_id = Column(Integer, ForeignKey("states.id", ondelete="RESTRICT"), nullable=False)
    district_id = Column(Integer, ForeignKey("districts.id", ondelete="RESTRICT"), nullable=False)
    area_hectares = Column(Numeric(10, 4), nullable=False)
    classification = Column(String(50), nullable=False, default="AGRICULTURAL")
    owner_name = Column(String(200), nullable=False)
    status = Column(String(50), nullable=False, default="IDENTIFIED")
    geometry = Column(SpatialPolygon, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    project = relationship("Project", back_populates="parcels")
    surveys = relationship("ParcelSurvey", back_populates="parcel", cascade="all, delete-orphan")


class ParcelSurvey(Base):
    __tablename__ = "parcel_surveys"

    id = Column(Integer, primary_key=True, index=True)
    parcel_id = Column(Integer, ForeignKey("land_parcels.id", ondelete="CASCADE"), nullable=False)
    surveyor_name = Column(String(150), nullable=False)
    survey_date = Column(Date, nullable=False)
    status = Column(String(50), nullable=False, default="COMPLETED")
    remarks = Column(Text, nullable=True)
    geometry = Column(SpatialPolygon, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    parcel = relationship("LandParcel", back_populates="surveys")
