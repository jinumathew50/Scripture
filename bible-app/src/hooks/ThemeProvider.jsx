import { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(() => {
    return localStorage.getItem('bible-theme') || 'light';
  });
  
  const [fontSize, setFontSize] = useState(() => {
    return parseInt(localStorage.getItem('bible-fontsize') || '16', 10);
  });

  useEffect(() => {
    localStorage.setItem('bible-theme', theme);
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  useEffect(() => {
    localStorage.setItem('bible-fontsize', fontSize.toString());
  }, [fontSize]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  const increaseFont = () => setFontSize(prev => Math.min(prev + 2, 24));
  const decreaseFont = () => setFontSize(prev => Math.max(prev - 2, 12));

  const palette = theme === 'light' ? {
    background: '#FDFBF7',
    surface: '#F4F1EA',
    surfaceSecondary: '#EBE6DF',
    text: '#1C1917',
    textSecondary: '#57534E',
    textTertiary: '#8B837B',
    brand: '#B85B42',
    brandLight: '#F2D8D1',
    border: '#EBE6DF',
    white: '#FFFFFF',
  } : {
    background: '#121212',
    surface: '#1E1E1E',
    surfaceSecondary: '#2C2C2C',
    text: '#EAEAEA',
    textSecondary: '#C4C4C4',
    textTertiary: '#A0A0A0',
    brand: '#C16B54',
    brandLight: '#4A2216',
    border: '#2C2C2C',
    white: '#1C1917',
  };

  return (
    <ThemeContext.Provider value={{ theme, palette, fontSize, toggleTheme, increaseFont, decreaseFont }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
