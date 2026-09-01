from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database.session import Base

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)
    notification_type = Column(String(50), nullable=False)  # SECTION_4, SECTION_11, SECTION_19
    gazette_number = Column(String(100), nullable=False)
    issue_date = Column(Date, nullable=False)
    document_url = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class Award(Base):
    __tablename__ = "awards"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)
    award_number = Column(String(100), nullable=False, unique=True)
    total_compensation_cr = Column(Numeric(12, 2), nullable=False)
    award_date = Column(Date, nullable=False)
    status = Column(String(50), nullable=False, default="DECLARED")  # DRAFT, DECLARED, DISBURSED
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class CompensationAssessment(Base):
    __tablename__ = "compensation_assessments"

    id = Column(Integer, primary_key=True, index=True)
    parcel_id = Column(Integer, ForeignKey("land_parcels.id", ondelete="CASCADE"), nullable=False, index=True)
    land_value = Column(Numeric(12, 2), nullable=False)
    structure_value = Column(Numeric(12, 2), default=0.0)
    solatium = Column(Numeric(12, 2), default=0.0)
    total_amount = Column(Numeric(12, 2), nullable=False)
    status = Column(String(50), nullable=False, default="APPROVED")
    calculated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class CompensationPayment(Base):
    __tablename__ = "compensation_payments"

    id = Column(Integer, primary_key=True, index=True)
    assessment_id = Column(Integer, ForeignKey("compensation_assessments.id", ondelete="CASCADE"), nullable=False)
    beneficiary_name = Column(String(200), nullable=False)
    bank_account = Column(String(100), nullable=False)
    total_amount = Column(Numeric(12, 2), nullable=False)
    payment_status = Column(String(50), nullable=False, default="PAID")
    dbt_utr_number = Column(String(100), nullable=True, unique=True)
    paid_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
