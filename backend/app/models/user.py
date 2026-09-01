from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database.session import Base

class State(Base):
    __tablename__ = "states"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, unique=True)
    code = Column(String(10), nullable=False, unique=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    districts = relationship("District", back_populates="state", cascade="all, delete-orphan")
    agencies = relationship("Agency", back_populates="state")
    users = relationship("User", foreign_keys="[User.state_id]", back_populates="state")
    projects = relationship("Project", back_populates="state")


class District(Base):
    __tablename__ = "districts"

    id = Column(Integer, primary_key=True, index=True)
    state_id = Column(Integer, ForeignKey("states.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(100), nullable=False)
    code = Column(String(10), nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    state = relationship("State", back_populates="districts")
    users = relationship("User", foreign_keys="[User.district_id]", back_populates="district")
    projects = relationship("Project", back_populates="district")

    __table_args__ = (
        UniqueConstraint('state_id', 'code', name='unique_state_district_code'),
    )


class Agency(Base):
    __tablename__ = "agencies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    type = Column(String(100), nullable=False)  # CENTRAL_PSU, STATE_PSU, STATE_JOINT_PSU
    state_id = Column(Integer, ForeignKey("states.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    state = relationship("State", back_populates="agencies")
    users = relationship("User", foreign_keys="[User.agency_id]", back_populates="agency")
    projects = relationship("Project", back_populates="agency")


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    email = Column(String(255), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False, index=True)  # CENTRAL_MINISTRY, STATE_GOVERNMENT, DISTRICT_AUTHORITY, PROJECT_AGENCY, FIELD_OFFICER
    state_id = Column(Integer, ForeignKey("states.id", ondelete="SET NULL"), nullable=True)
    district_id = Column(Integer, ForeignKey("districts.id", ondelete="SET NULL"), nullable=True)
    agency_id = Column(Integer, ForeignKey("agencies.id", ondelete="SET NULL"), nullable=True)
    
    # Official Identity Lifecycle
    official_id = Column(String(100), nullable=True, index=True)
    official_id_type = Column(String(50), nullable=True)  # STATE_REVENUE_EMP_ID, NHAI_OFFICER_ID, NIC_GOV_ID, MINISTRY_OFFICIAL_ID, OTHER_OFFICIAL_ID
    identity_status = Column(String(20), default="PENDING", nullable=False, index=True)  # PENDING, UNDER_REVIEW, VERIFIED, REJECTED, SUSPENDED
    department = Column(String(150), nullable=True)
    designation = Column(String(150), nullable=True)
    phone = Column(String(20), nullable=True)
    verified_at = Column(DateTime(timezone=True), nullable=True)
    verified_by = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    verification_method = Column(String(50), default="MANUAL_AUTHORITY_REVIEW", nullable=True)  # MANUAL_AUTHORITY_REVIEW, GOVERNMENT_API, GOVERNMENT_PORTAL_REFERENCE
    verification_reference = Column(String(100), nullable=True)
    verification_notes = Column(String(255), nullable=True)
    rejection_reason = Column(String(255), nullable=True)
    suspension_reason = Column(String(255), nullable=True)
    
    is_active = Column(Boolean, default=True)
    is_demo = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    state = relationship("State", foreign_keys=[state_id], back_populates="users")
    district = relationship("District", foreign_keys=[district_id], back_populates="users")
    agency = relationship("Agency", foreign_keys=[agency_id], back_populates="users")
