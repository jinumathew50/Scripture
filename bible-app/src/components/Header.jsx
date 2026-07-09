import { useTheme } from '../hooks/useTheme';

export default function Header({ onMenuClick, onSearchClick }) {
  const { theme, palette, toggleTheme, increaseFont, decreaseFont, fontSize } = useTheme();

  return (
    <header style={styles.header}>
      <div style={styles.leftSection}>
        <button onClick={onMenuClick} style={styles.iconButton} aria-label="Menu">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={palette.text} strokeWidth="2">
            <line x1="3" y1="6" x2="21" y2="6"></line>
            <line x1="3" y1="12" x2="21" y2="12"></line>
            <line x1="3" y1="18" x2="21" y2="18"></line>
          </svg>
        </button>
        <h1 style={styles.title}>Scripture</h1>
      </div>
      
      <div style={styles.rightSection}>
        <button onClick={decreaseFont} style={styles.fontButton} aria-label="Decrease font size">A-</button>
        <span style={styles.fontSizeDisplay}>{fontSize}</span>
        <button onClick={increaseFont} style={styles.fontButton} aria-label="Increase font size">A+</button>
        
        <button onClick={toggleTheme} style={styles.iconButton} aria-label="Toggle theme">
          {theme === 'light' ? (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={palette.text} strokeWidth="2">
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
            </svg>
          ) : (
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={palette.text} strokeWidth="2">
              <circle cx="12" cy="12" r="5"></circle>
              <line x1="12" y1="1" x2="12" y2="3"></line>
              <line x1="12" y1="21" x2="12" y2="23"></line>
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
              <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
              <line x1="1" y1="12" x2="3" y2="12"></line>
              <line x1="21" y1="12" x2="23" y2="12"></line>
              <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
              <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
            </svg>
          )}
        </button>
        
        <button onClick={onSearchClick} style={styles.iconButton} aria-label="Search">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={palette.text} strokeWidth="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
        </button>
      </div>
    </header>
  );
}

const styles = {
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '16px 24px',
    borderBottom: '1px solid var(--border)',
    position: 'sticky',
    top: 0,
    backgroundColor: 'var(--background)',
    zIndex: 100,
  },
  leftSection: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
  },
  rightSection: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },
  title: {
    fontFamily: "'Playfair Display', serif",
    fontSize: '24px',
    fontWeight: '600',
    color: 'var(--text)',
    margin: 0,
  },
  iconButton: {
    background: 'transparent',
    border: 'none',
    cursor: 'pointer',
    padding: '8px',
    borderRadius: '8px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transition: 'background-color 0.2s',
  },
  fontButton: {
    background: 'var(--surface)',
    border: '1px solid var(--border)',
    cursor: 'pointer',
    padding: '6px 10px',
    borderRadius: '6px',
    fontSize: '14px',
    fontWeight: '500',
    color: 'var(--text)',
    minWidth: '36px',
  },
  fontSizeDisplay: {
    fontSize: '14px',
    color: 'var(--textSecondary)',
    minWidth: '24px',
    textAlign: 'center',
  },
};
