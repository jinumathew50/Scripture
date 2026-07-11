"""
Database table creation script for Supabase

Run this script to create all necessary tables in your Supabase PostgreSQL database.
Requires the supabase-py library and proper environment configuration.
"""

import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: Please set SUPABASE_URL and SUPABASE_KEY in your .env file")
    exit(1)

# Initialize Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# SQL statements for creating tables
TABLES_SQL = """
-- Marks table (highlights, bookmarks, notes)
CREATE TABLE IF NOT EXISTS marks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    device_id TEXT NOT NULL,
    bible_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter INTEGER NOT NULL,
    verse_start INTEGER NOT NULL,
    verse_end INTEGER,
    mark_type TEXT NOT NULL CHECK (mark_type IN ('highlight', 'bookmark', 'note')),
    color TEXT CHECK (color IN ('yellow', 'green', 'blue', 'pink', 'orange')),
    note_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading progress table
CREATE TABLE IF NOT EXISTS reading_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    device_id TEXT NOT NULL,
    bible_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(device_id, bible_id, book_id, chapter)
);

-- Enrollments table (reading plans)
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    device_id TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    plan_name TEXT NOT NULL,
    start_date DATE NOT NULL,
    duration_days INTEGER NOT NULL,
    completed_days INTEGER[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cache tables for Bible content (optional - can also use Supabase Edge Functions)
CREATE TABLE IF NOT EXISTS bibles_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bible_id TEXT UNIQUE NOT NULL,
    data JSONB NOT NULL,
    cached_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS books_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bible_id TEXT NOT NULL,
    data JSONB NOT NULL,
    cached_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS text_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    fileset_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter INTEGER NOT NULL,
    data JSONB NOT NULL,
    cached_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(fileset_id, book_id, chapter)
);

CREATE TABLE IF NOT EXISTS timestamps_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    fileset_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter INTEGER NOT NULL,
    data JSONB NOT NULL,
    cached_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(fileset_id, book_id, chapter)
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_marks_device_id ON marks(device_id);
CREATE INDEX IF NOT EXISTS idx_marks_bible_id ON marks(bible_id);
CREATE INDEX IF NOT EXISTS idx_marks_type ON marks(mark_type);
CREATE INDEX IF NOT EXISTS idx_progress_device_id ON reading_progress(device_id);
CREATE INDEX IF NOT EXISTS idx_progress_updated_at ON reading_progress(updated_at);
CREATE INDEX IF NOT EXISTS idx_enrollments_device_id ON enrollments(device_id);
"""


def create_tables():
    """Create all database tables"""
    print("Creating database tables...")
    
    try:
        # Execute the SQL statements
        # Note: Supabase Python client doesn't support raw SQL execution directly
        # You'll need to run this SQL in the Supabase Dashboard SQL Editor
        # or use the Supabase CLI
        
        print("\n" + "="*60)
        print("IMPORTANT: The Supabase Python client doesn't support raw SQL.")
        print("Please copy the SQL below and run it in your Supabase Dashboard:")
        print("1. Go to https://app.supabase.com")
        print("2. Select your project")
        print("3. Go to SQL Editor")
        print("4. Paste and run the SQL statements")
        print("="*60 + "\n")
        
        print(TABLES_SQL)
        
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False


if __name__ == "__main__":
    create_tables()
