import { useState, useEffect } from 'react'

const API_BASE = '/api'

export function useBible() {
  const [books, setBooks] = useState([])
  const [currentBook, setCurrentBook] = useState(null)
  const [currentChapter, setCurrentChapter] = useState(null)
  const [verses, setVerses] = useState([])
  const [audioUrl, setAudioUrl] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [verseOfTheDay, setVerseOfTheDay] = useState(null)

  // Fetch all books
  useEffect(() => {
    fetchBooks()
    fetchVerseOfTheDay()
  }, [])

  const fetchBooks = async () => {
    try {
      setLoading(true)
      const response = await fetch(`${API_BASE}/books?version_id=WBT`)
      if (!response.ok) throw new Error('Failed to fetch books')
      const data = await response.json()
      setBooks(data.data || [])
      setLoading(false)
    } catch (err) {
      setError(err.message)
      setLoading(false)
    }
  }

  const fetchChapter = async (bookId, chapterNum) => {
    try {
      setLoading(true)
      setError(null)
      const response = await fetch(`${API_BASE}/chapters/${bookId}/${chapterNum}?version_id=WBT`)
      if (!response.ok) throw new Error('Failed to fetch chapter')
      const data = await response.json()
      
      if (data.data) {
        setVerses(data.data.verses || [])
        setCurrentBook(bookId)
        setCurrentChapter(chapterNum)
        
        // Try to fetch audio
        fetchAudio(bookId, chapterNum)
      }
      setLoading(false)
    } catch (err) {
      setError(err.message)
      setLoading(false)
    }
  }

  const fetchAudio = async (bookId, chapterNum) => {
    try {
      const response = await fetch(`${API_BASE}/audio/${bookId}/${chapterNum}?version_id=WBT`)
      if (response.ok) {
        const data = await response.json()
        if (data.data && data.data.audio) {
          setAudioUrl(data.data.audio.url)
        }
      }
    } catch (err) {
      console.log('Audio not available:', err)
      setAudioUrl(null)
    }
  }

  const searchVerses = async (query) => {
    try {
      setLoading(true)
      const response = await fetch(`${API_BASE}/search?q=${encodeURIComponent(query)}&version_id=WBT`)
      if (!response.ok) throw new Error('Search failed')
      const data = await response.json()
      setLoading(false)
      return data.data || []
    } catch (err) {
      setError(err.message)
      setLoading(false)
      return []
    }
  }

  const fetchVerseOfTheDay = async () => {
    try {
      const response = await fetch(`${API_BASE}/verse-of-the-day?version_id=WBT`)
      if (response.ok) {
        const data = await response.json()
        setVerseOfTheDay(data)
      }
    } catch (err) {
      console.log('Could not fetch verse of the day')
    }
  }

  const getBookName = (bookId) => {
    const book = books.find(b => b.id === bookId)
    return book ? book.name : bookId
  }

  return {
    books,
    currentBook,
    currentChapter,
    verses,
    audioUrl,
    loading,
    error,
    verseOfTheDay,
    fetchChapter,
    searchVerses,
    getBookName,
    setCurrentBook,
    setCurrentChapter
  }
}
