const API_KEY = '39cf40d2-bdb9-4a47-9f7e-e2d0ba021c93';
const BASE_URL = 'https://api.scripture.api.bible/v1';

// Helper to get book ID from name (BibleBrain uses specific IDs like "GEN", "PSA", "MAT")
const bookIdMap = {
  "Genesis": "GEN", "Exodus": "EXO", "Leviticus": "LEV", "Numbers": "NUM", "Deuteronomy": "DEU",
  "Joshua": "JOS", "Judges": "JDG", "Ruth": "RUT", "1 Samuel": "1SA", "2 Samuel": "2SA",
  "1 Kings": "1KI", "2 Kings": "2KI", "1 Chronicles": "1CH", "2 Chronicles": "2CH",
  "Ezra": "EZR", "Nehemiah": "NEH", "Esther": "EST", "Job": "JOB", "Psalms": "PSA",
  "Proverbs": "PRO", "Ecclesiastes": "ECC", "Song of Solomon": "SNG", "Isaiah": "ISA",
  "Jeremiah": "JER", "Lamentations": "LAM", "Ezekiel": "EZK", "Daniel": "DAN",
  "Hosea": "HOS", "Joel": "JOL", "Amos": "AMO", "Obadiah": "OBA", "Jonah": "JON",
  "Micah": "MIC", "Nahum": "NAM", "Habakkuk": "HAB", "Zephaniah": "ZEP", "Haggai": "HAG",
  "Zechariah": "ZEC", "Malachi": "MAL",
  "Matthew": "MAT", "Mark": "MRK", "Luke": "LUK", "John": "JHN", "Acts": "ACT",
  "Romans": "ROM", "1 Corinthians": "1CO", "2 Corinthians": "2CO", "Galatians": "GAL",
  "Ephesians": "EPH", "Philippians": "PHI", "Colossians": "COL", "1 Thessalonians": "1TH",
  "2 Thessalonians": "2TH", "1 Timothy": "1TI", "2 Timothy": "2TI", "Titus": "TIT",
  "Philemon": "PHM", "Hebrews": "HEB", "James": "JAS", "1 Peter": "1PE", "2 Peter": "2PE",
  "1 John": "1JN", "2 John": "2JN", "3 John": "3JN", "Jude": "JUD", "Revelation": "REV"
};

export const getBookId = (bookName) => bookIdMap[bookName] || bookName;

// Fetch List of Books
export const fetchBooks = async () => {
  try {
    const response = await fetch(`${BASE_URL}/books?version-id=de4e12af7f28f59ff0a475dc86705be8`, { // Using KJV version ID for consistency
      headers: { 'api-key': API_KEY }
    });
    if (!response.ok) throw new Error('Failed to fetch books');
    const data = await response.json();
    return data.data;
  } catch (error) {
    console.error("Error fetching books:", error);
    // Fallback to static list if API fails (common with CORS on free tiers)
    return Object.keys(bookIdMap).map(name => ({ id: bookIdMap[name], name, abbreviation: name }));
  }
};

// Fetch Chapter Text
export const fetchChapter = async (bookId, chapterNum) => {
  try {
    // BibleBrain chapter endpoint: /bibles/{version-id}/chapters/{bookId}{chapterNum}
    const chapterId = `${bookId}.${chapterNum}`; 
    const response = await fetch(`${BASE_URL}/bibles/de4e12af7f28f59ff0a475dc86705be8/chapters/${chapterId}`, {
      headers: { 'api-key': API_KEY }
    });
    
    if (!response.ok) {
      if (response.status === 404) throw new Error('Chapter not found');
      throw new Error('Failed to fetch chapter');
    }
    
    const data = await response.json();
    return data.data;
  } catch (error) {
    console.error("Error fetching chapter:", error);
    throw error;
  }
};

// Get Audio URL for a verse or chapter
// BibleBrain audio is usually accessed via their player or specific stream URLs
// For this app, we will construct the audio URL based on their standard pattern if available
// Or use the 'audio' property if returned in verse data (requires specific query params)
export const getAudioUrl = (bookId, chapterNum, verseNum = null) => {
  // BibleBrain doesn't always give direct MP3 links in the text API without specific entitlements.
  // However, we can try to construct a standard request or use the media endpoint if available.
  // Fallback: We will simulate audio capability or use a public domain audio source if BibleBrain restricts direct hotlinking.
  
  // Attempting to use BibleBrain's media structure (often requires specific version with audio)
  // For KJV (de4e12af...), audio might not be directly hotlinkable via simple URL construction without OAuth flow in some cases.
  // We will return null if not directly available, and the UI will hide the player, 
  // OR we can try the 'bibles/{id}/chapters/{id}/audio' endpoint if supported.
  
  // Let's try the standard audio endpoint pattern for the chapter
  return `${BASE_URL}/bibles/de4e12af7f28f59ff0a475dc86705be8/chapters/${bookId}.${chapterNum}/audio`;
};
