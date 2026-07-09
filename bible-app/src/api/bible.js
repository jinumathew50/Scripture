// Bible API using free bible-api.com for KJV text
const BASE_URL = 'https://bible-api.com';

export async function getBooks() {
  const response = await fetch(`${BASE_URL}/books`);
  if (!response.ok) throw new Error('Failed to fetch books');
  return response.json();
}

export async function getChapter(book, chapter) {
  const response = await fetch(`${BASE_URL}/${book}/${chapter}`);
  if (!response.ok) throw new Error('Failed to fetch chapter');
  return response.json();
}

export async function getVerse(reference) {
  const response = await fetch(`${BASE_URL}/${reference}`);
  if (!response.ok) throw new Error('Failed to fetch verse');
  return response.json();
}

export async function search(query) {
  // Simple search - fetch all and filter (bible-api.com doesn't have search endpoint)
  // For production, use a proper Bible API with search
  const response = await fetch(`${BASE_URL}/search?q=${encodeURIComponent(query)}&translation=kjv`);
  if (!response.ok) throw new Error('Search failed');
  return response.json();
}

// Book mappings
export const BOOKS = [
  { id: 'Genesis', name: 'Genesis', abbr: 'Gen', testament: 'OT', chapters: 50 },
  { id: 'Exodus', name: 'Exodus', abbr: 'Exo', testament: 'OT', chapters: 40 },
  { id: 'Leviticus', name: 'Leviticus', abbr: 'Lev', testament: 'OT', chapters: 27 },
  { id: 'Numbers', name: 'Numbers', abbr: 'Num', testament: 'OT', chapters: 36 },
  { id: 'Deuteronomy', name: 'Deuteronomy', abbr: 'Deu', testament: 'OT', chapters: 34 },
  { id: 'Joshua', name: 'Joshua', abbr: 'Jos', testament: 'OT', chapters: 24 },
  { id: 'Judges', name: 'Judges', abbr: 'Jdg', testament: 'OT', chapters: 21 },
  { id: 'Ruth', name: 'Ruth', abbr: 'Rut', testament: 'OT', chapters: 4 },
  { id: '1 Samuel', name: '1 Samuel', abbr: '1Sa', testament: 'OT', chapters: 31 },
  { id: '2 Samuel', name: '2 Samuel', abbr: '2Sa', testament: 'OT', chapters: 24 },
  { id: '1 Kings', name: '1 Kings', abbr: '1Ki', testament: 'OT', chapters: 22 },
  { id: '2 Kings', name: '2 Kings', abbr: '2Ki', testament: 'OT', chapters: 25 },
  { id: '1 Chronicles', name: '1 Chronicles', abbr: '1Ch', testament: 'OT', chapters: 29 },
  { id: '2 Chronicles', name: '2 Chronicles', abbr: '2Ch', testament: 'OT', chapters: 36 },
  { id: 'Ezra', name: 'Ezra', abbr: 'Ezr', testament: 'OT', chapters: 10 },
  { id: 'Nehemiah', name: 'Nehemiah', abbr: 'Neh', testament: 'OT', chapters: 13 },
  { id: 'Esther', name: 'Esther', abbr: 'Est', testament: 'OT', chapters: 10 },
  { id: 'Job', name: 'Job', abbr: 'Job', testament: 'OT', chapters: 42 },
  { id: 'Psalms', name: 'Psalms', abbr: 'Psa', testament: 'OT', chapters: 150 },
  { id: 'Proverbs', name: 'Proverbs', abbr: 'Pro', testament: 'OT', chapters: 31 },
  { id: 'Ecclesiastes', name: 'Ecclesiastes', abbr: 'Ecc', testament: 'OT', chapters: 12 },
  { id: 'Song of Solomon', name: 'Song of Solomon', abbr: 'Sol', testament: 'OT', chapters: 8 },
  { id: 'Isaiah', name: 'Isaiah', abbr: 'Isa', testament: 'OT', chapters: 66 },
  { id: 'Jeremiah', name: 'Jeremiah', abbr: 'Jer', testament: 'OT', chapters: 52 },
  { id: 'Lamentations', name: 'Lamentations', abbr: 'Lam', testament: 'OT', chapters: 5 },
  { id: 'Ezekiel', name: 'Ezekiel', abbr: 'Eze', testament: 'OT', chapters: 48 },
  { id: 'Daniel', name: 'Daniel', abbr: 'Dan', testament: 'OT', chapters: 12 },
  { id: 'Hosea', name: 'Hosea', abbr: 'Hos', testament: 'OT', chapters: 14 },
  { id: 'Joel', name: 'Joel', abbr: 'Joe', testament: 'OT', chapters: 3 },
  { id: 'Amos', name: 'Amos', abbr: 'Amo', testament: 'OT', chapters: 9 },
  { id: 'Obadiah', name: 'Obadiah', abbr: 'Oba', testament: 'OT', chapters: 1 },
  { id: 'Jonah', name: 'Jonah', abbr: 'Jon', testament: 'OT', chapters: 4 },
  { id: 'Micah', name: 'Micah', abbr: 'Mic', testament: 'OT', chapters: 7 },
  { id: 'Nahum', name: 'Nahum', abbr: 'Nah', testament: 'OT', chapters: 3 },
  { id: 'Habakkuk', name: 'Habakkuk', abbr: 'Hab', testament: 'OT', chapters: 3 },
  { id: 'Zephaniah', name: 'Zephaniah', abbr: 'Zep', testament: 'OT', chapters: 3 },
  { id: 'Haggai', name: 'Haggai', abbr: 'Hag', testament: 'OT', chapters: 2 },
  { id: 'Zechariah', name: 'Zechariah', abbr: 'Zec', testament: 'OT', chapters: 14 },
  { id: 'Malachi', name: 'Malachi', abbr: 'Mal', testament: 'OT', chapters: 4 },
  { id: 'Matthew', name: 'Matthew', abbr: 'Mat', testament: 'NT', chapters: 28 },
  { id: 'Mark', name: 'Mark', abbr: 'Mar', testament: 'NT', chapters: 16 },
  { id: 'Luke', name: 'Luke', abbr: 'Luk', testament: 'NT', chapters: 24 },
  { id: 'John', name: 'John', abbr: 'Joh', testament: 'NT', chapters: 21 },
  { id: 'Acts', name: 'Acts', abbr: 'Act', testament: 'NT', chapters: 28 },
  { id: 'Romans', name: 'Romans', abbr: 'Rom', testament: 'NT', chapters: 16 },
  { id: '1 Corinthians', name: '1 Corinthians', abbr: '1Co', testament: 'NT', chapters: 16 },
  { id: '2 Corinthians', name: '2 Corinthians', abbr: '2Co', testament: 'NT', chapters: 13 },
  { id: 'Galatians', name: 'Galatians', abbr: 'Gal', testament: 'NT', chapters: 6 },
  { id: 'Ephesians', name: 'Ephesians', abbr: 'Eph', testament: 'NT', chapters: 6 },
  { id: 'Philippians', name: 'Philippians', abbr: 'Phi', testament: 'NT', chapters: 4 },
  { id: 'Colossians', name: 'Colossians', abbr: 'Col', testament: 'NT', chapters: 4 },
  { id: '1 Thessalonians', name: '1 Thessalonians', abbr: '1Th', testament: 'NT', chapters: 5 },
  { id: '2 Thessalonians', name: '2 Thessalonians', abbr: '2Th', testament: 'NT', chapters: 3 },
  { id: '1 Timothy', name: '1 Timothy', abbr: '1Ti', testament: 'NT', chapters: 6 },
  { id: '2 Timothy', name: '2 Timothy', abbr: '2Ti', testament: 'NT', chapters: 4 },
  { id: 'Titus', name: 'Titus', abbr: 'Tit', testament: 'NT', chapters: 3 },
  { id: 'Philemon', name: 'Philemon', abbr: 'Phm', testament: 'NT', chapters: 1 },
  { id: 'Hebrews', name: 'Hebrews', abbr: 'Heb', testament: 'NT', chapters: 13 },
  { id: 'James', name: 'James', abbr: 'Jam', testament: 'NT', chapters: 5 },
  { id: '1 Peter', name: '1 Peter', abbr: '1Pe', testament: 'NT', chapters: 5 },
  { id: '2 Peter', name: '2 Peter', abbr: '2Pe', testament: 'NT', chapters: 3 },
  { id: '1 John', name: '1 John', abbr: '1Jo', testament: 'NT', chapters: 5 },
  { id: '2 John', name: '2 John', abbr: '2Jo', testament: 'NT', chapters: 1 },
  { id: '3 John', name: '3 John', abbr: '3Jo', testament: 'NT', chapters: 1 },
  { id: 'Jude', name: 'Jude', abbr: 'Jud', testament: 'NT', chapters: 1 },
  { id: 'Revelation', name: 'Revelation', abbr: 'Rev', testament: 'NT', chapters: 22 },
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
