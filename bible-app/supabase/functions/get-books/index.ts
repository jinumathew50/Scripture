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
    const { versionId } = body;

    if (!versionId) {
      throw new Error('versionId is required');
    }

    const response = await fetch(
      `${BIBLE_BRAIN_BASE_URL}/volume/${versionId}/books?apikey=${BIBLE_BRAIN_API_KEY}`
    );
    
    if (!response.ok) {
      throw new Error('Failed to fetch books from Bible Brain API');
    }
    
    const data = await response.json();
    
    const books = data.map((book: any) => ({
      id: book.id,
      name: book.name,
      abbreviation: book.abbreviation,
      book_number: book.book_number,
      testament: book.testament,
      chapter_count: book.chapter_count,
      has_audio: book.has_audio || false,
    }));
    
    return new Response(
      JSON.stringify(books),
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
