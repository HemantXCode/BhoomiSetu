from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database.session import Base

class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    project_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    agency_id = Column(Integer, ForeignKey("agencies.id", ondelete="RESTRICT"), nullable=False, index=True)
    state_id = Column(Integer, ForeignKey("states.id", ondelete="RESTRICT"), nullable=False, index=True)
    district_id = Column(Integer, ForeignKey("districts.id", ondelete="RESTRICT"), nullable=False, index=True)
    proposed_area = Column(Numeric(12, 2), nullable=False)
    status = Column(String(50), nullable=False, default="PROPOSED", index=True)
    start_date = Column(Date, nullable=True)
    expected_end_date = Column(Date, nullable=True)
    created_by = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    agency = relationship("Agency", back_populates="projects")
    state = relationship("State", back_populates="projects")
    district = relationship("District", back_populates="projects")
    milestones = relationship("ProjectMilestone", back_populates="project", cascade="all, delete-orphan")
    parcels = relationship("LandParcel", back_populates="project", cascade="all, delete-orphan")


class ProjectMilestone(Base):
    __tablename__ = "project_milestones"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    milestone_name = Column(String(255), nullable=False)
    status = Column(String(50), nullable=False, default="PENDING")
    progress_percentage = Column(Numeric(5, 2), default=0.0)
    expected_date = Column(Date, nullable=True)
    completed_date = Column(Date, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    project = relationship("Project", back_populates="milestones")
