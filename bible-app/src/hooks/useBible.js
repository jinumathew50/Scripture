import { useState, useEffect } from 'react';
import { fetchBooks, fetchChapter, getBookId } from '../api/bibleBrain';

// Static fallback for book data (chapter counts) since BibleBrain API might have CORS issues on free tier
const BOOKS = [
  { name: "Genesis", id: "GEN", chapters: 50, testament: "OT" },
  { name: "Exodus", id: "EXO", chapters: 40, testament: "OT" },
  { name: "Leviticus", id: "LEV", chapters: 27, testament: "OT" },
  { name: "Numbers", id: "NUM", chapters: 36, testament: "OT" },
  { name: "Deuteronomy", id: "DEU", chapters: 34, testament: "OT" },
  { name: "Joshua", id: "JOS", chapters: 24, testament: "OT" },
  { name: "Judges", id: "JDG", chapters: 21, testament: "OT" },
  { name: "Ruth", id: "RUT", chapters: 4, testament: "OT" },
  { name: "1 Samuel", id: "1SA", chapters: 31, testament: "OT" },
  { name: "2 Samuel", id: "2SA", chapters: 24, testament: "OT" },
  { name: "1 Kings", id: "1KI", chapters: 22, testament: "OT" },
  { name: "2 Kings", id: "2KI", chapters: 25, testament: "OT" },
  { name: "1 Chronicles", id: "1CH", chapters: 29, testament: "OT" },
  { name: "2 Chronicles", id: "2CH", chapters: 36, testament: "OT" },
  { name: "Ezra", id: "EZR", chapters: 10, testament: "OT" },
  { name: "Nehemiah", id: "NEH", chapters: 13, testament: "OT" },
  { name: "Esther", id: "EST", chapters: 10, testament: "OT" },
  { name: "Job", id: "JOB", chapters: 42, testament: "OT" },
  { name: "Psalms", id: "PSA", chapters: 150, testament: "OT" },
  { name: "Proverbs", id: "PRO", chapters: 31, testament: "OT" },
  { name: "Ecclesiastes", id: "ECC", chapters: 12, testament: "OT" },
  { name: "Song of Solomon", id: "SNG", chapters: 8, testament: "OT" },
  { name: "Isaiah", id: "ISA", chapters: 66, testament: "OT" },
  { name: "Jeremiah", id: "JER", chapters: 52, testament: "OT" },
  { name: "Lamentations", id: "LAM", chapters: 5, testament: "OT" },
  { name: "Ezekiel", id: "EZK", chapters: 48, testament: "OT" },
  { name: "Daniel", id: "DAN", chapters: 12, testament: "OT" },
  { name: "Hosea", id: "HOS", chapters: 14, testament: "OT" },
  { name: "Joel", id: "JOL", chapters: 3, testament: "OT" },
  { name: "Amos", id: "AMO", chapters: 9, testament: "OT" },
  { name: "Obadiah", id: "OBA", chapters: 1, testament: "OT" },
  { name: "Jonah", id: "JON", chapters: 4, testament: "OT" },
  { name: "Micah", id: "MIC", chapters: 7, testament: "OT" },
  { name: "Nahum", id: "NAM", chapters: 3, testament: "OT" },
  { name: "Habakkuk", id: "HAB", chapters: 3, testament: "OT" },
  { name: "Zephaniah", id: "ZEP", chapters: 3, testament: "OT" },
  { name: "Haggai", id: "HAG", chapters: 2, testament: "OT" },
  { name: "Zechariah", id: "ZEC", chapters: 14, testament: "OT" },
  { name: "Malachi", id: "MAL", chapters: 4, testament: "OT" },
  { name: "Matthew", id: "MAT", chapters: 28, testament: "NT" },
  { name: "Mark", id: "MRK", chapters: 16, testament: "NT" },
  { name: "Luke", id: "LUK", chapters: 24, testament: "NT" },
  { name: "John", id: "JHN", chapters: 21, testament: "NT" },
  { name: "Acts", id: "ACT", chapters: 28, testament: "NT" },
  { name: "Romans", id: "ROM", chapters: 16, testament: "NT" },
  { name: "1 Corinthians", id: "1CO", chapters: 16, testament: "NT" },
  { name: "2 Corinthians", id: "2CO", chapters: 13, testament: "NT" },
  { name: "Galatians", id: "GAL", chapters: 6, testament: "NT" },
  { name: "Ephesians", id: "EPH", chapters: 6, testament: "NT" },
  { name: "Philippians", id: "PHI", chapters: 4, testament: "NT" },
  { name: "Colossians", id: "COL", chapters: 4, testament: "NT" },
  { name: "1 Thessalonians", id: "1TH", chapters: 5, testament: "NT" },
  { name: "2 Thessalonians", id: "2TH", chapters: 3, testament: "NT" },
  { name: "1 Timothy", id: "1TI", chapters: 6, testament: "NT" },
  { name: "2 Timothy", id: "2TI", chapters: 4, testament: "NT" },
  { name: "Titus", id: "TIT", chapters: 3, testament: "NT" },
  { name: "Philemon", id: "PHM", chapters: 1, testament: "NT" },
  { name: "Hebrews", id: "HEB", chapters: 13, testament: "NT" },
  { name: "James", id: "JAS", chapters: 5, testament: "NT" },
  { name: "1 Peter", id: "1PE", chapters: 5, testament: "NT" },
  { name: "2 Peter", id: "2PE", chapters: 3, testament: "NT" },
  { name: "1 John", id: "1JN", chapters: 5, testament: "NT" },
  { name: "2 John", id: "2JN", chapters: 1, testament: "NT" },
  { name: "3 John", id: "3JN", chapters: 1, testament: "NT" },
  { name: "Jude", id: "JUD", chapters: 1, testament: "NT" },
  { name: "Revelation", id: "REV", chapters: 22, testament: "NT" }
];

