import { useState, useEffect } from 'react';
import './App.css';

// Bible API service
const BIBLE_API_BASE = 'https://bible-api.com';

function App() {
  const [books, setBooks] = useState([]);
  const [selectedBook, setSelectedBook] = useState(null);
  const [selectedChapter, setSelectedChapter] = useState(null);
  const [chapterContent, setChapterContent] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [theme, setTheme] = useState('light');
  const [searchQuery, setSearchQuery] = useState('');
  const [fontSize, setFontSize] = useState(16);

  // Fetch all books of the Bible
  useEffect(() => {
    fetchBooks();
  }, []);

  // Apply theme
  useEffect(() => {
    document.body.className = `${theme}-theme`;
  }, [theme]);

  const fetchBooks = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${BIBLE_API_BASE}/`);
      if (!response.ok) throw new Error('Failed to fetch books');
      const data = await response.json();
      setBooks(data);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const fetchChapter = async (bookName, chapter) => {
    try {
      setLoading(true);
      setError(null);
      const response = await fetch(`${BIBLE_API_BASE}/?reference=${encodeURIComponent(bookName)}+${chapter}&translation=kjv`);
      if (!response.ok) throw new Error('Failed to fetch chapter');
      const data = await response.json();
      setChapterContent(data);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleBookSelect = (book) => {
    setSelectedBook(book);
    setSelectedChapter(null);
    setChapterContent(null);
  };

  const handleChapterSelect = (chapter) => {
    setSelectedChapter(chapter);
    fetchChapter(selectedBook.name, chapter);
  };

  const toggleTheme = () => {
    setTheme(theme === 'light' ? 'dark' : 'light');
  };

  const increaseFontSize = () => {
    setFontSize(prev => Math.min(prev + 2, 24));
  };

  const decreaseFontSize = () => {
    setFontSize(prev => Math.max(prev - 2, 12));
  };

  const filteredBooks = books.filter(book =>
    book.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <div className="header-content">
          <div className="logo">
            <h1>📖 Holy Bible</h1>
            <p>Read & Study God's Word</p>
          </div>
          <div className="header-controls">
            <button onClick={toggleTheme} className="theme-btn" title="Toggle theme">
              {theme === 'light' ? '🌙' : '☀️'}
            </button>
            <div className="font-controls">
              <button onClick={decreaseFontSize} className="font-btn" title="Decrease font size">A-</button>
              <button onClick={increaseFontSize} className="font-btn" title="Increase font size">A+</button>
            </div>
          </div>
        </div>
      </header>

      <div className="main-container">
        {/* Sidebar - Book List */}
        <aside className="sidebar">
          <div className="search-box">
            <input
              type="text"
              placeholder="Search books..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="search-input"
            />
          </div>
          
          <div className="books-list">
            <h3>Old Testament</h3>
            {filteredBooks
              .filter(book => book.testament === 'old')
              .map((book) => (
                <button
                  key={book.book}
                  className={`book-btn ${selectedBook?.book === book.book ? 'active' : ''}`}
                  onClick={() => handleBookSelect(book)}
                >
                  {book.name} ({book.chapters})
                </button>
              ))}
            
            <h3 className="new-testament-header">New Testament</h3>
            {filteredBooks
              .filter(book => book.testament === 'new')
              .map((book) => (
                <button
                  key={book.book}
                  className={`book-btn ${selectedBook?.book === book.book ? 'active' : ''}`}
                  onClick={() => handleBookSelect(book)}
                >
                  {book.name} ({book.chapters})
                </button>
              ))}
          </div>
        </aside>

        {/* Main Content Area */}
        <main className="content-area">
          {!selectedBook ? (
            <div className="welcome-screen">
              <h2>Welcome to the Holy Bible</h2>
              <p>Select a book from the sidebar to begin reading</p>
              <div className="featured-verses">
                <h3>Featured Verses</h3>
                <div className="verse-card">
                  <p>"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."</p>
                  <span>- John 3:16</span>
                </div>
                <div className="verse-card">
                  <p>"The Lord is my shepherd, I lack nothing."</p>
                  <span>- Psalm 23:1</span>
                </div>
              </div>
            </div>
          ) : !selectedChapter ? (
            <div className="chapter-selection">
              <h2>{selectedBook.name}</h2>
              <p className="book-info">{selectedBook.testament} Testament • {selectedBook.chapters} Chapters</p>
              <div className="chapters-grid">
                {Array.from({ length: selectedBook.chapters }, (_, i) => i + 1).map((chapter) => (
                  <button
                    key={chapter}
                    className="chapter-btn"
                    onClick={() => handleChapterSelect(chapter)}
                  >
                    Chapter {chapter}
                  </button>
                ))}
              </div>
            </div>
          ) : loading ? (
            <div className="loading">
              <div className="spinner"></div>
              <p>Loading chapter...</p>
            </div>
          ) : error ? (
            <div className="error">
              <p>Error: {error}</p>
              <button onClick={() => handleChapterSelect(selectedChapter)}>Retry</button>
            </div>
          ) : chapterContent ? (
            <div className="chapter-content" style={{ fontSize: `${fontSize}px` }}>
              <div className="chapter-header">
                <h2>{chapterContent.reference}</h2>
                <button onClick={() => setSelectedChapter(null)} className="back-btn">
                  ← Back to Chapters
                </button>
              </div>
              <div className="verses">
                {chapterContent.verses.map((verse) => (
                  <div key={verse.verse} className="verse">
                    <sup className="verse-number">{verse.verse}</sup>
                    <span>{verse.text}</span>
                  </div>
                ))}
              </div>
            </div>
          ) : null}
        </main>
      </div>

      {/* Footer */}
      <footer className="footer">
        <p>© 2025 Holy Bible App • King James Version</p>
      </footer>
    </div>
  );
}

export default App;
