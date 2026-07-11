from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class MarkType(str, Enum):
    HIGHLIGHT = "highlight"
    BOOKMARK = "bookmark"
    NOTE = "note"


class HighlightColor(str, Enum):
    YELLOW = "yellow"
    GREEN = "green"
    BLUE = "blue"
    PINK = "pink"
    ORANGE = "orange"


class MarkBase(BaseModel):
    device_id: str
    bible_id: str
    book_id: str
    chapter: int
    verse_start: int
    verse_end: Optional[int] = None
    mark_type: MarkType
    color: Optional[HighlightColor] = None
    note_text: Optional[str] = None


class MarkCreate(MarkBase):
    pass


class MarkUpdate(BaseModel):
    color: Optional[HighlightColor] = None
    note_text: Optional[str] = None


class Mark(MarkBase):
    id: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
