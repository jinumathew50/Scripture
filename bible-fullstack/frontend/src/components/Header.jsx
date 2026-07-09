import { useTheme } from './ThemeProvider'

export default function Header({ onSearch, fontSize, setFontSize }) {
  const { theme, toggleTheme } = useTheme()

  const handleSearch = (e) => {
    e.preventDefault()
    const query = e.target.search.value
    if (query.trim()) {
      onSearch(query)
      e.target.reset()
    }
  }

  return (
    <header className="header">
      <div>
        <h2>Holy Bible</h2>
        <p style={{ color: 'var(--text-secondary)' }}>Read, Listen, and Search</p>
      </div>
      
      <div className="header-controls">
        <form onSubmit={handleSearch} className="search-box" style={{ marginBottom: 0 }}>
          <input
            type="text"
            name="search"
            placeholder="Search verses..."
            className="search-input"
            style={{ padding: '8px 15px', width: '200px' }}
          />
          <button type="submit" className="search-btn" style={{ padding: '8px 15px' }}>
            🔍
          </button>
        </form>

        <button 
          className="font-btn" 
          onClick={() => setFontSize(prev => prev === 'normal' ? 'large' : prev === 'large' ? 'xlarge' : 'normal')}
        >
          {fontSize === 'normal' ? 'A+' : fontSize === 'large' ? 'A++' : 'A'}
        </button>

        <button className="theme-toggle" onClick={toggleTheme}>
          {theme === 'light' ? '🌙' : '☀️'}
        </button>
      </div>
    </header>
  )
}
