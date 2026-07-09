// Bible API using Digital Bible Platform (DBT) - api.dbt.org/v4
const API_BASE_URL = 'https://api.dbt.org/v4';
const API_KEY = '39cf40d2-bdb9-4a47-9f7e-e2d0ba021c93';

// Cache for discovered version IDs
let textVersionId = null;
let audioVersionId = null;

// Helper to handle DBT API response structure
const handleResponse = async (response) => {
  if (!response.ok) {
    if (response.status === 404) {
      throw new Error('Resource not found. Please check your API key and version.');
    }
    throw new Error(`API Error: ${response.status}`);
  }
  const data = await response.json();
  return data.data || data; // DBT often wraps data in a 'data' property
};

/**
 * Find a valid English Text Version dynamically
 */
const findTextVersion = async () => {
  if (textVersionId) return textVersionId;

  try {
    const response = await fetch(`${API_BASE_URL}/bibles?language=en`, {
      headers: { 'X-API-Key': API_KEY }
    });

    if (!response.ok) throw new Error('Failed to fetch versions');
    
    const data = await response.json();
    const versions = data.data || [];
    
    // Prefer World English Bible (WEB) or other free versions
    const preferred = versions.find(v => v.id === 'WEB') || 
                      versions.find(v => v.id === 'ENGESV') || 
                      versions.find(v => v.id === 'KJV') ||
                      versions[0];

    if (preferred) {
      textVersionId = preferred.id;
      console.log(`✅ Using text version: ${preferred.name} (${preferred.id})`);
      return preferred.id;
    }
    throw new Error('No English text version found');
  } catch (error) {
    console.error('❌ Error finding text version:', error);
    throw error;
  }
};

/**
 * Find a valid Audio Version dynamically
 */
const findAudioVersion = async () => {
  if (audioVersionId) return audioVersionId;

  try {
    const response = await fetch(`${API_BASE_URL}/bibles?language=en&tags=audio`, {
      headers: { 'X-API-Key': API_KEY }
    });

    if (!response.ok) throw new Error('Failed to fetch audio versions');
    
    const data = await response.json();
    const versions = data.data || [];
    const preferred = versions[0];

    if (preferred) {
      audioVersionId = preferred.id;
      console.log(`✅ Using audio version: ${preferred.name} (${preferred.id})`);
      return preferred.id;
    }
    throw new Error('No audio version found');
  } catch (error) {
    console.warn('⚠️ Audio not available:', error.message);
    return null;
  }
};

export async function getBooks() {
  try {
    const versionId = await findTextVersion();
    const response = await fetch(`${API_BASE_URL}/bibles/${versionId}/books`, {
      headers: { 'X-API-Key': API_KEY }
    });
    
    const books = await handleResponse(response);
    
    // Map DBT volume structure to our app's expected structure
    return books.map(book => ({
      id: book.id,
      name: book.name,
      abbr: book.abbreviation || book.id.substring(0, 3).toUpperCase(),
      testament: book.testament === 'NT' ? 'NT' : 'OT',
      chapters: book.chapters || []
    }));
  } catch (error) {
    console.error("Error fetching books:", error);
    throw error;
  }
}

export async function getChapter(bookId, chapterNum) {
  try {
    const versionId = await findTextVersion();
    
    // DBT Endpoint: /bibles/{version_id}/chapters/{book_id}/{chapter_num}
    const response = await fetch(
      `${API_BASE_URL}/bibles/${versionId}/chapters/${bookId}/${chapterNum}`,
      { headers: { 'X-API-Key': API_KEY } }
    );
    
    const chapterData = await handleResponse(response);
    
    // Format verses for the UI
    const verses = chapterData.verses?.map(v => ({
      number: v.num || v.number,
      text: v.text
    })) || [];

    return {
      bookId,
      chapterNum,
      versionId,
      verses,
      reference: `${bookId} ${chapterNum}`
    };
  } catch (error) {
    console.error("Error fetching chapter:", error);
    throw error;
  }
}

