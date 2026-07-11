from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from datetime import datetime, timedelta, timezone
from database import get_supabase
from models.progress import ProgressCreate, Progress, StreakInfo

router = APIRouter(prefix="/api/progress", tags=["progress"])


def utc_now() -> str:
    """Get current UTC time as ISO format string"""
    return datetime.now(timezone.utc).isoformat()


@router.post("", response_model=Progress)
async def save_progress(progress: ProgressCreate):
    """Save reading progress (auto-saves when user reads a chapter)"""
    supabase = get_supabase()
    
    try:
        # Check if progress exists for this device + bible + book + chapter
        existing = supabase.table("reading_progress").select("*").eq(
            "device_id", progress.device_id
        ).eq("bible_id", progress.bible_id).eq("book_id", progress.book_id).eq(
            "chapter", progress.chapter
        ).execute()
        
        data = {
            "device_id": progress.device_id,
            "bible_id": progress.bible_id,
            "book_id": progress.book_id,
            "chapter": progress.chapter,
            "verse": progress.verse,
            "updated_at": utc_now(),
        }
        
        if existing.data and len(existing.data) > 0:
            # Update existing
            result = supabase.table("reading_progress").update(data).eq(
                "id", existing.data[0]["id"]
            ).execute()
        else:
            # Insert new
            data["created_at"] = utc_now()
            result = supabase.table("reading_progress").insert(data).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to save progress")
        
        return Progress(**result.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=dict)
async def get_progress(
    device_id: str = Query(..., description="Device ID for guest mode"),
    bible_id: Optional[str] = Query(None, description="Filter by Bible"),
):
    """Get user's last read position and streak info"""
    supabase = get_supabase()
    
    try:
        # Get last read position
        query = supabase.table("reading_progress").select("*").eq(
            "device_id", device_id
        ).order("updated_at", desc=True).limit(1)
        
        if bible_id:
            query = query.eq("bible_id", bible_id)
        
        result = query.execute()
        
        last_read = None
        if result.data and len(result.data) > 0:
            last_read = Progress(**result.data[0])
        
        # Calculate streak
        today = datetime.now(timezone.utc).date()
        
        # Get all unique reading days in the past
        thirty_days_ago = today - timedelta(days=30)
        streak_result = supabase.table("reading_progress").select(
            "updated_at"
        ).eq("device_id", device_id).gte(
            "updated_at", thirty_days_ago.isoformat()
        ).execute()
        
        # Count unique days
        unique_days = set()
        if streak_result.data:
            for item in streak_result.data:
                day_str = item["updated_at"][:10]  # YYYY-MM-DD
                unique_days.add(day_str)
        
        # Calculate current streak
        current_streak = 0
        for i in range(365):
            day = today - timedelta(days=i)
            if day.isoformat() in unique_days:
                current_streak += 1
            else:
                break
        
        total_days_read = len(unique_days)
        last_read_date = None
        if result.data and len(result.data) > 0:
            last_read_date = result.data[0]["updated_at"][:10]
        
        return {
            "last_read": last_read,
            "streak": StreakInfo(
                current_streak=current_streak,
                total_days_read=total_days_read,
                last_read_date=last_read_date,
            ),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
