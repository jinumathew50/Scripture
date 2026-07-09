import { useState, useEffect } from 'react';
import { getChapter, getVerse, getBooks, BOOKS, getVerseOfTheDay } from '../api/bible';

export function useBible() {
  const [books, setBooks] = useState([]);
  const [currentBook, setCurrentBook] = useState('John');
  const [currentChapter, setCurrentChapter] = useState(1);
  const [chapterData, setChapterData] = useState(null);
  const [verseOfDay, setVerseOfDay] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Load books on mount
  useEffect(() => {
    async function loadBooks() {
      try {
        const data = await getBooks();
        setBooks(data);
      } catch (err) {
        // Use local BOOKS if API fails
        setBooks(BOOKS);
      }
    }
    loadBooks();
  }, []);

  // Load verse of the day
  useEffect(() => {
    async function loadVOTD() {
      try {
        const ref = getVerseOfTheDay();
        const data = await getVerse(ref);
        setVerseOfDay(data);
      } catch (err) {
        console.error('Failed to load verse of the day:', err);
      }
    }
    loadVOTD();
  }, []);

  // Load chapter when book/chapter changes
  useEffect(() => {
    async function loadChapter() {
      setLoading(true);
      setError(null);
      try {
        const data = await getChapter(currentBook, currentChapter);
        setChapterData(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }
    if (currentBook && currentChapter) {
      loadChapter();
    }
  }, [currentBook, currentChapter]);

  const navigateToBook = (bookId) => {
    setCurrentBook(bookId);
    setCurrentChapter(1);
  };

  const navigateToChapter = (chapter) => {
    setCurrentChapter(chapter);
  };

  const nextChapter = () => {
    const book = BOOKS.find(b => b.name === currentBook || b.id === currentBook);
    if (book && currentChapter < book.chapters) {
      setCurrentChapter(currentChapter + 1);
    } else if (book) {
      // Try to go to next book
      const idx = BOOKS.findIndex(b => b.name === currentBook || b.id === currentBook);
      if (idx < BOOKS.length - 1) {
        setCurrentBook(BOOKS[idx + 1].name);
        setCurrentChapter(1);
      }
    }
  };

  const prevChapter = () => {
    if (currentChapter > 1) {
      setCurrentChapter(currentChapter - 1);
    } else {
      // Try to go to previous book
      const idx = BOOKS.findIndex(b => b.name === currentBook || b.id === currentBook);
      if (idx > 0) {
        const prevBook = BOOKS[idx - 1];
        setCurrentBook(prevBook.name);
        setCurrentChapter(prevBook.chapters);
      }
    }
  };

  return {
    books: books.length > 0 ? books : BOOKS,
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
