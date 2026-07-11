from fastapi import APIRouter, HTTPException, Query
from typing import Optional, List
import httpx
from datetime import datetime
from config import settings

router = APIRouter(prefix="/api/bible", tags=["bible"])

BIBLE_BRAIN_BASE = "https://dbt.io/api/v4"


# Deterministic verse of the day based on date
VERSES_OF_THE_DAY = [
    {"reference": "John 3:16", "text": "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have eternal life."},
    {"reference": "Psalm 23:1", "text": "The LORD is my shepherd; I shall not want."},
    {"reference": "Philippians 4:13", "text": "I can do all things through Christ which strengtheneth me."},
    {"reference": "Jeremiah 29:11", "text": "For I know the thoughts that I think toward you, saith the LORD, thoughts of peace, and not of evil, to give you an expected end."},
    {"reference": "Romans 8:28", "text": "And we know that all things work together for good to them that love God, to them who are the called according to his purpose."},
]


@router.get("/verse-of-the-day")
async def get_verse_of_the_day(fileset_id: Optional[str] = Query(None, description="Fileset ID for translation")):
    """Get deterministic daily verse based on date"""
    day_of_year = datetime.now().timetuple().tm_yday
    verse_index = (day_of_year - 1) % len(VERSES_OF_THE_DAY)
    return VERSES_OF_THE_DAY[verse_index]


@router.get("/bibles")
async def list_bibles(language_code: Optional[str] = Query(None, description="Filter by language code")):
    """List available Bibles from Bible Brain"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        params = {"key": settings.bible_brain_api_key}
        if language_code:
            params["language_code"] = language_code
        
        response = await client.get(f"{BIBLE_BRAIN_BASE}/bibles", params=params)
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch Bibles")
        
        return response.json()


@router.get("/bibles/{bible_id}")
async def get_bible_details(bible_id: str):
    """Get Bible details including filesets"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/bibles/{bible_id}",
            params={"key": settings.bible_brain_api_key}
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Bible not found")
        
        return response.json()


@router.get("/books/{bible_id}")
async def get_books(bible_id: str):
    """Get all books for a Bible with chapter counts"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/books",
            params={"key": settings.bible_brain_api_key, "bible_id": bible_id}
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch books")
        
        return response.json()


@router.get("/text/{fileset_id}/{book_id}/{chapter}")
async def get_chapter_text(fileset_id: str, book_id: str, chapter: int):
    """Get chapter verses (cached via Supabase)"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/verses",
            params={
                "key": settings.bible_brain_api_key,
                "fileset_id": fileset_id,
                "book_id": book_id,
                "chapter": chapter
            }
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch text")
        
        return response.json()


@router.get("/audio/{fileset_id}/{book_id}/{chapter}")
async def get_audio_stream(fileset_id: str, book_id: str, chapter: int):
    """Get signed audio streaming URL (not cached)"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/filesets/{fileset_id}/files",
            params={
                "key": settings.bible_brain_api_key,
                "book_id": book_id,
                "chapter": chapter
            }
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch audio")
        
        data = response.json()
        if data.get("data"):
            return {"url": data["data"][0]["path"]}
        
        raise HTTPException(status_code=404, detail="Audio not found")


@router.get("/timestamps/{fileset_id}/{book_id}/{chapter}")
async def get_timestamps(fileset_id: str, book_id: str, chapter: int):
    """Get verse timing data for karaoke highlighting"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/filesets/{fileset_id}/timestamps",
            params={
                "key": settings.bible_brain_api_key,
                "book_id": book_id,
                "chapter": chapter
            }
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Failed to fetch timestamps")
        
        return response.json()


@router.get("/search")
async def search_bible(query: str, fileset_id: Optional[str] = Query(None)):
    """Full-text verse search"""
    if not settings.bible_brain_api_key:
        raise HTTPException(status_code=500, detail="Bible Brain API key not configured")
    
    async with httpx.AsyncClient() as client:
        params = {
            "key": settings.bible_brain_api_key,
            "query": query,
            "limit": 50
        }
        if fileset_id:
            params["fileset_id"] = fileset_id
        
        response = await client.get(
            f"{BIBLE_BRAIN_BASE}/search",
            params=params
        )
        if response.status_code != 200:
            raise HTTPException(status_code=response.status_code, detail="Search failed")
        
        return response.json()
