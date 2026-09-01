from sqlalchemy import Column, Integer, String, Text, BigInteger, DateTime, ForeignKey
from datetime import datetime, timezone
from app.database.session import Base

class Document(Base):
    __tablename__ = "documents"

    id = Column(String(100), primary_key=True, index=True)  # UUID
    document_name = Column(String(255), nullable=False)
    file_type = Column(String(100), nullable=False)
    file_size = Column(BigInteger, nullable=False)
    storage_path = Column(String(500), nullable=False)
    uploaded_by = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    related_entity = Column(String(100), nullable=True)
    related_entity_id = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
