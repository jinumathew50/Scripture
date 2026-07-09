import { useState } from 'react'
import { useBible } from '../hooks/useBible'

export default function Sidebar({ onSelectBook, selectedBook }) {
  const { books, fetchChapter, currentChapter, getBookName } = useBible()
  const [expandedBook, setExpandedBook] = useState(null)
  const [filter, setFilter] = useState('all') // all, ot, nt

  const oldTestament = books.filter(b => b.testament === 'OT')
  const newTestament = books.filter(b => b.testament === 'NT')

  const handleBookClick = (bookId) => {
    if (expandedBook === bookId) {
      setExpandedBook(null)
    } else {
      setExpandedBook(bookId)
      onSelectBook(bookId)
    }
  }

  const handleChapterClick = (bookId, chapterNum) => {
    fetchChapter(bookId, chapterNum)
  }

  const displayedBooks = filter === 'ot' ? oldTestament : 
                         filter === 'nt' ? newTestament : books

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <h1>📖 Holy Bible</h1>
        <p>World English Bible</p>
      </div>

      <div style={{ marginBottom: '20px', display: 'flex', gap: '5px' }}>
        <button 
          onClick={() => setFilter('all')}
          style={{
            flex: 1,
            padding: '8px',
            border: 'none',
            borderRadius: '6px',
            background: filter === 'all' ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.1)',
            color: 'white',
            cursor: 'pointer'
          }}
        >
          All
        </button>
        <button 
          onClick={() => setFilter('ot')}
          style={{
            flex: 1,
            padding: '8px',
            border: 'none',
            borderRadius: '6px',
            background: filter === 'ot' ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.1)',
            color: 'white',
            cursor: 'pointer'
          }}
        >
          OT
        </button>
        <button 
          onClick={() => setFilter('nt')}
          style={{
            flex: 1,
            padding: '8px',
            border: 'none',
            borderRadius: '6px',
            background: filter === 'nt' ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.1)',
            color: 'white',
            cursor: 'pointer'
          }}
        >
          NT
        </button>
      </div>

      <div className="book-list">
        {filter !== 'nt' && (
          <div className="testament-section">
            <div className="testament-title">Old Testament</div>
            {oldTestament.map(book => (
              <div key={book.id}>
                <div 
                  className={`book-item ${selectedBook === book.id ? 'active' : ''}`}
                  onClick={() => handleBookClick(book.id)}
                >
                  <span>{book.name}</span>
                  <span>{expandedBook === book.id ? '▼' : '▶'}</span>
                </div>
                {expandedBook === book.id && (
                  <div className="chapter-grid">
                    {Array.from({ length: book.chapters || 1 }, (_, i) => i + 1).map(chapter => (
                      <button
                        key={chapter}
                        className={`chapter-btn ${currentChapter === chapter && selectedBook === book.id ? 'active' : ''}`}
                        onClick={() => handleChapterClick(book.id, chapter)}
                      >
                        {chapter}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {filter !== 'ot' && (
          <div className="testament-section">
            <div className="testament-title">New Testament</div>
            {newTestament.map(book => (
              <div key={book.id}>
                <div 
                  className={`book-item ${selectedBook === book.id ? 'active' : ''}`}
                  onClick={() => handleBookClick(book.id)}
                >
                  <span>{book.name}</span>
                  <span>{expandedBook === book.id ? '▼' : '▶'}</span>
                </div>
                {expandedBook === book.id && (
                  <div className="chapter-grid">
                    {Array.from({ length: book.chapters || 1 }, (_, i) => i + 1).map(chapter => (
                      <button
                        key={chapter}
                        className={`chapter-btn ${currentChapter === chapter && selectedBook === book.id ? 'active' : ''}`}
                        onClick={() => handleChapterClick(book.id, chapter)}
                      >
                        {chapter}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
