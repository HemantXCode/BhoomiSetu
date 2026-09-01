from sqlalchemy import Column, Integer, String, Text, Numeric, Date, DateTime, ForeignKey
from datetime import datetime, timezone
from app.database.session import Base

class AffectedFamily(Base):
    __tablename__ = "affected_families"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False, index=True)
    family_head = Column(String(200), nullable=False)
    total_members = Column(Integer, nullable=False, default=1)
    vulnerability_status = Column(String(50), nullable=False, default="GENERAL")  # BPL, SC_ST, GENERAL
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class DisplacedFamily(Base):
    __tablename__ = "displaced_families"

    id = Column(Integer, primary_key=True, index=True)
    affected_family_id = Column(Integer, ForeignKey("affected_families.id", ondelete="CASCADE"), nullable=False, index=True)
    resettlement_status = Column(String(50), nullable=False, default="PENDING")  # PENDING, ALLOTTED, RESETTLED
    grant_amount = Column(Numeric(12, 2), default=0.0)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))


class RehabilitationRecord(Base):
    __tablename__ = "rehabilitation_records"

    id = Column(Integer, primary_key=True, index=True)
    family_id = Column(Integer, ForeignKey("affected_families.id", ondelete="CASCADE"), nullable=False)
    assistance_type = Column(String(100), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    status = Column(String(50), nullable=False, default="DISBURSED")
    date = Column(Date, nullable=False)


class ResettlementRecord(Base):
    __tablename__ = "resettlement_records"

    id = Column(Integer, primary_key=True, index=True)
    family_id = Column(Integer, ForeignKey("affected_families.id", ondelete="CASCADE"), nullable=False)
    allotment_site = Column(String(200), nullable=False)
    plot_number = Column(String(50), nullable=False)
    possession_status = Column(String(50), nullable=False, default="HANDED_OVER")
    date = Column(Date, nullable=False)
