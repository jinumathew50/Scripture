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
    const { filesetId, bookId, chapterNumber } = body;

    if (!filesetId || !bookId || !chapterNumber) {
      throw new Error('filesetId, bookId, and chapterNumber are required');
    }

    const response = await fetch(
      `${BIBLE_BRAIN_BASE_URL}/volume/audio/${filesetId}/${bookId}/${chapterNumber}/timing?apikey=${BIBLE_BRAIN_API_KEY}`
    );
    
    if (!response.ok) {
      throw new Error('Failed to get audio timing from Bible Brain API');
    }
    
    const data = await response.json();
    
    // Pre-process timing data for client efficiency
    const timing = data.verses.map((verse: any) => ({
      verse_number: verse.verse_number,
      start_time: verse.start_time,
      end_time: verse.end_time,
    }));
    
    return new Response(
      JSON.stringify(timing),
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
