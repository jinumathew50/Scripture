import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const BIBLE_BRAIN_API_KEY = Deno.env.get('BIBLE_BRAIN_API_KEY') || '';
const BIBLE_BRAIN_BASE_URL = 'https://api.biblebrain.com/v4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { versionId, bookId, chapterNumber } = body;

    if (!versionId || !bookId || !chapterNumber) {
      throw new Error('versionId, bookId, and chapterNumber are required');
    }

    const response = await fetch(
      `${BIBLE_BRAIN_BASE_URL}/volume/${versionId}/${bookId}/${chapterNumber}?apikey=${BIBLE_BRAIN_API_KEY}`
    );
    
    if (!response.ok) {
      throw new Error('Failed to fetch chapter from Bible Brain API');
    }
    
    const data = await response.json();
    
    // Process chapter data with verse-level timing info
    const chapter = {
      version_id: versionId,
      book_id: bookId,
      chapter_number: chapterNumber,
      verses: data.verses.map((verse: any) => ({
        verse_id: verse.id,
        verse_number: verse.verse_number,
        text: verse.text,
        audio_start_time: verse.audio_start_time,
        audio_end_time: verse.audio_end_time,
      })),
    };
    
    return new Response(
      JSON.stringify(chapter),
      { 
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Edge function error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
