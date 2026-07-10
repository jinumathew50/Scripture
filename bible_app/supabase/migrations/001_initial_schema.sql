-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  avatar_url TEXT,
  preferred_translation_id TEXT DEFAULT 'eng ESV',
  font_size DOUBLE PRECISION DEFAULT 16.0,
  theme TEXT DEFAULT 'light', -- 'light', 'dark', 'sepia'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookmarks table
CREATE TABLE bookmarks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  book_id TEXT NOT NULL,
  chapter_number INTEGER NOT NULL,
  verse_number INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, book_id, chapter_number, verse_number)
);

-- Highlights table
CREATE TABLE highlights (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  book_id TEXT NOT NULL,
  chapter_number INTEGER NOT NULL,
  start_verse_number INTEGER NOT NULL,
  end_verse_number INTEGER,
  color_hex TEXT NOT NULL DEFAULT '#FFFF00',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notes table
CREATE TABLE notes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  book_id TEXT NOT NULL,
  chapter_number INTEGER NOT NULL,
  start_verse_number INTEGER,
  end_verse_number INTEGER,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading plans table (pre-built and custom plans)
CREATE TABLE reading_plans (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  total_days INTEGER NOT NULL,
  is_custom BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES profiles(id),
  plan_data JSONB NOT NULL, -- Array of daily readings: [{day: 1, passages: [{book_id, chapter, verses}]}]
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User reading plan progress
CREATE TABLE user_reading_plans (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  plan_id UUID REFERENCES reading_plans(id) ON DELETE CASCADE NOT NULL,
  current_day INTEGER DEFAULT 1,
  completed_days INTEGER[] DEFAULT '{}',
  start_date DATE DEFAULT CURRENT_DATE,
  last_completed_date DATE,
  streak INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, plan_id)
);

-- Downloads tracking table
CREATE TABLE downloads (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  book_name TEXT NOT NULL,
  chapter_number INTEGER, -- NULL if entire book
  type TEXT NOT NULL CHECK (type IN ('audio', 'text')),
  file_size_bytes INTEGER NOT NULL DEFAULT 0,
  downloaded_at TIMESTAMPTZ DEFAULT NOW(),
  is_complete BOOLEAN DEFAULT FALSE,
  storage_path TEXT, -- Path in Supabase Storage
  UNIQUE(user_id, fileset_id)
);

-- AI response cache
CREATE TABLE ai_response_cache (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  passage_key TEXT NOT NULL, -- Format: "book_id:chapter:verse_start-verse_end"
  question_hash TEXT NOT NULL, -- Hash of the question for caching
  response TEXT NOT NULL,
  model_version TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  usage_count INTEGER DEFAULT 1
);

-- Reading history (for recent chapters)
CREATE TABLE reading_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  book_id TEXT NOT NULL,
  chapter_number INTEGER NOT NULL,
  translation_id TEXT,
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  read_duration_seconds INTEGER DEFAULT 0,
  UNIQUE(user_id, book_id, chapter_number)
);

-- Indexes for performance
CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX idx_highlights_user ON highlights(user_id);
CREATE INDEX idx_notes_user ON notes(user_id);
CREATE INDEX idx_user_reading_plans_user ON user_reading_plans(user_id);
CREATE INDEX idx_downloads_user ON downloads(user_id);
CREATE INDEX idx_ai_cache_passage ON ai_response_cache(passage_key, question_hash);
CREATE INDEX idx_ai_cache_expires ON ai_response_cache(expires_at);
CREATE INDEX idx_reading_history_user ON reading_history(user_id, last_read_at DESC);

-- Row Level Security (RLS) Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reading_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_response_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_history ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Bookmarks policies
CREATE POLICY "Users can CRUD their own bookmarks"
  ON bookmarks FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Highlights policies
CREATE POLICY "Users can CRUD their own highlights"
  ON highlights FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Notes policies
CREATE POLICY "Users can CRUD their own notes"
  ON notes FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Reading plans policies
CREATE POLICY "Anyone can view non-custom reading plans"
  ON reading_plans FOR SELECT
  USING (is_custom = FALSE OR created_by = auth.uid());

CREATE POLICY "Users can create custom reading plans"
  ON reading_plans FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update their own custom plans"
  ON reading_plans FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete their own custom plans"
  ON reading_plans FOR DELETE
  USING (auth.uid() = created_by);

-- User reading plans policies
CREATE POLICY "Users can CRUD their own reading plan progress"
  ON user_reading_plans FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Downloads policies
CREATE POLICY "Users can CRUD their own downloads"
  ON downloads FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- AI cache policies
CREATE POLICY "Users can view their own cached responses"
  ON ai_response_cache FOR SELECT
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "System can insert AI cache"
  ON ai_response_cache FOR INSERT
  WITH CHECK (true); -- Allow Edge Function to insert without user context

CREATE POLICY "System can update AI cache"
  ON ai_response_cache FOR UPDATE
  USING (true);

-- Reading history policies
CREATE POLICY "Users can CRUD their own reading history"
  ON reading_history FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Functions and Triggers

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

CREATE TRIGGER update_user_reading_plans_updated_at
  BEFORE UPDATE ON user_reading_plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Function to clean up expired AI cache
CREATE OR REPLACE FUNCTION cleanup_expired_ai_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM ai_response_cache
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Create Storage Bucket for offline audio
-- Note: This needs to be done via Supabase dashboard or API
-- Bucket name: 'offline-audio'
-- Public: false
-- File size limit: 50MB per file
-- Allowed MIME types: audio/mpeg, audio/mp4