export async function getVerse(reference) {
  // For single verse, we can use search or parse and fetch chapter
  const parts = reference.split(' ');
  if (parts.length < 2) throw new Error('Invalid reference format');
  
  const bookName = parts.slice(0, -1).join(' ');
  const chapterVerse = parts[parts.length - 1].split(':');
  const chapter = chapterVerse[0];
  const verseNum = chapterVerse[1] || null;
  
  // Find book ID from name (simplified)
  const bookId = bookName.replace(/ /g, '').toUpperCase(); 
  
  const chapterData = await getChapter(bookId, chapter);
  if (verseNum) {
    const verse = chapterData.verses.find(v => v.number === parseInt(verseNum));
    return verse ? { ...verse, reference } : null;
  }
  return chapterData;
}

export async function search(query) {
  try {
    const versionId = await findTextVersion();
    const encodedQuery = encodeURIComponent(query);
    
    const response = await fetch(
      `${API_BASE_URL}/bibles/${versionId}/search?q=${encodedQuery}`,
      { headers: { 'X-API-Key': API_KEY } }
    );
    
    const results = await handleResponse(response);
    
    return results.map(item => ({
      bookId: item.volume_id || item.book_id,
      chapter: item.chapter_start,
      verse: item.verse_start,
      text: item.text,
      reference: `${item.book_name || item.book_id} ${item.chapter_start}:${item.verse_start}`
    }));
  } catch (error) {
    console.error("Error searching:", error);
    return [];
  }
}

export async function getAudioUrl(bookId, chapterNum) {
  try {
    const versionId = await findAudioVersion();
    if (!versionId) return null;

    // DBT Endpoint: /bibles/{version_id}/chapters/{book_id}/{chapter_num}
    // Audio versions return media info in the chapter response
    const response = await fetch(
      `${API_BASE_URL}/bibles/${versionId}/chapters/${bookId}/${chapterNum}`,
      { headers: { 'X-API-Key': API_KEY } }
    );
    
    if (!response.ok) return null;
    
    const audioData = await handleResponse(response);
    
    // Check for direct URL in response
    if (audioData.path && audioData.path.startsWith('http')) {
      return audioData.path;
    }
    
    // Some DBT audio providers use a different structure
    if (audioData.media && audioData.media.url) {
      return audioData.media.url;
    }
    
    return null;
  } catch (error) {
    console.error("Error fetching audio:", error);
    return null;
  }
}

