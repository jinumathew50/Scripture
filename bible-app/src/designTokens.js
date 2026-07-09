// Scripture App Design Tokens - Editorial Mobile LIGHT Personality
// A quiet, distraction-free reading experience that feels like a classic, beautifully bound physical book

export const lightTheme = {
  colors: {
    surface: "#FDFBF7",
    onSurface: "#1C1917",
    surfaceSecondary: "#F4F1EA",
    onSurfaceSecondary: "#44403C",
    surfaceTertiary: "#EBE6DF",
    onSurfaceTertiary: "#57534E",
    surfaceInverse: "#1C1917",
    onSurfaceInverse: "#FDFBF7",
    brand: "#B85B42",
    brandPrimary: "#B85B42",
    onBrandPrimary: "#FFFFFF",
    brandSecondary: "#E3A894",
    onBrandSecondary: "#291510",
    brandTertiary: "#F2D8D1",
    onBrandTertiary: "#5C2D21",
    success: "#4A7A59",
    onSuccess: "#FFFFFF",
    warning: "#D9943B",
    onWarning: "#1C1917",
    error: "#A63D40", // Red-letter text color
    onError: "#FFFFFF",
    info: "#567C8A",
    onInfo: "#FFFFFF",
    border: "#EBE6DF",
    borderStrong: "#D6CEC5",
    divider: "#EBE6DF"
  },
  typography: {
    displayFontFamily: '"Libre Baskerville", Georgia, serif',
    textFontFamily: '"Satoshi", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    scale: {
      sm: 12,
      base: 14,
      lg: 16,
      xl: 20,
      "2xl": 24,
      "3xl": 32,
      "4xl": 40
    }
  },
  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    "2xl": 32,
    "3xl": 48
  },
  radius: {
    sm: 6,
    md: 12,
    lg: 20,
    pill: 999
  },
  shadows: {
    none: 'none',
    subtle: '0 1px 2px rgba(28, 25, 23, 0.05)',
    soft: '0 2px 4px rgba(28, 25, 23, 0.06)'
  }
};

export const darkTheme = {
  colors: {
    surface: "#121212",
    onSurface: "#EAEAEA",
    surfaceSecondary: "#1E1E1E",
    onSurfaceSecondary: "#C4C4C4",
    surfaceTertiary: "#2C2C2C",
    onSurfaceTertiary: "#A0A0A0",
    surfaceInverse: "#FDFBF7",
    onSurfaceInverse: "#1C1917",
    brand: "#C16B54",
    brandPrimary: "#C16B54",
    onBrandPrimary: "#FFFFFF",
    brandSecondary: "#8A3D29",
    onBrandSecondary: "#F2D8D1",
    brandTertiary: "#4A2216",
    onBrandTertiary: "#E3A894",
    success: "#5C9970",
    onSuccess: "#FFFFFF",
    warning: "#E5A95A",
    onWarning: "#1C1917",
    error: "#C25356", // Red-letter text color
    onError: "#FFFFFF",
    info: "#6B9AAB",
    onInfo: "#FFFFFF",
    border: "#2C2C2C",
    borderStrong: "#44403C",
    divider: "#2C2C2C"
  },
  typography: lightTheme.typography,
  spacing: lightTheme.spacing,
  radius: lightTheme.radius,
  shadows: {
    none: 'none',
    subtle: '0 1px 2px rgba(0, 0, 0, 0.3)',
    soft: '0 2px 4px rgba(0, 0, 0, 0.4)'
  }
};

export const sepiaTheme = {
  colors: {
    surface: "#F5EBE0",
    onSurface: "#3D342B",
    surfaceSecondary: "#EDE0D4",
    onSurfaceSecondary: "#5C5046",
    surfaceTertiary: "#E6D5C3",
    onSurfaceTertiary: "#6B5E54",
    surfaceInverse: "#3D342B",
    onSurfaceInverse: "#F5EBE0",
    brand: "#B85B42",
    brandPrimary: "#B85B42",
    onBrandPrimary: "#FFFFFF",
    brandSecondary: "#D4A574",
    onBrandSecondary: "#3D342B",
    brandTertiary: "#E8D5C4",
    onBrandTertiary: "#5C4A3D",
    success: "#5C8D6E",
    onSuccess: "#FFFFFF",
    warning: "#D4A574",
    onWarning: "#3D342B",
    error: "#A63D40", // Red-letter text color
    onError: "#FFFFFF",
    info: "#6B8D9A",
    onInfo: "#FFFFFF",
    border: "#E6D5C3",
    borderStrong: "#D4C4B5",
    divider: "#E6D5C3"
  },
  typography: lightTheme.typography,
  spacing: lightTheme.spacing,
  radius: lightTheme.radius,
  shadows: lightTheme.shadows
};

export const images = {
  verseOfTheDayBgLight: {
    url: "https://images.unsplash.com/photo-1439792675105-701e6a4ab6f0?crop=entropy&cs=srgb&fm=jpg&ixid=M3w4NjAzNTl8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwcGVhY2VmdWwlMjBsYW5kc2NhcGUlMjBzdW5yaXNlfGVufDB8fHx8MTc4MzIyNjE3OHww&ixlib=rb-4.1.0&q=85",
    alt: "Minimalist peaceful landscape sunrise"
  },
  verseOfTheDayBgDark: {
    url: "https://images.unsplash.com/photo-1477840539360-4a1d23071046?crop=entropy&cs=srgb&fm=jpg&ixid=M3w4NjA1NDh8MHwxfHNlYXJjaHwxfHxuaWdodCUyMHNreSUyMHN0YXJzJTIwbWluaW1hbHxlbnwwfHx8fDE3ODMyMjYxODR8MA&ixlib=rb-4.1.0&q=85",
    alt: "Snowy mountain peak under starry night sky"
  },
  readingPlanBg: {
    url: "https://images.unsplash.com/photo-1629968417850-3505f5180761?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NDk1NzZ8MHwxfHNlYXJjaHwxfHxhbnRpcXVlJTIwcGFwZXIlMjB0ZXh0dXJlJTIwYmxhbmt8ZW58MHx8fHwxNzgzMjI2MTc5fDA&ixlib=rb-4.1.0&q=85",
    alt: "Antique paper texture"
  },
  emptyStateArchive: {
    url: "https://images.unsplash.com/photo-1517770413964-df8ca61194a6?crop=entropy&cs=srgb&fm=jpg&ixid=M3w3NTY2NzF8MHwxfHNlYXJjaHwxfHxvcGVuJTIwYm9vayUyMHBhZ2VzJTIwbWFjcm8lMjBwaG90b2dyYXBoeXxlbnwwfHx8fDE3ODMyMjYxNzh8MA&ixlib=rb-4.1.0&q=85",
    alt: "Macro photography of open book pages"
  },
  emptyStateDark: {
    url: "https://images.unsplash.com/photo-1576506542790-51244b486a6b?crop=entropy&cs=srgb&fm=jpg&ixid=M3w4NjY2NzN8MHwxfHNlYXJjaHwxfHxiaWJsZSUyMHJlYWRpbmclMjBkYXJrJTIwYWVzdGhldGljfGVufDB8fHx8MTc4MzIyNjE4NHww&ixlib=rb-4.1.0&q=85",
    alt: "Person sitting by table opening book in dark aesthetic"
  }
};

export const haptics = {
  tabPress: 'light',
  verseSelect: 'medium',
  audioPlayPause: 'medium',
  chapterSwipe: 'light',
  bookmarkAdd: 'success'
};
