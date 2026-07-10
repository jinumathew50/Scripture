# 📖 Bible App - Technical Specification

## Executive Summary
A cross-platform mobile Bible application (iOS/Android) built with Flutter, featuring scripture reading, dramatized audio playback with verse-level synchronization, offline capabilities, structured reading plans, and an optional AI study assistant. Backend powered by Supabase for authentication, database, storage, and edge functions.

---

## 1. Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                      Mobile App (Flutter)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Reading Screen│  │ Audio Player │  │ Offline Manager      │  │
│  └──────────────┘  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Search         │  │ Reading Plans│  │ AI Study Assistant   │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Supabase Backend                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Auth          │  │ PostgreSQL   │  │ Storage              │  │
│  │ (Email/Google)│  │ (User Data)  │  │ (Cached Audio)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │ Realtime      │  │ Edge Functions                          │  │
│  │ (Sync)        │  │ (Bible API Proxy)                       │  │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   External APIs                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Bible Brain API (Faith Comes By Hearing)                  │  │
│  │ - Scripture Text (multiple translations)                  │  │
│  │ - Dramatized Audio (filesets with verse timing)           │  │
│  │ - Gospel Film Video (stretch)                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Gemini API (Optional AI Layer)                           │  │
│  │ - Context explanations                                   │  │
│  │ - Cross-references                                       │  │
│  │ - Q&A grounded in open passage                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **Supabase over Firebase**: Chosen per requirements for:
   - PostgreSQL relational database (better for complex queries on reading plans, cross-references)
   - Built-in Row Level Security (RLS) for data privacy
   - Real-time subscriptions for sync across devices
   - Edge Functions (Deno-based) for secure API proxying
   - Storage with CDN for cached audio files

2. **Bible Brain API via Edge Functions**: 
   - API keys never exposed to client
   - Rate limiting and caching at edge layer
   - License compliance enforcement (what can be cached offline)
   - Response transformation for consistent data format

3. **Offline-First Architecture**:
   - Hive local database for text content and metadata
   - flutter_cache_manager for audio file caching
   - Supabase Storage for user-uploaded content (notes, custom plans)
   - Sync queue for offline actions (bookmarks, highlights, notes)

4. **Audio Sync Strategy**:
   - Primary: Verse-level timing data from Bible Brain (when available)
   - Fallback: Chapter-level playback with manual verse navigation
   - Graceful degradation ensures compatibility across all filesets

---

## 2. Supabase Schema Design

### Database Tables

