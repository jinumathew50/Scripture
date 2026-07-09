import { useState } from 'react';
import { useTheme } from './hooks/ThemeProvider.jsx';
import { useBible } from './hooks/useBible.js';
import Header from './components/Header.jsx';
import './App.css';

function App() {
  const { theme, palette, fontSize } = useTheme();
  const { 
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
    prevChapter
  } = useBible();
  
  const [showMenu, setShowMenu] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeTab, setActiveTab] = useState('home');

  const OTBooks = books.filter(b => b.testament === 'OT' || (b.name && isOT(b.name)));
  const NTBooks = books.filter(b => b.testament === 'NT' || (b.name && !isOT(b.name)));

  function isOT(bookName) {
    const otBooks = ['Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth', 
      '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 
      'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 
      'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos', 'Obadiah', 'Jonah', 'Micah', 
      'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'];
    return otBooks.includes(bookName);
  }

  const getBookChapters = (bookName) => {
    const book = books.find(b => b.name === bookName || b.id === bookName);
    return book ? book.chapters : 0;
  };

  const handleSearch = (e) => {
    e.preventDefault();
    // Simple search implementation
    console.log('Searching for:', searchQuery);
  };

  return (
    <div className="app" style={{ 
      backgroundColor: palette.background, 
      color: palette.text,
      minHeight: '100vh'
    }}>
      <Header 
        onMenuClick={() => setShowMenu(!showMenu)}
        onSearchClick={() => setShowSearch(!showSearch)}
      />

      {/* Search Panel */}
      {showSearch && (
        <div className="search-panel" style={{ backgroundColor: palette.surface }}>
          <form onSubmit={handleSearch} style={{ display: 'flex', gap: '8px', padding: '16px' }}>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search the Bible..."
              style={{
                flex: 1,
                padding: '10px 14px',
                borderRadius: '8px',
                border: `1px solid ${palette.border}`,
                backgroundColor: palette.background,
                color: palette.text,
                fontSize: `${fontSize}px`,
              }}
            />
            <button 
              type="submit"
              style={{
                padding: '10px 20px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: palette.brand,
                color: '#fff',
                cursor: 'pointer',
                fontWeight: '500',
              }}
            >
              Search
            </button>
          </form>
        </div>
      )}

      {/* Side Menu */}
      {showMenu && (
        <div className="menu-overlay" onClick={() => setShowMenu(false)}>
          <div 
            className="side-menu" 
            onClick={(e) => e.stopPropagation()}
            style={{ backgroundColor: palette.surface }}
          >
            <div className="menu-header">
              <h2 style={{ fontFamily: "'Playfair Display', serif", margin: 0 }}>Books</h2>
              <button onClick={() => setShowMenu(false)} className="close-btn">×</button>
            </div>
            
            <div className="menu-content">
              <h3 style={{ fontSize: '12px', textTransform: 'uppercase', letterSpacing: '1px', color: palette.textTertiary, marginBottom: '8px' }}>Old Testament</h3>
              <div className="book-grid">
                {OTBooks.map(book => (
                  <button
                    key={book.name || book.id}
                    className={`book-btn ${currentBook === (book.name || book.id) ? 'active' : ''}`}
                    onClick={() => {
                      navigateToBook(book.name || book.id);
                      setShowMenu(false);
                    }}
                    style={{
                      backgroundColor: currentBook === (book.name || book.id) ? palette.brandLight : 'transparent',
                      color: currentBook === (book.name || book.id) ? palette.text : palette.textSecondary,
                    }}
                  >
                    {book.abbr || book.name?.substring(0, 3) || book.id?.substring(0, 3)}
                  </button>
                ))}
              </div>
              
              <h3 style={{ fontSize: '12px', textTransform: 'uppercase', letterSpacing: '1px', color: palette.textTertiary, marginTop: '20px', marginBottom: '8px' }}>New Testament</h3>
              <div className="book-grid">
                {NTBooks.map(book => (
                  <button
                    key={book.name || book.id}
                    className={`book-btn ${currentBook === (book.name || book.id) ? 'active' : ''}`}
                    onClick={() => {
                      navigateToBook(book.name || book.id);
                      setShowMenu(false);
                    }}
                    style={{
                      backgroundColor: currentBook === (book.name || book.id) ? palette.brandLight : 'transparent',
                      color: currentBook === (book.name || book.id) ? palette.text : palette.textSecondary,
                    }}
                  >
                    {book.abbr || book.name?.substring(0, 3) || book.id?.substring(0, 3)}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Main Content */}
      <main className="main-content">
        {activeTab === 'home' && (
          <>
            {/* Verse of the Day Card */}
            {verseOfDay && (
              <div className="votd-card" style={{ 
                background: `linear-gradient(135deg, ${palette.brand}22, ${palette.brand}11)`,
                borderColor: palette.border
              }}>
                <div className="votd-label">Verse of the Day</div>
                <blockquote className="votd-text">
                  "{verseOfDay.text}"
                </blockquote>
                <cite className="votd-reference">
                  — {verseOfDay.reference}
                </cite>
                <button 
                  className="read-votd-btn"
                  onClick={() => {
                    const [book, chapterVerse] = verseOfDay.reference.split(' ');
                    const [chapter, verse] = chapterVerse.split(':');
                    navigateToBook(book);
                    navigateToChapter(parseInt(chapter));
                  }}
                >
                  Read Chapter
                </button>
              </div>
            )}

            {/* Current Reading */}
            <div className="reading-section">
              <div className="chapter-header">
                <button onClick={prevChapter} className="nav-btn" disabled={loading}>←</button>
                <div className="chapter-info">
                  <h2 style={{ fontFamily: "'Playfair Display', serif", margin: 0, fontSize: `${fontSize + 4}px` }}>
                    {currentBook} {currentChapter}
                  </h2>
                </div>
                <button onClick={nextChapter} className="nav-btn" disabled={loading}>→</button>
              </div>

              {/* Chapter Navigation */}
              <div className="chapter-nav" style={{ backgroundColor: palette.surface }}>
                {Array.from({ length: Math.min(getBookChapters(currentBook), 50) }, (_, i) => i + 1).map(ch => (
                  <button
                    key={ch}
                    className={`chapter-btn ${currentChapter === ch ? 'active' : ''}`}
                    onClick={() => navigateToChapter(ch)}
                    style={{
                      backgroundColor: currentChapter === ch ? palette.brand : 'transparent',
                      color: currentChapter === ch ? '#fff' : palette.textSecondary,
                    }}
                  >
                    {ch}
                  </button>
                ))}
              </div>

              {/* Verses */}
              <div className="verses-container" style={{ fontSize: `${fontSize}px` }}>
                {loading && <div className="loading">Loading chapter...</div>}
                {error && <div className="error">Error: {error}</div>}
                
                {!loading && !error && chapterData?.verses && (
                  chapterData.verses.map(verse => (
                    <div key={verse.verse} className="verse">
                      <sup className="verse-num">{verse.verse}</sup>
                      <span>{verse.text}</span>
                    </div>
                  ))
                )}
                
                {!loading && !error && !chapterData && (
                  <div className="no-data">Select a book and chapter to read</div>
                )}
              </div>
            </div>
          </>
        )}
      </main>

      {/* Bottom Navigation */}
      <nav className="bottom-nav" style={{ backgroundColor: palette.surface, borderTopColor: palette.border }}>
        <button 
          className={`nav-item ${activeTab === 'home' ? 'active' : ''}`}
          onClick={() => setActiveTab('home')}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
            <polyline points="9 22 9 12 15 12 15 22"></polyline>
          </svg>
          <span>Home</span>
        </button>
        <button 
          className={`nav-item ${activeTab === 'read' ? 'active' : ''}`}
          onClick={() => setActiveTab('read')}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
          </svg>
          <span>Read</span>
        </button>
        <button 
          className={`nav-item ${activeTab === 'search' ? 'active' : ''}`}
          onClick={() => setShowSearch(true)}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <span>Search</span>
        </button>
      </nav>
    </div>
  );
}

export default App;
