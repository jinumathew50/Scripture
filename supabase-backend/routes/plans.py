from fastapi import APIRouter, HTTPException, Query, Body
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from database import get_supabase
from models.plans import (
    CuratedPlan, CustomPlanCreate, Enrollment, EnrollmentDetail, PlanDay
)

router = APIRouter(prefix="/api/plans", tags=["plans"])


def utc_now() -> str:
    """Get current UTC time as ISO format string"""
    return datetime.now(timezone.utc).isoformat()


def utc_today():
    """Get current UTC date"""
    return datetime.now(timezone.utc).date()


# Curated reading plans
CURATED_PLANS = [
    CuratedPlan(
        id="nt-90-days",
        name="New Testament in 90 Days",
        description="Read through the entire New Testament in 90 days",
        duration_days=90,
        testaments=["new"],
        books=["MAT", "MRK", "LUK", "JHN", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS", "1PE", "2PE", "1JN", "2JN", "3JN", "JUD", "REV"]
    ),
    CuratedPlan(
        id="psalms-proverbs-60",
        name="Psalms & Proverbs in 60 Days",
        description="Walk through wisdom and worship in 60 days",
        duration_days=60,
        testaments=["old"],
        books=["PSA", "PRO"]
    ),
    CuratedPlan(
        id="life-of-jesus-40",
        name="Life of Jesus in 40 Days",
        description="Follow Jesus' life through the Gospels",
        duration_days=40,
        testaments=["new"],
        books=["MAT", "MRK", "LUK", "JHN"]
    ),
    CuratedPlan(
        id="john-21-days",
        name="Gospel of John in 21 Days",
        description="Deep dive into John's Gospel",
        duration_days=21,
        testaments=["new"],
        books=["JHN"]
    ),
    CuratedPlan(
        id="romans-16-days",
        name="Book of Romans in 16 Days",
        description="Study Paul's masterpiece letter",
        duration_days=16,
        testaments=["new"],
        books=["ROM"]
    ),
    CuratedPlan(
        id="four-gospels-40",
        name="Four Gospels in 40 Days",
        description="Read all four Gospels in 40 days",
        duration_days=40,
        testaments=["new"],
        books=["MAT", "MRK", "LUK", "JHN"]
    ),
]


@router.get("/curated", response_model=List[CuratedPlan])
async def list_curated_plans():
    """Get all curated reading plans"""
    return CURATED_PLANS


@router.get("/books")
async def get_book_options():
    """Get all 66 Bible books for custom plan creation"""
    OLD_TESTAMENT = [
        {"id": "GEN", "name": "Genesis", "chapters": 50},
        {"id": "EXO", "name": "Exodus", "chapters": 40},
        {"id": "LEV", "name": "Leviticus", "chapters": 27},
        {"id": "NUM", "name": "Numbers", "chapters": 36},
        {"id": "DEU", "name": "Deuteronomy", "chapters": 34},
        {"id": "JOS", "name": "Joshua", "chapters": 24},
        {"id": "JDG", "name": "Judges", "chapters": 21},
        {"id": "RUT", "name": "Ruth", "chapters": 4},
        {"id": "1SA", "name": "1 Samuel", "chapters": 31},
        {"id": "2SA", "name": "2 Samuel", "chapters": 24},
        {"id": "1KI", "name": "1 Kings", "chapters": 22},
        {"id": "2KI", "name": "2 Kings", "chapters": 25},
        {"id": "1CH", "name": "1 Chronicles", "chapters": 29},
        {"id": "2CH", "name": "2 Chronicles", "chapters": 36},
        {"id": "EZR", "name": "Ezra", "chapters": 10},
        {"id": "NEH", "name": "Nehemiah", "chapters": 13},
        {"id": "EST", "name": "Esther", "chapters": 10},
        {"id": "JOB", "name": "Job", "chapters": 42},
        {"id": "PSA", "name": "Psalms", "chapters": 150},
        {"id": "PRO", "name": "Proverbs", "chapters": 31},
        {"id": "ECC", "name": "Ecclesiastes", "chapters": 12},
        {"id": "SNG", "name": "Song of Solomon", "chapters": 8},
        {"id": "ISA", "name": "Isaiah", "chapters": 66},
        {"id": "JER", "name": "Jeremiah", "chapters": 52},
        {"id": "LAM", "name": "Lamentations", "chapters": 5},
        {"id": "EZK", "name": "Ezekiel", "chapters": 48},
        {"id": "DAN", "name": "Daniel", "chapters": 12},
        {"id": "HOS", "name": "Hosea", "chapters": 14},
        {"id": "JOL", "name": "Joel", "chapters": 3},
        {"id": "AMO", "name": "Amos", "chapters": 9},
        {"id": "OBA", "name": "Obadiah", "chapters": 1},
        {"id": "JON", "name": "Jonah", "chapters": 4},
        {"id": "MIC", "name": "Micah", "chapters": 7},
        {"id": "NAM", "name": "Nahum", "chapters": 3},
        {"id": "HAB", "name": "Habakkuk", "chapters": 3},
        {"id": "ZEP", "name": "Zephaniah", "chapters": 3},
        {"id": "HAG", "name": "Haggai", "chapters": 2},
        {"id": "ZEC", "name": "Zechariah", "chapters": 14},
        {"id": "MAL", "name": "Malachi", "chapters": 4},
    ]
    
    NEW_TESTAMENT = [
        {"id": "MAT", "name": "Matthew", "chapters": 28},
        {"id": "MRK", "name": "Mark", "chapters": 16},
        {"id": "LUK", "name": "Luke", "chapters": 24},
        {"id": "JHN", "name": "John", "chapters": 21},
        {"id": "ACT", "name": "Acts", "chapters": 28},
        {"id": "ROM", "name": "Romans", "chapters": 16},
        {"id": "1CO", "name": "1 Corinthians", "chapters": 16},
        {"id": "2CO", "name": "2 Corinthians", "chapters": 13},
        {"id": "GAL", "name": "Galatians", "chapters": 6},
        {"id": "EPH", "name": "Ephesians", "chapters": 6},
        {"id": "PHP", "name": "Philippians", "chapters": 4},
        {"id": "COL", "name": "Colossians", "chapters": 4},
        {"id": "1TH", "name": "1 Thessalonians", "chapters": 5},
        {"id": "2TH", "name": "2 Thessalonians", "chapters": 3},
        {"id": "1TI", "name": "1 Timothy", "chapters": 6},
        {"id": "2TI", "name": "2 Timothy", "chapters": 4},
        {"id": "TIT", "name": "Titus", "chapters": 3},
        {"id": "PHM", "name": "Philemon", "chapters": 1},
        {"id": "HEB", "name": "Hebrews", "chapters": 13},
        {"id": "JAS", "name": "James", "chapters": 5},
        {"id": "1PE", "name": "1 Peter", "chapters": 5},
        {"id": "2PE", "name": "2 Peter", "chapters": 3},
        {"id": "1JN", "name": "1 John", "chapters": 5},
        {"id": "2JN", "name": "2 John", "chapters": 1},
        {"id": "3JN", "name": "3 John", "chapters": 1},
        {"id": "JUD", "name": "Jude", "chapters": 1},
        {"id": "REV", "name": "Revelation", "chapters": 22},
    ]
    
    return {"old_testament": OLD_TESTAMENT, "new_testament": NEW_TESTAMENT}


def generate_plan_days(plan_id: str, book_id: str, duration_days: int) -> List[PlanDay]:
    """Generate reading schedule for a custom plan"""
    # Get chapter count for the book
    books_map = {b["id"]: b for b in [
        *CURATED_PLANS[0].books,  # Just using as example
    ]}
    
    # Simplified: distribute chapters evenly
    total_chapters = 28  # Default, would lookup actual
    chapters_per_day = max(1, total_chapters // duration_days)
    
    days = []
    for day_num in range(1, duration_days + 1):
        start_chapter = (day_num - 1) * chapters_per_day + 1
        end_chapter = min(day_num * chapters_per_day, total_chapters)
        
        readings = [{"book_id": book_id, "chapter": ch} for ch in range(start_chapter, end_chapter + 1)]
        
        days.append(PlanDay(
            day_number=day_num,
            readings=readings,
            is_completed=False,
            is_current=(day_num == 1)
        ))
    
    return days


@router.post("/enroll", response_model=Enrollment)
async def enroll_in_plan(enrollment_data: CustomPlanCreate):
    """Enroll in a reading plan (idempotent for curated plans)"""
    supabase = get_supabase()
    
    try:
        # Check if already enrolled in this plan
        existing = supabase.table("enrollments").select("*").eq(
            "device_id", enrollment_data.device_id
        ).eq("plan_id", enrollment_data.book_id).execute()
        
        if existing.data and len(existing.data) > 0:
            # Return existing enrollment (idempotency)
            return Enrollment(**existing.data[0])
        
        # Create new enrollment
        data = {
            "device_id": enrollment_data.device_id,
            "plan_id": enrollment_data.book_id,
            "plan_name": f"Custom: {enrollment_data.book_id}",
            "start_date": utc_today().isoformat(),
            "duration_days": enrollment_data.duration_days,
            "created_at": utc_now(),
            "completed_days": [],
        }
        
        result = supabase.table("enrollments").insert(data).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to enroll")
        
        return Enrollment(**result.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=List[Enrollment])
async def list_enrollments(device_id: str = Query(...)):
    """Get all enrolled plans for a device"""
    supabase = get_supabase()
    
    try:
        result = supabase.table("enrollments").select("*").eq(
            "device_id", device_id
        ).order("created_at", desc=True).execute()
        
        return [Enrollment(**item) for item in result.data]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{enrollment_id}", response_model=EnrollmentDetail)
async def get_enrollment_detail(enrollment_id: str):
    """Get detailed plan progress with all days"""
    supabase = get_supabase()
    
    try:
        result = supabase.table("enrollments").select("*").eq(
            "id", enrollment_id
        ).execute()
        
        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Enrollment not found")
        
        enrollment = result.data[0]
        
        # Calculate current day
        start_date = datetime.fromisoformat(enrollment["start_date"]).date()
        today = utc_today()
        days_elapsed = (today - start_date).days + 1
        current_day = min(days_elapsed, enrollment["duration_days"])
        
        # Generate days
        days = generate_plan_days(
            enrollment["plan_id"],
            enrollment["plan_id"],  # Using plan_id as book_id for simplicity
            enrollment["duration_days"]
        )
        
        # Mark completed days
        completed_days = enrollment.get("completed_days", [])
        for day in days:
            day.is_completed = day.day_number in completed_days
            day.is_current = (day.day_number == current_day)
        
        progress_pct = (len(completed_days) / enrollment["duration_days"]) * 100
        
        return EnrollmentDetail(
            **enrollment,
            current_day=current_day,
            total_days=enrollment["duration_days"],
            progress_percentage=progress_pct,
            days=days
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{enrollment_id}/complete")
async def complete_day(enrollment_id: str, day_number: int = Body(..., embed=True)):
    """Mark a day as completed"""
    supabase = get_supabase()
    
    try:
        result = supabase.table("enrollments").select("*").eq(
            "id", enrollment_id
        ).execute()
        
        if not result.data or len(result.data) == 0:
            raise HTTPException(status_code=404, detail="Enrollment not found")
        
        enrollment = result.data[0]
        completed_days = enrollment.get("completed_days", [])
        
        if day_number not in completed_days:
            completed_days.append(day_number)
            
            update_result = supabase.table("enrollments").update({
                "completed_days": completed_days
            }).eq("id", enrollment_id).execute()
            
            if not update_result.data:
                raise HTTPException(status_code=500, detail="Failed to update")
        
        return {"message": "Day marked as complete", "completed_days": completed_days}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{enrollment_id}")
async def delete_enrollment(enrollment_id: str):
    """Delete/unenroll from a plan"""
    supabase = get_supabase()
    
    try:
        result = supabase.table("enrollments").delete().eq(
            "id", enrollment_id
        ).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Enrollment not found")
        
        return {"message": "Enrollment deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