// Book mappings for fallback/manual reference
export const BOOKS = [
  { id: 'GEN', name: 'Genesis', abbr: 'Gen', testament: 'OT', chapters: 50 },
  { id: 'EXO', name: 'Exodus', abbr: 'Exo', testament: 'OT', chapters: 40 },
  { id: 'LEV', name: 'Leviticus', abbr: 'Lev', testament: 'OT', chapters: 27 },
  { id: 'NUM', name: 'Numbers', abbr: 'Num', testament: 'OT', chapters: 36 },
  { id: 'DEU', name: 'Deuteronomy', abbr: 'Deu', testament: 'OT', chapters: 34 },
  { id: 'JOS', name: 'Joshua', abbr: 'Jos', testament: 'OT', chapters: 24 },
  { id: 'JDG', name: 'Judges', abbr: 'Jdg', testament: 'OT', chapters: 21 },
  { id: 'RUT', name: 'Ruth', abbr: 'Rut', testament: 'OT', chapters: 4 },
  { id: '1SA', name: '1 Samuel', abbr: '1Sa', testament: 'OT', chapters: 31 },
  { id: '2SA', name: '2 Samuel', abbr: '2Sa', testament: 'OT', chapters: 24 },
  { id: '1KI', name: '1 Kings', abbr: '1Ki', testament: 'OT', chapters: 22 },
  { id: '2KI', name: '2 Kings', abbr: '2Ki', testament: 'OT', chapters: 25 },
  { id: '1CH', name: '1 Chronicles', abbr: '1Ch', testament: 'OT', chapters: 29 },
  { id: '2CH', name: '2 Chronicles', abbr: '2Ch', testament: 'OT', chapters: 36 },
  { id: 'EZR', name: 'Ezra', abbr: 'Ezr', testament: 'OT', chapters: 10 },
  { id: 'NEH', name: 'Nehemiah', abbr: 'Neh', testament: 'OT', chapters: 13 },
  { id: 'EST', name: 'Esther', abbr: 'Est', testament: 'OT', chapters: 10 },
  { id: 'JOB', name: 'Job', abbr: 'Job', testament: 'OT', chapters: 42 },
  { id: 'PSA', name: 'Psalms', abbr: 'Psa', testament: 'OT', chapters: 150 },
  { id: 'PRO', name: 'Proverbs', abbr: 'Pro', testament: 'OT', chapters: 31 },
  { id: 'ECC', name: 'Ecclesiastes', abbr: 'Ecc', testament: 'OT', chapters: 12 },
  { id: 'SNG', name: 'Song of Solomon', abbr: 'Sol', testament: 'OT', chapters: 8 },
  { id: 'ISA', name: 'Isaiah', abbr: 'Isa', testament: 'OT', chapters: 66 },
  { id: 'JER', name: 'Jeremiah', abbr: 'Jer', testament: 'OT', chapters: 52 },
  { id: 'LAM', name: 'Lamentations', abbr: 'Lam', testament: 'OT', chapters: 5 },
  { id: 'EZK', name: 'Ezekiel', abbr: 'Eze', testament: 'OT', chapters: 48 },
  { id: 'DAN', name: 'Daniel', abbr: 'Dan', testament: 'OT', chapters: 12 },
  { id: 'HOS', name: 'Hosea', abbr: 'Hos', testament: 'OT', chapters: 14 },
  { id: 'JOL', name: 'Joel', abbr: 'Joe', testament: 'OT', chapters: 3 },
  { id: 'AMO', name: 'Amos', abbr: 'Amo', testament: 'OT', chapters: 9 },
  { id: 'OBA', name: 'Obadiah', abbr: 'Oba', testament: 'OT', chapters: 1 },
  { id: 'JON', name: 'Jonah', abbr: 'Jon', testament: 'OT', chapters: 4 },
  { id: 'MIC', name: 'Micah', abbr: 'Mic', testament: 'OT', chapters: 7 },
  { id: 'NAM', name: 'Nahum', abbr: 'Nah', testament: 'OT', chapters: 3 },
  { id: 'HAB', name: 'Habakkuk', abbr: 'Hab', testament: 'OT', chapters: 3 },
  { id: 'ZEP', name: 'Zephaniah', abbr: 'Zep', testament: 'OT', chapters: 3 },
  { id: 'HAG', name: 'Haggai', abbr: 'Hag', testament: 'OT', chapters: 2 },
  { id: 'ZEC', name: 'Zechariah', abbr: 'Zec', testament: 'OT', chapters: 14 },
  { id: 'MAL', name: 'Malachi', abbr: 'Mal', testament: 'OT', chapters: 4 },
  { id: 'MAT', name: 'Matthew', abbr: 'Mat', testament: 'NT', chapters: 28 },
  { id: 'MRK', name: 'Mark', abbr: 'Mar', testament: 'NT', chapters: 16 },
  { id: 'LUK', name: 'Luke', abbr: 'Luk', testament: 'NT', chapters: 24 },
  { id: 'JHN', name: 'John', abbr: 'Joh', testament: 'NT', chapters: 21 },
  { id: 'ACT', name: 'Acts', abbr: 'Act', testament: 'NT', chapters: 28 },
  { id: 'ROM', name: 'Romans', abbr: 'Rom', testament: 'NT', chapters: 16 },
  { id: '1CO', name: '1 Corinthians', abbr: '1Co', testament: 'NT', chapters: 16 },
  { id: '2CO', name: '2 Corinthians', abbr: '2Co', testament: 'NT', chapters: 13 },
  { id: 'GAL', name: 'Galatians', abbr: 'Gal', testament: 'NT', chapters: 6 },
  { id: 'EPH', name: 'Ephesians', abbr: 'Eph', testament: 'NT', chapters: 6 },
  { id: 'PHP', name: 'Philippians', abbr: 'Phi', testament: 'NT', chapters: 4 },
  { id: 'COL', name: 'Colossians', abbr: 'Col', testament: 'NT', chapters: 4 },
  { id: '1TH', name: '1 Thessalonians', abbr: '1Th', testament: 'NT', chapters: 5 },
  { id: '2TH', name: '2 Thessalonians', abbr: '2Th', testament: 'NT', chapters: 3 },
  { id: '1TI', name: '1 Timothy', abbr: '1Ti', testament: 'NT', chapters: 6 },
  { id: '2TI', name: '2 Timothy', abbr: '2Ti', testament: 'NT', chapters: 4 },
  { id: 'TIT', name: 'Titus', abbr: 'Tit', testament: 'NT', chapters: 3 },
  { id: 'PHM', name: 'Philemon', abbr: 'Phm', testament: 'NT', chapters: 1 },
  { id: 'HEB', name: 'Hebrews', abbr: 'Heb', testament: 'NT', chapters: 13 },
  { id: 'JAS', name: 'James', abbr: 'Jam', testament: 'NT', chapters: 5 },
  { id: '1PE', name: '1 Peter', abbr: '1Pe', testament: 'NT', chapters: 5 },
  { id: '2PE', name: '2 Peter', abbr: '2Pe', testament: 'NT', chapters: 3 },
  { id: '1JN', name: '1 John', abbr: '1Jo', testament: 'NT', chapters: 5 },
  { id: '2JN', name: '2 John', abbr: '2Jo', testament: 'NT', chapters: 1 },
  { id: '3JN', name: '3 John', abbr: '3Jo', testament: 'NT', chapters: 1 },
  { id: 'JUD', name: 'Jude', abbr: 'Jud', testament: 'NT', chapters: 1 },
  { id: 'REV', name: 'Revelation', abbr: 'Rev', testament: 'NT', chapters: 22 },
];

