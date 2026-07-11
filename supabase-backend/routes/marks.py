from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Optional, List
from datetime import datetime
from database import get_supabase
from models.marks import MarkCreate, MarkUpdate, Mark, MarkType, HighlightColor

router = APIRouter(prefix="/api/marks", tags=["marks"])


@router.post("", response_model=Mark)
async def create_mark(mark: MarkCreate):
    """Create a highlight, bookmark, or note"""
    supabase = get_supabase()
    
    try:
        data = {
            "device_id": mark.device_id,
            "bible_id": mark.bible_id,
            "book_id": mark.book_id,
            "chapter": mark.chapter,
            "verse_start": mark.verse_start,
            "verse_end": mark.verse_end,
            "mark_type": mark.mark_type.value,
            "color": mark.color.value if mark.color else None,
            "note_text": mark.note_text,
        }
        
        result = supabase.table("marks").insert(data).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to create mark")
        
        return Mark(**result.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=List[Mark])
async def get_marks(
    device_id: str = Query(..., description="Device ID for guest mode"),
    mark_type: Optional[MarkType] = Query(None, description="Filter by type"),
    bible_id: Optional[str] = Query(None, description="Filter by Bible"),
):
    """Get user marks with optional filters"""
    supabase = get_supabase()
    
    try:
        query = supabase.table("marks").select("*").eq("device_id", device_id)
        
        if mark_type:
            query = query.eq("mark_type", mark_type.value)
        
        if bible_id:
            query = query.eq("bible_id", bible_id)
        
        query = query.order("created_at", desc=True)
        
        result = query.execute()
        
        return [Mark(**item) for item in result.data]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.patch("/{mark_id}", response_model=Mark)
async def update_mark(mark_id: str, mark_update: MarkUpdate):
    """Update a mark (color or note)"""
    supabase = get_supabase()
    
    try:
        update_data = {}
        if mark_update.color:
            update_data["color"] = mark_update.color.value
        if mark_update.note_text is not None:
            update_data["note_text"] = mark_update.note_text
        update_data["updated_at"] = datetime.utcnow().isoformat()
        
        result = supabase.table("marks").update(update_data).eq("id", mark_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Mark not found")
        
        return Mark(**result.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{mark_id}")
async def delete_mark(mark_id: str):
    """Delete a mark"""
    supabase = get_supabase()
    
    try:
        result = supabase.table("marks").delete().eq("id", mark_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Mark not found")
        
        return {"message": "Mark deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
