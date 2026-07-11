-- =============================================
-- Bible App Database Schema for Supabase
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- TABLES
-- =============================================

-- Profiles table (extends auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    display_name TEXT,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    preferred_version_id TEXT DEFAULT 'engwbt',
    font_size REAL DEFAULT 18.0,
    theme_mode TEXT DEFAULT 'light',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookmarks table
CREATE TABLE bookmarks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    version_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter_number INTEGER NOT NULL,
    verse_number INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, version_id, book_id, chapter_number, verse_number)
);

-- Highlights table
CREATE TABLE highlights (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    version_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter_number INTEGER NOT NULL,
    verse_start INTEGER NOT NULL,
    verse_end INTEGER NOT NULL,
    color TEXT DEFAULT '#FFEB3B', -- Yellow default
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notes table
CREATE TABLE notes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    version_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter_number INTEGER NOT NULL,
    verse_number INTEGER, -- Can be null for chapter-level notes
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading Plans table
CREATE TABLE reading_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL, -- 'chronological', '90_day_nt', 'topical', 'custom'
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    total_days INTEGER,
    is_custom BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading Plan Days table
CREATE TABLE reading_plan_days (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    plan_id UUID REFERENCES reading_plans(id) ON DELETE CASCADE NOT NULL,
    day_number INTEGER NOT NULL,
    readings JSONB NOT NULL, -- Array of {book_id, chapter_number}
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMPTZ,
    UNIQUE(plan_id, day_number)
);

-- Downloads tracking table (for cross-device awareness)
CREATE TABLE downloads (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    fileset_id TEXT NOT NULL,
    version_id TEXT NOT NULL,
    book_id TEXT NOT NULL,
    chapter_number INTEGER, -- Null for entire book
    download_type TEXT NOT NULL, -- 'text', 'audio', 'both'
    file_size_mb REAL,
    downloaded_at TIMESTAMPTZ DEFAULT NOW(),
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, fileset_id, book_id, chapter_number)
);

-- User Preferences table
CREATE TABLE user_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
    wifi_only_downloads BOOLEAN DEFAULT true,
    max_cache_size_mb INTEGER DEFAULT 500,
    audio_playback_speed REAL DEFAULT 1.0,
    sleep_timer_minutes INTEGER DEFAULT 0,
    daily_reminder_time TIME,
    daily_reminder_enabled BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- INDEXES
-- =============================================

CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX idx_highlights_user ON highlights(user_id);
CREATE INDEX idx_notes_user ON notes(user_id);
CREATE INDEX idx_reading_plans_user ON reading_plans(user_id);
CREATE INDEX idx_reading_plan_days_plan ON reading_plan_days(plan_id);
CREATE INDEX idx_downloads_user ON downloads(user_id);
CREATE INDEX idx_downloads_fileset ON downloads(fileset_id);

-- Full-text search index for notes
CREATE INDEX idx_notes_content_search ON notes USING gin(to_tsvector('english', content));

-- =============================================
-- TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_highlights_updated_at
    BEFORE UPDATE ON highlights
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at
    BEFORE UPDATE ON notes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION create_profile_on_signup()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, email, created_at)
    VALUES (NEW.id, NEW.email, NOW());
    
    INSERT INTO user_preferences (user_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_profile_on_signup();

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_plan_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Bookmarks policies
CREATE POLICY "Users can view own bookmarks"
    ON bookmarks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own bookmarks"
    ON bookmarks FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Highlights policies
CREATE POLICY "Users can view own highlights"
    ON highlights FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own highlights"
    ON highlights FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Notes policies
CREATE POLICY "Users can view own notes"
    ON notes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own notes"
    ON notes FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Reading plans policies
CREATE POLICY "Users can view own reading plans"
    ON reading_plans FOR SELECT
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can manage own reading plans"
    ON reading_plans FOR ALL
    USING (auth.uid() = user_id OR user_id IS NULL)
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Reading plan days policies (follow plan ownership)
CREATE POLICY "Users can view reading plan days for their plans"
    ON reading_plan_days FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM reading_plans
            WHERE reading_plans.id = reading_plan_days.plan_id
            AND (reading_plans.user_id = auth.uid() OR reading_plans.user_id IS NULL)
        )
    );

CREATE POLICY "Users can manage reading plan days for their plans"
    ON reading_plan_days FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM reading_plans
            WHERE reading_plans.id = reading_plan_days.plan_id
            AND reading_plans.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM reading_plans
            WHERE reading_plans.id = reading_plan_days.plan_id
            AND reading_plans.user_id = auth.uid()
        )
    );

-- Downloads policies
CREATE POLICY "Users can view own downloads"
    ON downloads FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own downloads"
    ON downloads FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- User preferences policies
CREATE POLICY "Users can view own preferences"
    ON user_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
    ON user_preferences FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
    ON user_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =============================================
-- FUNCTIONS
-- =============================================

-- Function to get full-text search results for notes
CREATE OR REPLACE FUNCTION search_notes(query TEXT, user_uuid UUID)
RETURNS TABLE(
    id UUID,
    book_id TEXT,
    chapter_number INTEGER,
    verse_number INTEGER,
    content TEXT,
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.id,
        n.book_id,
        n.chapter_number,
        n.verse_number,
        n.content,
        ts_rank(to_tsvector('english', n.content), plainto_tsquery('english', query)) AS rank
    FROM notes n
    WHERE n.user_id = user_uuid
    AND to_tsvector('english', n.content) @@ plainto_tsquery('english', query)
    ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- SEED DATA (Optional - Pre-built Reading Plans)
-- =============================================

-- Insert pre-built reading plans (available to all users)
INSERT INTO reading_plans (plan_type, name, description, total_days, is_custom) VALUES
('chronological', 'Bible in a Year (Chronological)', 'Read through the Bible in one year in chronological order', 365, false),
('90_day_nt', 'New Testament in 90 Days', 'Read through the New Testament in 90 days', 90, false),
('topical', 'Verses About Anxiety', 'A 7-day plan focusing on verses about anxiety and peace', 7, false),
('topical', 'Verses About Hope', 'A 7-day plan focusing on verses about hope', 7, false);