// Inspirational verses for "Verse of the Day"
export const VERSE_OF_THE_DAY_POOL = [
  'John 3:16',
  'Psalm 23:1',
  'Psalm 23:4',
  'Philippians 4:13',
  'Jeremiah 29:11',
  'Romans 8:28',
  'Proverbs 3:5',
  'Proverbs 3:6',
  'Isaiah 40:31',
  'Psalm 46:10',
  'Matthew 6:33',
  'Matthew 11:28',
  '2 Corinthians 5:17',
  'Galatians 2:20',
  'Ephesians 2:8',
  'Hebrews 11:1',
  'James 1:5',
  '1 Peter 5:7',
  '1 John 4:19',
  'Psalm 27:1',
  'Psalm 34:8',
  'Psalm 91:1',
  'Psalm 119:105',
  'Proverbs 16:3',
  'Romans 12:2',
  'Romans 15:13',
  '1 Corinthians 13:4',
  'Galatians 5:22',
  'Philippians 4:6',
  'Philippians 4:7',
  'Colossians 3:23',
  'Hebrews 12:2',
  'Revelation 21:4',
  'Matthew 5:16',
  'Matthew 28:19',
  'Luke 1:37',
  'John 14:6',
  'John 16:33',
  '1 Corinthians 10:13',
];

export function getVerseOfTheDay() {
  const today = new Date().toDateString();
  let hash = 0;
  for (let i = 0; i < today.length; i++) {
    hash = ((hash << 5) - hash) + today.charCodeAt(i);
    hash |= 0;
  }
  const index = Math.abs(hash) % VERSE_OF_THE_DAY_POOL.length;
  return VERSE_OF_THE_DAY_POOL[index];
}
