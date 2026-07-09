# 📖 Holy Bible Application

A modern, responsive Bible reading application built with React and Vite. This application provides easy access to all books of the Old and New Testament with a clean, user-friendly interface.

## ✨ Features

- **Complete Bible**: Access all 66 books of the Bible (39 Old Testament, 27 New Testament)
- **King James Version (KJV)**: Read the classic KJV translation
- **Dark/Light Theme**: Toggle between light and dark modes for comfortable reading
- **Adjustable Font Size**: Customize text size for better readability
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Search Functionality**: Quickly find books by name
- **Chapter Navigation**: Easy navigation through chapters
- **Modern UI**: Clean, intuitive interface inspired by modern design principles

## 🚀 Technologies Used

### Frontend
- **React 19** - Modern UI library
- **Vite** - Fast build tool and development server
- **CSS3** - Custom styling with CSS variables for theming

### Backend/API
- **bible-api.com** - Free REST API for Bible content (King James Version)

## 📦 Installation

### Prerequisites
- Node.js (v18 or higher)
- npm or yarn

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd bible-app
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to `http://localhost:3000`

## 🛠️ Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally

## 📁 Project Structure

```
bible-app/
├── public/
│   └── bible-icon.svg      # App icon
├── src/
│   ├── App.jsx             # Main application component
│   ├── App.css             # Application styles
│   ├── index.css           # Global styles & theme variables
│   └── main.jsx            # Entry point
├── index.html              # HTML template
├── package.json            # Dependencies & scripts
├── vite.config.js          # Vite configuration
└── README.md               # Documentation
```

## 🎨 Customization

### Theme Colors
You can customize the theme colors in `src/index.css`:

```css
/* Light theme */
.light-theme {
  --bg-primary: #ffffff;
  --accent-color: #6366f1;
  /* ... */
}

/* Dark theme */
.dark-theme {
  --bg-primary: #1a1a2e;
  --accent-color: #6366f1;
  /* ... */
}
```

### API Configuration
The app uses the free [bible-api.com](https://bible-api.com/) service. To use a different API, modify the `BIBLE_API_BASE` constant in `src/App.jsx`.

## 🌐 Deployment

### Build for Production
```bash
npm run build
```

The optimized production files will be in the `dist/` folder.

### Deploy to Netlify/Vercel
1. Connect your GitHub repository
2. Set build command: `npm run build`
3. Set publish directory: `dist`

## 📱 Responsive Breakpoints

- Mobile: < 480px
- Tablet: 481px - 768px
- Desktop: 769px - 1024px
- Large Desktop: > 1025px

## 🔧 Troubleshooting

### Common Issues

1. **API not loading**: Check your internet connection. The app requires an active connection to fetch Bible content.

2. **Styles not applying**: Clear your browser cache and reload.

3. **Build errors**: Ensure all dependencies are installed (`npm install`).

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Bible text provided by [bible-api.com](https://bible-api.com/)
- King James Version (Public Domain)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues and feature requests, please create an issue in the repository.

---

Made with ❤️ for spreading God's Word
