import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const BIBLE_BRAIN_API_KEY = Deno.env.get('BIBLE_BRAIN_API_KEY') || '';
const BIBLE_BRAIN_BASE_URL = 'https://api.biblebrain.com/v4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify API key exists
    if (!BIBLE_BRAIN_API_KEY) {
      throw new Error('BIBLE_BRAIN_API_KEY not configured');
    }

    const response = await fetch(
      `${BIBLE_BRAIN_BASE_URL}/volume?apikey=${BIBLE_BRAIN_API_KEY}`
    );
    
    if (!response.ok) {
      throw new Error('Failed to fetch Bible versions from Bible Brain API');
    }
    
    const data = await response.json();
    
    // Process and filter versions based on license
    const versions = data.map((v: any) => ({
      id: v.id,
      name: v.name,
      abbreviation: v.abbreviation,
      language: v.language,
      description: v.description,
      has_audio: v.has_audio || false,
      is_downloadable: v.downloadable || false, // Only cache what's explicitly allowed
    }));
    
    return new Response(
      JSON.stringify(versions),
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