```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  display_name TEXT,
  avatar_url TEXT,
  preferred_translation_id TEXT DEFAULT 'ENGKJDA',
  font_size INTEGER DEFAULT 16,
  theme_mode TEXT DEFAULT 'system', -- 'light', 'dark', 'system'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookmarks
CREATE TABLE public.bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_bookmark UNIQUE (user_id, fileset_id, book_id, chapter, verse)
);

-- Highlights
CREATE TABLE public.highlights (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse_start INTEGER NOT NULL,
  verse_end INTEGER NOT NULL,
  color_code TEXT DEFAULT '#FFD700', -- Gold default
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notes
CREATE TABLE public.notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse_start INTEGER,
  verse_end INTEGER,
  content TEXT NOT NULL,
  is_private BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading Plans
CREATE TABLE public.reading_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  plan_type TEXT NOT NULL, -- 'chronological', '90day_nt', 'topical', 'custom'
  total_days INTEGER NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  creator_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reading Plan Days
CREATE TABLE public.reading_plan_days (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_id UUID REFERENCES public.reading_plans(id) ON DELETE CASCADE NOT NULL,
  day_number INTEGER NOT NULL,
  readings JSONB NOT NULL, -- [{fileset_id, book_id, chapter, verse_start, verse_end}]
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_plan_day UNIQUE (plan_id, day_number)
);

-- User Reading Plan Progress
CREATE TABLE public.user_reading_plan_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  plan_id UUID REFERENCES public.reading_plans(id) ON DELETE CASCADE NOT NULL,
  start_date DATE NOT NULL,
  current_day INTEGER DEFAULT 1,
  completed_days INTEGER[] DEFAULT ARRAY[]::INTEGER[],
  streak_count INTEGER DEFAULT 0,
  last_completed_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_user_plan UNIQUE (user_id, plan_id)
);

-- Downloads Tracking (cross-device awareness)
CREATE TABLE public.user_downloads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter INTEGER,
  download_type TEXT NOT NULL, -- 'text', 'audio', 'both'
  file_size_bytes BIGINT,
  downloaded_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- For license compliance
  is_valid BOOLEAN DEFAULT TRUE,
  
  CONSTRAINT unique_download UNIQUE (user_id, fileset_id, book_id, chapter)
);

-- AI Cache (to reduce Gemini API calls)
CREATE TABLE public.ai_response_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  fileset_id TEXT NOT NULL,
  book_id TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse_start INTEGER NOT NULL,
  verse_end INTEGER NOT NULL,
  query_hash TEXT NOT NULL, -- Hash of query + passage
  response_json JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  
  CONSTRAINT unique_ai_cache UNIQUE (fileset_id, book_id, chapter, verse_start, verse_end, query_hash)
);

-- Indexes for performance
CREATE INDEX idx_bookmarks_user ON public.bookmarks(user_id);
CREATE INDEX idx_highlights_user ON public.highlights(user_id);
CREATE INDEX idx_notes_user ON public.notes(user_id);
CREATE INDEX idx_user_progress_user ON public.user_reading_plan_progress(user_id);
CREATE INDEX idx_user_downloads_user ON public.user_downloads(user_id);
CREATE INDEX idx_ai_cache_passage ON public.ai_response_cache(fileset_id, book_id, chapter);
CREATE INDEX idx_ai_cache_expiry ON public.ai_response_cache(expires_at);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reading_plan_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reading_plan_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_response_cache ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can manage own bookmarks"
  ON public.bookmarks FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own highlights"
  ON public.highlights FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own notes"
  ON public.notes FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own reading plan progress"
  ON public.user_reading_plan_progress FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own downloads"
  ON public.user_downloads FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own AI cache"
  ON public.ai_response_cache FOR ALL
  USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Public can view public reading plans"
  ON public.reading_plans FOR SELECT
  USING (is_public = TRUE OR creator_id = auth.uid());

CREATE POLICY "Users can manage own reading plans"
  ON public.reading_plans FOR ALL
  USING (creator_id = auth.uid());
```

---

## 3. Supabase Edge Functions Structure

### Function 1: `bible-brain-proxy`
Proxies requests to Bible Brain API, handles caching, rate limiting, and license compliance.

