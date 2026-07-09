import { useState } from 'react'
import { ThemeProvider } from './components/ThemeProvider'
import Sidebar from './components/Sidebar'
import Header from './components/Header'
import VerseDisplay from './components/VerseDisplay'
import { useBible } from './hooks/useBible'

function AppContent() {
  const [selectedBook, setSelectedBook] = useState(null)
  const [fontSize, setFontSize] = useState('normal')
  const { searchVerses } = useBible()

  const handleSearch = async (query) => {
    const results = await searchVerses(query)
    console.log('Search results:', results)
    // You can add a search results display component here
    alert(`Found ${results.length} results for "${query}"`)
  }

  return (
    <div className="app">
      <Sidebar 
        selectedBook={selectedBook} 
        onSelectBook={setSelectedBook} 
      />
      <main className="main-content" style={{ fontSize: fontSize === 'xlarge' ? '1.3rem' : fontSize === 'large' ? '1.15rem' : '1rem' }}>
        <Header 
          onSearch={handleSearch}
          fontSize={fontSize}
          setFontSize={setFontSize}
        />
        <VerseDisplay 
          selectedBook={selectedBook}
          onSearch={handleSearch}
        />
      </main>
    </div>
  )
}

function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  )
}

export default App