export function useBible() {
  const [books, setBooks] = useState(BOOKS);
  const [currentBook, setCurrentBook] = useState('John');
  const [currentChapter, setCurrentChapter] = useState(1);
  const [chapterData, setChapterData] = useState(null);
  const [verseOfDay, setVerseOfDay] = useState({ text: "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.", reference: "John 3:16" });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  // Load books on mount (try API first, fallback to static)
  useEffect(() => {
    async function loadBooks() {
      try {
        const data = await fetchBooks();
        if (data && data.length > 0) {
          // Merge API data with our static chapter counts
          const merged = data.map(apiBook => {
            const staticBook = BOOKS.find(b => b.id === apiBook.id || b.name === apiBook.name);
            return {
              ...apiBook,
              chapters: staticBook ? staticBook.chapters : 0,
              testament: staticBook ? staticBook.testament : 'OT'
            };
          });
          setBooks(merged);
        }
      } catch (err) {
        console.warn('Using static book list:', err.message);
        setBooks(BOOKS);
      }
    }
    loadBooks();
  }, []);

  // Load chapter when book/chapter changes
  useEffect(() => {
    async function loadChapter() {
      setLoading(true);
      setError(null);
      try {
        const bookId = getBookId(currentBook);
        const data = await fetchChapter(bookId, currentChapter);
        
        // Transform BibleBrain response to our app's format
        if (data && data.verses) {
          const formattedVerses = data.verses.map(v => ({
            verse: v.number,
            text: v.content
          }));
          setChapterData({ verses: formattedVerses });
        } else {
          throw new Error('Invalid chapter data format');
        }
      } catch (err) {
        console.error('Failed to load chapter:', err);
        setError(err.message || 'Failed to load chapter. Please check your internet connection.');
      } finally {
        setLoading(false);
      }
    }
    if (currentBook && currentChapter) {
      loadChapter();
    }
  }, [currentBook, currentChapter]);

  const navigateToBook = (bookName) => {
    setCurrentBook(bookName);
    setCurrentChapter(1);
  };

  const navigateToChapter = (chapter) => {
    setCurrentChapter(chapter);
  };

  const nextChapter = () => {
    const book = books.find(b => b.name === currentBook || b.id === currentBook);
    if (book && currentChapter < book.chapters) {
      setCurrentChapter(currentChapter + 1);
    } else if (book) {
      // Try to go to next book
      const idx = books.findIndex(b => b.name === currentBook || b.id === currentBook);
      if (idx < books.length - 1) {
        setCurrentBook(books[idx + 1].name);
        setCurrentChapter(1);
      }
    }
  };

  const prevChapter = () => {
    if (currentChapter > 1) {
      setCurrentChapter(currentChapter - 1);
    } else {
      // Try to go to previous book
      const idx = books.findIndex(b => b.name === currentBook || b.id === currentBook);
      if (idx > 0) {
        const prevBook = books[idx - 1];
        setCurrentBook(prevBook.name);
        setCurrentChapter(prevBook.chapters);
      }
    }
  };

  return {
    books,
    currentBook,
    currentChapter,
    chapterData,
    verseOfDay,
    loading,
    error,
    navigateToBook,
    navigateToChapter,
    nextChapter,
    prevChapter,
  };
}