```typescript
// supabase/functions/bible-brain-proxy/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const BIBLE_BRAIN_BASE_URL = "https://api.biblebrain.com";
const BIBLE_BRAIN_API_KEY = Deno.env.get('BIBLE_BRAIN_API_KEY')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { endpoint, params } = await req.json();
    
    // Validate endpoint whitelist
    const allowedEndpoints = [
      '/filesets',
      '/books',
      '/chapters',
      '/verses',
      '/verse-timing',
      '/search',
    ];
    
    if (!allowedEndpoints.includes(endpoint)) {
      throw new Error('Invalid endpoint');
    }

    // Build URL with API key
    const url = new URL(`${BIBLE_BRAIN_BASE_URL}${endpoint}`);
    url.searchParams.set('key', BIBLE_BRAIN_API_KEY);
    url.searchParams.set('callback', 'F');
    url.searchParams.set('v', '4.1');
    
    // Add request params
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        url.searchParams.set(key, String(value));
      }
    });

    // Fetch from Bible Brain
    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Bible Brain API error: ${response.status}`);
    }

    const data = await response.json();

    // Check offline permissions in response metadata
    const canCache = checkOfflinePermissions(data);

    return new Response(
      JSON.stringify({ ...data, _meta: { canCache, timestamp: Date.now() } }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

function checkOfflinePermissions(data: any): boolean {
  // Check fileset metadata for download permissions
  // This is critical for license compliance
  if (data.fileset?.download_allowed === true) {
    return true;
  }
  
  // Default to false - only cache when explicitly permitted
  return false;
}
```

### Function 2: `ai-study-assistant`
Handles AI queries with grounding, caching, and cost control.

```typescript
// supabase/functions/ai-study-assistant/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!;
const GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { 
      fileset_id, 
      book_id, 
      chapter, 
      verse_start, 
      verse_end, 
      query,
      user_id 
    } = await req.json();

    // Validate input
    if (!query || !book_id || !chapter) {
      throw new Error('Missing required parameters');
    }

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    // Check cache first
    const queryHash = await crypto.subtle.digest(
      'SHA-256',
      new TextEncoder().encode(`${query}|${fileset_id}|${book_id}|${chapter}|${verse_start}|${verse_end}`)
    );
    const hashHex = Array.from(new Uint8Array(queryHash))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');

    const { data: cached } = await supabase
      .from('ai_response_cache')
      .select('*')
      .eq('fileset_id', fileset_id)
      .eq('book_id', book_id)
      .eq('chapter', chapter)
      .eq('verse_start', verse_start)
      .eq('verse_end', verse_end)
      .eq('query_hash', hashHex)
      .gt('expires_at', new Date().toISOString())
      .single();

    if (cached) {
      return new Response(
        JSON.stringify({ ...cached.response_json, _cached: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Fetch scripture text for grounding
    const { data: verses } = await supabase.functions.invoke('bible-brain-proxy', {
      body: {
        endpoint: '/verses',
        params: {
          fileset_id,
          book_id,
          chapter,
          verse_start,
          verse_end,
        }
      }
    });

    const scriptureText = verses?.data?.verses?.map((v: any) => 
      `${v.verseNumber} ${v.text}`
    ).join('\n') || '';

    // Build system prompt with strict grounding
    const systemPrompt = `You are a Bible study assistant. Your role is to provide context, explanations, and cross-references for scripture passages.

IMPORTANT RULES:
1. NEVER invent or add content not found in the actual scripture text
2. NEVER contradict the scripture text provided
3. Always clearly distinguish between scripture text and your commentary
4. If asked about something not in the passage, say so honestly
5. Keep responses concise and focused on the specific verses provided
6. Do not make theological claims beyond what the text supports

PASSAGE CONTEXT:
${scriptureText}

Provide helpful, accurate, and humble commentary.`;

    // Call Gemini API
    const geminiResponse = await fetch(`${GEMINI_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: `${systemPrompt}\n\nUSER QUESTION: ${query}`
          }]
        }],
        generationConfig: {
          temperature: 0.3, // Lower temperature for more factual responses
          maxOutputTokens: 500, // Limit response length to control costs
        },
        safetySettings: [
          {
            category: "HARM_CATEGORY_RELIGION",
            threshold: "BLOCK_NONE" // Allow religious content
          }
        ]
      })
    });

    if (!geminiResponse.ok) {
      throw new Error(`Gemini API error: ${geminiResponse.status}`);
    }

    const geminiData = await geminiResponse.json();
    const responseText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || '';

    const responseData = {
      query,
      passage: { fileset_id, book_id, chapter, verse_start, verse_end },
      response: responseText,
      sources: extractCrossReferences(responseText),
      timestamp: Date.now(),
    };

    // Cache the response (without user_id to allow sharing)
    await supabase.from('ai_response_cache').insert({
      fileset_id,
      book_id,
      chapter,
      verse_start,
      verse_end,
      query_hash: hashHex,
      response_json: responseData,
      user_id: null, // Shared cache
    });

    return new Response(
      JSON.stringify(responseData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

function extractCrossReferences(text: string): string[] {
  // Simple regex to extract Bible references like "John 3:16" or "Psalm 23"
  const regex = /\b([A-Z][a-z]+)\s+(\d+)(?::(\d+))?\b/g;
  const matches = [...text.matchAll(regex)];
  return matches.map(m => m[0]);
}
```

### Function 3: `sync-offline-actions`
Processes queued actions from offline mode.

```typescript
// supabase/functions/sync-offline-actions/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing authorization header');
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    const { data: { user } } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''));
    
    if (!user) {
      throw new Error('Unauthorized');
    }

    const { actions } = await req.json();
    const results = [];

    for (const action of actions) {
      try {
        let result;
        
        switch (action.type) {
          case 'bookmark':
            result = await upsertBookmark(supabase, user.id, action.data);
            break;
          case 'highlight':
            result = await upsertHighlight(supabase, user.id, action.data);
            break;
          case 'note':
            result = await upsertNote(supabase, user.id, action.data);
            break;
          case 'reading_progress':
            result = await updateReadingProgress(supabase, user.id, action.data);
            break;
          default:
            throw new Error(`Unknown action type: ${action.type}`);
        }

        results.push({ actionId: action.id, success: true, result });
      } catch (error) {
        results.push({ actionId: action.id, success: false, error: error.message });
      }
    }

    return new Response(
      JSON.stringify({ results }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

async function upsertBookmark(supabase: any, userId: string, data: any) {
  return await supabase.from('bookmarks').upsert({
    user_id: userId,
    fileset_id: data.fileset_id,
    book_id: data.book_id,
    chapter: data.chapter,
    verse: data.verse,
  }, {
    onConflict: 'user_id,fileset_id,book_id,chapter,verse'
  });
}

async function upsertHighlight(supabase: any, userId: string, data: any) {
  return await supabase.from('highlights').upsert({
    user_id: userId,
    fileset_id: data.fileset_id,
    book_id: data.book_id,
    chapter: data.chapter,
    verse_start: data.verse_start,
    verse_end: data.verse_end,
    color_code: data.color_code,
    note: data.note,
  });
}

async function upsertNote(supabase: any, userId: string, data: any) {
  return await supabase.from('notes').upsert({
    user_id: userId,
    fileset_id: data.fileset_id,
    book_id: data.book_id,
    chapter: data.chapter,
    verse_start: data.verse_start,
    verse_end: data.verse_end,
    content: data.content,
    is_private: data.is_private,
  });
}

async function updateReadingProgress(supabase: any, userId: string, data: any) {
  const { data: existing } = await supabase
    .from('user_reading_plan_progress')
    .select('*')
    .eq('user_id', userId)
    .eq('plan_id', data.plan_id)
    .single();

  if (!existing) {
    return await supabase.from('user_reading_plan_progress').insert({
      user_id: userId,
      plan_id: data.plan_id,
      start_date: new Date().toISOString().split('T')[0],
      current_day: data.day_number,
      completed_days: [data.day_number],
      streak_count: 1,
      last_completed_date: new Date().toISOString().split('T')[0],
    });
  }

  const updatedDays = existing.completed_days.includes(data.day_number)
    ? existing.completed_days
    : [...existing.completed_days, data.day_number];

  const newStreak = calculateStreak(updatedDays);

  return await supabase.from('user_reading_plan_progress').update({
    current_day: Math.max(existing.current_day, data.day_number),
    completed_days: updatedDays,
    streak_count: newStreak,
    last_completed_date: new Date().toISOString().split('T')[0],
    updated_at: new Date().toISOString(),
  }).eq('id', existing.id);
}

function calculateStreak(completedDays: number[]): number {
  // Simple streak calculation - consecutive days
  // In production, this would use actual dates
  return completedDays.length;
}
```

---

## 4. Flutter Project Structure

```
bible_app/
├── android/                    # Android-specific configuration
├── ios/                        # iOS-specific configuration
├── lib/
│   ├── main.dart               # App entry point
│   ├── app.dart                # MaterialApp configuration
│   │
│   ├── core/                   # Core utilities and constants
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── bible_books.dart
│   │   │   └── api_endpoints.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   ├── string_extensions.dart
│   │   │   └── datetime_extensions.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── text_styles.dart
│   │   └── utils/
│   │       ├── logger.dart
│   │       ├── validators.dart
│   │       └── formatters.dart
│   │
│   ├── config/                 # App configuration
│   │   ├── routes/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   └── di/
│   │       └── injection_container.dart
│   │
│   ├── data/                   # Data layer
│   │   ├── models/
│   │   │   ├── bible/
│   │   │   │   ├── book.dart
│   │   │   │   ├── chapter.dart
│   │   │   │   ├── verse.dart
│   │   │   │   ├── fileset.dart
│   │   │   │   └── verse_timing.dart
│   │   │   ├── user/
│   │   │   │   ├── user_profile.dart
│   │   │   │   ├── bookmark.dart
│   │   │   │   ├── highlight.dart
│   │   │   │   ├── note.dart
│   │   │   │   └── reading_plan_progress.dart
│   │   │   └── ai/
│   │   │       └── ai_response.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── bible_repository_impl.dart
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── user_repository_impl.dart
│   │   │   ├── reading_plan_repository_impl.dart
│   │   │   └── download_repository_impl.dart
│   │   │
│   │   └── datasources/
│   │       ├── remote/
│   │       │   ├── bible_brain_api.dart
│   │       │   ├── supabase_auth_api.dart
│   │       │   ├── supabase_db_api.dart
│   │       │   └── ai_api.dart
│   │       ├── local/
│   │       │   ├── hive_database.dart
│   │       │   ├── cache_manager.dart
│   │       │   └── preferences.dart
│   │       └── models/
│   │           └── DTOs matching domain models
│   │
│   ├── domain/                 # Business logic layer
│   │   ├── entities/
│   │   │   ├── book_entity.dart
│   │   │   ├── chapter_entity.dart
│   │   │   ├── verse_entity.dart
│   │   │   ├── user_entity.dart
│   │   │   └── reading_plan_entity.dart
│   │   ├── repositories/
│   │   │   ├── bible_repository.dart
│   │   │   ├── auth_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   ├── reading_plan_repository.dart
│   │   │   └── download_repository.dart
│   │   └── usecases/
│   │       ├── bible/
│   │       │   ├── get_books.dart
│   │       │   ├── get_chapter.dart
│   │       │   ├── get_verse_timing.dart
│   │       │   └── search_scripture.dart
│   │       ├── user/
│   │       │   ├── create_bookmark.dart
│   │       │   ├── create_highlight.dart
│   │       │   ├── create_note.dart
│   │       │   └── update_preferences.dart
│   │       ├── reading_plan/
│   │       │   ├── get_available_plans.dart
│   │       │   ├── start_plan.dart
│   │       │   ├── complete_day.dart
│   │       │   └── get_progress.dart
│   │       └── downloads/
│   │           ├── download_chapter.dart
│   │           ├── delete_download.dart
│   │           └── get_downloads.dart
│   │
│   ├── presentation/           # UI layer
│   │   ├── widgets/            # Reusable widgets
│   │   │   ├── common/
│   │   │   │   ├── app_bar_widget.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   ├── error_widget.dart
│   │   │   │   └── empty_state_widget.dart
│   │   │   ├── bible/
│   │   │   │   ├── book_list_tile.dart
│   │   │   │   ├── chapter_grid.dart
│   │   │   │   ├── verse_widget.dart
│   │   │   │   └── translation_selector.dart
│   │   │   ├── audio/
│   │   │   │   ├── audio_player_bar.dart
│   │   │   │   ├── playback_controls.dart
│   │   │   │   └── speed_selector.dart
│   │   │   └── highlights/
│   │   │       ├── highlight_color_picker.dart
│   │   │       └── note_editor.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── home_bloc.dart
│   │   │   ├── library/
│   │   │   │   ├── library_screen.dart
│   │   │   │   └── library_bloc.dart
│   │   │   ├── reading/
│   │   │   │   ├── reading_screen.dart
│   │   │   │   ├── reading_bloc.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── verse_interaction_widget.dart
│   │   │   │       ├── footnote_popup.dart
│   │   │   │       └── cross_reference_widget.dart
│   │   │   ├── audio_player/
│   │   │   │   ├── full_player_screen.dart
│   │   │   │   └── mini_player_widget.dart
│   │   │   ├── search/
│   │   │   │   ├── search_screen.dart
│   │   │   │   └── search_bloc.dart
│   │   │   ├── reading_plans/
│   │   │   │   ├── plans_list_screen.dart
│   │   │   │   ├── plan_detail_screen.dart
│   │   │   │   ├── plan_progress_screen.dart
│   │   │   │   └── reading_plans_bloc.dart
│   │   │   ├── downloads/
│   │   │   │   ├── downloads_screen.dart
│   │   │   │   └── downloads_bloc.dart
│   │   │   ├── settings/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── appearance_settings.dart
│   │   │   │   └── account_settings.dart
│   │   │   └── ai_study/
│   │   │       ├── ai_study_sheet.dart
│   │   │       └── ai_study_bloc.dart
│   │   │
│   │   └── blocs/              # State management (flutter_bloc)
│   │       ├── auth/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── bible/
│   │       │   ├── bible_bloc.dart
│   │       │   ├── bible_event.dart
│   │       │   └── bible_state.dart
│   │       └── player/
│   │           ├── player_bloc.dart
│   │           ├── player_event.dart
│   │           └── player_state.dart
│   │
│   └── services/               # App-wide services
│       ├── audio/
│       │   ├── audio_service.dart
│       │   ├── audio_player_handler.dart
│       │   └── verse_sync_service.dart
│       ├── notifications/
│       │   └── notification_service.dart
│       └── deep_links/
│           └── deep_link_service.dart
│
├── test/                       # Unit tests
│   ├── data/
│   ├── domain/
│   └── presentation/
│
├── integration_test/           # Integration tests
│
├── assets/                     # Static assets
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── translations/
│       ├── en-US.json
│       ├── es-ES.json
│       └── fr-FR.json
│
├── pubspec.yaml                # Dependencies
├── analysis_options.yaml       # Linter rules
└── README.md
```

---

## 5. Build Roadmap

### Phase 1: Foundation & MVP (Weeks 1-6)

**Week 1-2: Project Setup & Core Infrastructure**
- [ ] Initialize Flutter project with clean architecture structure
- [ ] Configure Supabase project (Auth, Postgres, Storage)
- [ ] Set up Edge Functions development environment
- [ ] Implement dependency injection (get_it + injectable)
- [ ] Create basic routing structure (go_router)
- [ ] Set up theming system (light/dark/sepia)
- [ ] Configure Hive for local storage
- [ ] Implement logging and error tracking

**Week 3-4: Bible Content & Reading Experience**
- [ ] Build Bible Brain API proxy Edge Function
- [ ] Implement Bible repository with remote and local datasources
- [ ] Create book/chapter navigation UI
- [ ] Build reading screen with verse rendering
- [ ] Implement font size adjustment
- [ ] Add translation switching
- [ ] Create bookmark functionality (local + sync)
- [ ] Implement basic highlighting (local + sync)

**Week 5-6: Audio Playback Foundation**
- [ ] Integrate just_audio for playback
- [ ] Build audio player service with background support
- [ ] Implement verse-level sync when timing data available
- [ ] Create mini-player widget
- [ ] Build full-screen player with controls
- [ ] Add variable playback speed
- [ ] Implement sleep timer
- [ ] Basic download manager for audio chapters

**MVP Deliverable**: Read + Listen experience with one translation, basic bookmarks/highlights, and single-chapter audio playback with sync.

---

### Phase 2: User Features & Offline (Weeks 7-10)

**Week 7-8: Authentication & User Data Sync**
- [ ] Implement Supabase Auth (email/password, Google Sign-In)
- [ ] Create user profile management
- [ ] Build sync engine for offline actions
- [ ] Implement realtime updates for bookmarks/highlights/notes
- [ ] Add notes feature with rich text support
- [ ] Create highlight color picker
- [ ] Build cross-device download tracking

**Week 9-10: Offline Mode & Download Manager**
- [ ] Enhance cache manager for efficient audio caching
- [ ] Implement chapter-by-chapter download UI
- [ ] Show download sizes and storage usage
- [ ] Add download queue management
- [ ] Handle license expiration for cached content
- [ ] Implement offline mode detection
- [ ] Build sync queue processor
- [ ] Add Wi-Fi only download option

**v1.0 Release Candidate**: Full reading + listening with offline support, user accounts, and sync across devices.

---

### Phase 3: Reading Plans & Search (Weeks 11-14)

**Week 11-12: Reading Plans System**
- [ ] Design reading plan schema in Supabase
- [ ] Create pre-built plans (Chronological, 90-Day NT, Topical)
- [ ] Build reading plan browsing UI
- [ ] Implement plan enrollment and progress tracking
- [ ] Add daily reminder notifications
- [ ] Create streak tracking and gamification
- [ ] Build custom plan creator
- [ ] Add plan completion celebrations

**Week 13-14: Search & Discovery**
- [ ] Implement full-text search within active translation
- [ ] Build search UI with filters (book, testament, keyword)
- [ ] Add search result highlighting
- [ ] Create recent searches history
- [ ] Implement search suggestions
- [ ] Add verse-of-the-day feature
- [ ] Build share cards for verses (image generation)

**v1.1 Release**: Reading plans with progress tracking, streaks, and robust search functionality.

---

### Phase 4: AI Study Assistant (Weeks 15-17)

**Week 15: AI Infrastructure**
- [ ] Build AI study assistant Edge Function
- [ ] Implement response caching strategy
- [ ] Create grounding mechanism with scripture text
- [ ] Add safety filters and content moderation
- [ ] Set up cost monitoring and rate limiting

**Week 16: AI UI & Integration**
- [ ] Build AI study bottom sheet component
- [ ] Create query input with suggested questions
- [ ] Display AI responses with clear visual distinction
- [ ] Add cross-reference extraction and linking
- [ ] Implement follow-up question threading
- [ ] Add toggle to enable/disable AI features

**Week 17: AI Refinement**
- [ ] Optimize response quality with prompt engineering
- [ ] Add multi-language support for AI
- [ ] Implement voice input for queries
- [ ] Build AI response history
- [ ] Add feedback mechanism for response quality

**v1.2 Release**: Optional AI study assistant grounded in scripture, with caching for cost control.

---

### Phase 5: Polish & Stretch Goals (Weeks 18-20+)

**Accessibility & Internationalization**
- [ ] Screen reader support (Semantics widgets)
- [ ] High contrast mode
- [ ] Dynamic text sizing (iOS) / Font scaling (Android)
- [ ] Multi-language UI (i18n)
- [ ] RTL language support (Arabic, Hebrew)

**Advanced Features**
- [ ] Group/community reading plans
- [ ] Journal entries linked to passages
- [ ] Advanced analytics dashboard
- [ ] Social sharing enhancements
- [ ] Widget support (iOS Home Screen, Android Widgets)
- [ ] Apple Watch / Wear OS companion app
- [ ] CarPlay / Android Auto support for audio

**Performance Optimization**
- [ ] Image caching optimization
- [ ] Audio prefetching strategy
- [ ] Database query optimization
- [ ] Bundle size reduction
- [ ] Startup time optimization

---

## 6. Key Technical Considerations

### Audio Sync Implementation Strategy

```dart
// Verse timing data structure from Bible Brain
class VerseTiming {
  final String verseNumber;
  final int startTimeMs;
  final int endTimeMs;
  final String audioUrl;
  
  // When timing data unavailable, fallback to estimated duration
  bool get hasTiming => startTimeMs != -1 && endTimeMs != -1;
}

// Player state machine
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  buffering,
  completed,
}

// Sync service handles verse highlighting
class VerseSyncService {
  final AudioPlayer _player;
  StreamSubscription<Duration>? _positionSubscription;
  
  void startSync(List<VerseTiming> timings) {
    _positionSubscription = _player.positionStream.listen((position) {
      final currentVerse = _findCurrentVerse(position, timings);
      _emitVerseChange(currentVerse);
    });
  }
  
  VerseTiming? _findCurrentVerse(Duration position, List<VerseTiming> timings) {
    final positionMs = position.inMilliseconds;
    return timings.firstWhere(
      (t) => t.hasTiming && 
             positionMs >= t.startTimeMs && 
             positionMs <= t.endTimeMs,
      orElse: () => timings.last, // Fallback to last verse
    );
  }
}
```

### Offline Storage Strategy

```dart
// Using flutter_cache_manager with custom stale rule
class BibleCacheManager {
  static const key = 'bibleAudioCache';
  
  static final instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 1000,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  // Check if content can be cached per license
  Future<bool> canCacheContent(String filesetId) async {
    // Query Edge Function for fileset permissions
    final permissions = await _getFilesetPermissions(filesetId);
    return permissions.downloadAllowed;
  }
}

// Hive boxes for different data types
class HiveBoxes {
  static const String scripture = 'scripture';
  static const String metadata = 'metadata';
  static const String userActions = 'user_actions_queue';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(scripture);
    await Hive.openBox(metadata);
    await Hive.openBox(userActions);
  }
}
```

### State Management Pattern (flutter_bloc)

```dart
// Reading screen BLoC example
class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final GetChapterUseCase _getChapter;
  final CreateBookmarkUseCase _createBookmark;
  final CreateHighlightUseCase _createHighlight;
  
  ReadingBloc({
    required GetChapterUseCase getChapter,
    required CreateBookmarkUseCase createBookmark,
    required CreateHighlightUseCase createHighlight,
  })  : _getChapter = getChapter,
        _createBookmark = createBookmark,
        _createHighlight = createHighlight,
        super(ReadingInitial());

  @override
  Stream<ReadingState> mapEventToState(ReadingEvent event) async* {
    if (event is LoadChapter) {
      yield ReadingLoading();
      
      try {
        // Try local cache first
        final cached = await _getFromCache(event.bookId, event.chapter);
        if (cached != null) {
          yield ChapterLoaded(chapter: cached, isOffline: true);
          
          // Then fetch from network in background
          _fetchAndUpdate(event.bookId, event.chapter, event.filesetId);
        } else {
          final chapter = await _getChapter.execute(
            bookId: event.bookId,
            chapter: event.chapter,
            filesetId: event.filesetId,
          );
          yield ChapterLoaded(chapter: chapter, isOffline: false);
        }
      } catch (e) {
        yield ReadingError(message: e.toString());
      }
    }
    
    if (event is ToggleBookmark) {
      // Optimistic UI update
      final currentState = state as ChapterLoaded;
      final isBookmarked = currentState.isVerseBookmarked(event.verseNumber);
      
      yield currentState.copyWith(
        chapter: currentState.chapter.copyWith(
          bookmarks: isBookmarked
              ? currentState.chapter.bookmarks.where((b) => b.verse != event.verseNumber).toList()
              : [...currentState.chapter.bookmarks, Bookmark(verse: event.verseNumber)],
        ),
      );
      
      // Sync to server
      await _createBookmark.execute(
        filesetId: currentState.chapter.filesetId,
        bookId: currentState.chapter.bookId,
        chapter: currentState.chapter.number,
        verse: event.verseNumber,
      );
    }
  }
}
```

---

## 7. Next Steps

1. **Confirm Bible Brain API access**: Obtain API key and review documentation for available filesets with verse timing
2. **Set up Supabase project**: Create project, configure Auth providers, run SQL migrations
3. **Initialize Flutter project**: Run `flutter create` with configured structure
4. **Build Edge Functions**: Start with Bible Brain proxy function
5. **Implement core reading flow**: Book selection → Chapter view → Verse rendering
6. **Add audio playback**: Integrate just_audio with basic controls
7. **Test on both platforms**: Ensure iOS and Android parity

Would you like me to generate the starter Flutter scaffolding code for the reading screen, audio player, and Supabase integration?
