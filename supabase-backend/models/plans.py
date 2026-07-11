from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class PlanDay(BaseModel):
    day_number: int
    readings: List[dict]  # [{book_id, chapter}, ...]
    is_completed: bool = False
    is_current: bool = False


class CuratedPlan(BaseModel):
    id: str
    name: str
    description: str
    duration_days: int
    testaments: List[str]  # ["old", "new", "both"]
    books: List[str]  # book_ids included


class CustomPlanCreate(BaseModel):
    device_id: str
    name: str
    book_id: str
    duration_days: int


class EnrollmentBase(BaseModel):
    device_id: str
    plan_id: str
    plan_name: str
    start_date: str
    duration_days: int


class Enrollment(EnrollmentBase):
    id: str
    created_at: datetime
    completed_days: List[int] = []
    
    class Config:
        from_attributes = True


class EnrollmentDetail(Enrollment):
    current_day: int
    total_days: int
    progress_percentage: float
    days: List[PlanDay]
