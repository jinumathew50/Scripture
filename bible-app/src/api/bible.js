// Bible API Service using bible-api.com (Free, no API key required)
const BASE_URL = 'https://bible-api.com';

/**
 * Map of book names to their IDs used by bible-api.com
 */
const BOOK_NAME_MAP = {
  'GEN': 'genesis', 'EXO': 'exodus', 'LEV': 'leviticus', 'NUM': 'numbers',
  'DEU': 'deuteronomy', 'JOS': 'joshua', 'JDG': 'judges', 'RUT': 'ruth',
  '1SA': '1samuel', '2SA': '2samuel', '1KI': '1kings', '2KI': '2kings',
  '1CH': '1chronicles', '2CH': '2chronicles', 'EZR': 'ezra', 'NEH': 'nehemiah',
  'EST': 'esther', 'JOB': 'job', 'PSA': 'psalms', 'PRO': 'proverbs',
  'ECC': 'ecclesiastes', 'SNG': 'songofsolomon', 'ISA': 'isaiah', 'JER': 'jeremiah',
  'LAM': 'lamentations', 'EZK': 'ezekiel', 'DAN': 'daniel', 'HOS': 'hosea',
  'JOL': 'joel', 'AMO': 'amos', 'OBA': 'obadiah', 'JON': 'jonah',
  'MIC': 'micah', 'NAM': 'nahum', 'HAB': 'habakkuk', 'ZEP': 'zephaniah',
  'HAG': 'haggai', 'ZEC': 'zechariah', 'MAL': 'malachi',
  'MAT': 'matthew', 'MRK': 'mark', 'LUK': 'luke', 'JHN': 'john',
  'ACT': 'acts', 'ROM': 'romans', '1CO': '1corinthians', '2CO': '2corinthians',
  'GAL': 'galatians', 'EPH': 'ephesians', 'PHP': 'philippians', 'COL': 'colossians',
  '1TH': '1thessalonians', '2TH': '2thessalonians', '1TI': '1timothy', '2TI': '2timothy',
  'TIT': 'titus', 'PHM': 'philemon', 'HEB': 'hebrews', 'JAS': 'james',
  '1PE': '1peter', '2PE': '2peter', '1JN': '1john', '2JN': '2john',
  '3JN': '3john', 'JUD': 'jude', 'REV': 'revelation'
};

/**
 * Fetches the list of all Bible books
 */
export const getBooks = async () => {
  try {
    // bible-api.com doesn't have a books endpoint, so we use our static list
    return BOOKS.map(book => ({
      id: book.id,
      name: book.name,
      abbr: book.abbr,
      testament: book.testament,
      chapters: book.chapters
    }));
  } catch (error) {
    console.error('Error fetching books:', error);
    throw error;
  }
};

/**
 * Fetches a specific chapter with all its verses
 * @param {string} bookId - Book ID (e.g., 'GEN', 'JHN')
 * @param {number} chapterNum - Chapter number
 */
export const getChapter = async (bookId, chapterNum) => {
  try {
    const bookName = BOOK_NAME_MAP[bookId];
    if (!bookName) {
      throw new Error(`Unknown book ID: ${bookId}`);
    }

    const url = `${BASE_URL}/${bookName}+${chapterNum}`;
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Failed to fetch chapter: ${response.status}`);
    }

    const data = await response.json();
    
    if (data.error) {
      throw new Error(data.error);
    }

    return {
      bookId,
      chapterNum,
      versionId: data.translation_id || 'web',
      versionName: data.translation_name || 'World English Bible',
      verses: data.verses?.map(v => ({
        number: v.verse,
        text: v.text.trim()
      })) || [],
      reference: `${bookId} ${chapterNum}`
    };
  } catch (error) {
    console.error('Error fetching chapter:', error);
    throw error;
  }
};

/**
 * Fetches a single verse by reference
 * @param {string} reference - Verse reference (e.g., 'John 3:16')
 */
export const getVerse = async (reference) => {
  try {
    const formattedRef = reference.toLowerCase().replace(/ /g, '+').replace(':', '+');
    const url = `${BASE_URL}/${formattedRef}`;
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Failed to fetch verse: ${response.status}`);
    }

    const data = await response.json();
    
    if (data.error) {
      throw new Error(data.error);
    }

    return {
      reference: data.reference,
      text: data.text,
      versionId: data.translation_id,
      verses: data.verses
    };
  } catch (error) {
    console.error('Error fetching verse:', error);
    throw error;
  }
};

/**
 * Search for verses containing a query
 * Note: bible-api.com doesn't support search, so we return empty array
 */
export const search = async (query) => {
  console.log('Search not available with current API');
  return [];
};

/**
 * Get audio URL for a chapter
 * Note: bible-api.com doesn't provide audio, so we return null
 */
export const getAudioUrl = async (bookId, chapterNum) => {
  console.log('Audio not available with current API');
  return null;
};

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
