from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..database import Base

class LegalQuery(Base):
    __tablename__ = "legal_queries"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    query = Column(Text, nullable=False)
    response = Column(Text, nullable=True)
    category = Column(String, nullable=True)
    is_saved = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    # user = relationship("User", back_populates="legal_queries")