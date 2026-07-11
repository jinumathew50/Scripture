from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ProgressBase(BaseModel):
    device_id: str
    bible_id: str
    book_id: str
    chapter: int
    verse: Optional[int] = None


class ProgressCreate(ProgressBase):
    pass


class Progress(ProgressBase):
    id: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class StreakInfo(BaseModel):
    current_streak: int
    total_days_read: int
    last_read_date: Optional[str] = None
