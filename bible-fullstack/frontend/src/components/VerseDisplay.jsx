import { useBible } from '../hooks/useBible'

export default function VerseDisplay({ selectedBook, onSearch }) {
  const { verses, currentBook, currentChapter, audioUrl, loading, error, getBookName, verseOfTheDay } = useBible()

  if (loading && verses.length === 0) {
    return <div className="loading">Loading...</div>
  }

  if (error) {
    return <div className="error">Error: {error}</div>
  }

  // Show welcome screen when no chapter is selected
  if (!currentBook || !currentChapter) {
    return (
      <div className="welcome-screen">
        <img src="/bible-icon.svg" alt="Bible" className="welcome-icon" />
        <h1 className="welcome-title">Welcome to Holy Bible</h1>
        <p className="welcome-subtitle">Read God's Word in multiple translations with audio</p>
        
        {verseOfTheDay && (
          <div className="votd-card">
            <div className="votd-title">✨ Verse of the Day</div>
            <div className="votd-text">"{verseOfTheDay.text}"</div>
            <div className="votd-ref">— {verseOfTheDay.reference}</div>
          </div>
        )}

        <div className="feature-cards">
          <div className="feature-card">
            <div className="feature-icon">📖</div>
            <div className="feature-title">Complete Bible</div>
            <div className="feature-desc">All 66 books of the Old and New Testament</div>
          </div>
          <div className="feature-card">
            <div className="feature-icon">🎧</div>
            <div className="feature-title">Audio Available</div>
            <div className="feature-desc">Listen to chapters with audio narration</div>
          </div>
          <div className="feature-card">
            <div className="feature-icon">🔍</div>
            <div className="feature-title">Powerful Search</div>
            <div className="feature-desc">Find any verse quickly with search</div>
          </div>
          <div className="feature-card">
            <div className="feature-icon">🌓</div>
            <div className="feature-title">Dark Mode</div>
            <div className="feature-desc">Comfortable reading day or night</div>
          </div>
        </div>
      </div>
    )
  }

  const bookName = getBookName(currentBook)

  return (
    <div className="verse-container">
      <div className="verse-header">
        <div className="verse-reference">
          {bookName} {currentChapter}
        </div>
        {audioUrl && (
          <div className="audio-player">
            <audio controls style={{ width: '100%' }}>
              <source src={audioUrl} type="audio/mpeg" />
              Your browser does not support the audio element.
            </audio>
          </div>
        )}
      </div>

      <div className="verse-text">
        {verses.map((verse) => (
          <div key={verse.verse_start || verse.verse_number} className="verse-item">
            <span className="verse-number">{verse.verse_start || verse.verse_number}</span>
            <span>{verse.text}</span>
          </div>
        ))}
      </div>
    </div>
  )
}
