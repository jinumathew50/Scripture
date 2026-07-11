# Supabase Backend for Scripture Bible App

A FastAPI backend with Supabase integration for the Scripture Bible application.

## Features

- **Supabase Integration**: PostgreSQL database via Supabase
- **Bible Brain Proxy**: Cached Bible content from dbt.io
- **User Data**: Highlights, bookmarks, notes, reading progress
- **Reading Plans**: Curated and custom reading plans
- **Multi-translation Support**: 25 translations across 12 languages

## Setup

### Prerequisites

- Python 3.9+
- Supabase account and project
- Bible Brain API key (from dbt.io)

### Installation

1. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables in `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key-or-service-role-key
BIBLE_BRAIN_API_KEY=your-bible-brain-api-key
DATABASE_URL=postgresql://postgres:[password]@db.your-project.supabase.co:5432/postgres
```

4. Run database migrations:
```bash
python -m scripts.create_tables
```

5. Start the server:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Project Structure

```
supabase-backend/
├── main.py                 # FastAPI application entry point
├── config.py               # Configuration and settings
├── database.py             # Supabase client setup
├── models/                 # Pydantic models
│   ├── __init__.py
│   ├── marks.py           # Highlights, bookmarks, notes
│   ├── progress.py        # Reading progress
│   └── plans.py           # Reading plans
├── routes/                 # API routes
│   ├── __init__.py
│   ├── bible.py           # Bible content endpoints
│   ├── marks.py           # User marks endpoints
│   ├── progress.py        # Progress endpoints
│   └── plans.py           # Reading plans endpoints
├── services/               # Business logic
│   ├── __init__.py
│   ├── bible_brain.py     # Bible Brain API proxy
│   ├── cache.py           # Caching logic
│   └── streaks.py         # Streak calculation
├── scripts/                # Database scripts
│   ├── __init__.py
│   └── create_tables.py   # Table creation script
├── tests/                  # Pytest tests
│   ├── __init__.py
│   └── test_api.py
├── .env                    # Environment variables (not committed)
├── .env.example            # Example environment file
├── requirements.txt        # Python dependencies
└── README.md               # This file
```

## API Endpoints

### Bible Content

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/bible/verse-of-the-day` | Daily verse |
| GET | `/api/bible/bibles` | List available Bibles |
| GET | `/api/bible/books/{bible_id}` | Get books list |
| GET | `/api/bible/text/{fileset_id}/{book_id}/{chapter}` | Chapter text |
| GET | `/api/bible/audio/{fileset_id}/{book_id}/{chapter}` | Audio stream |
| GET | `/api/bible/timestamps/{fileset_id}/{book_id}/{chapter}` | Verse timestamps |
| GET | `/api/bible/search` | Full-text search |

### User Data

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/marks` | Create highlight/bookmark/note |
| GET | `/api/marks` | Get user marks |
| PATCH | `/api/marks/{mark_id}` | Update mark |
| DELETE | `/api/marks/{mark_id}` | Delete mark |
| POST | `/api/progress` | Save reading progress |
| GET | `/api/progress` | Get user progress |

### Reading Plans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/plans/curated` | List curated plans |
| GET | `/api/plans/books` | Get book options |
| POST | `/api/plans/enroll` | Enroll in plan |
| GET | `/api/plans` | List enrolled plans |
| GET | `/api/plans/{enrollment_id}` | Get plan detail |
| POST | `/api/plans/{enrollment_id}/complete` | Complete day |
| DELETE | `/api/plans/{enrollment_id}` | Delete enrollment |

## Database Schema

### Tables

- `bibles_cache`: Cached Bible metadata
- `books_cache`: Cached book lists
- `text_cache`: Cached chapter text
- `timestamps_cache`: Cached audio timestamps
- `marks`: User highlights, bookmarks, notes
- `reading_progress`: User reading progress
- `enrollments`: Reading plan enrollments
- `completed_days`: Completed plan days

## Testing

Run all tests:
```bash
pytest tests/ -v
```

Run specific test file:
```bash
pytest tests/test_api.py -v
```

## Development

### Running in development mode:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Code style:
```bash
black .
flake8
```

## Deployment

### Docker
```bash
docker build -t scripture-backend .
docker run -p 8000:8000 --env-file .env scripture-backend
```

### Production considerations:
- Use service role key for backend operations
- Enable connection pooling
- Set up proper CORS origins
- Configure rate limiting
- Set up monitoring and logging

## License

MIT License
