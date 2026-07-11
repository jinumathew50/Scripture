from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from routes import bible, marks, progress, plans

# Create FastAPI application
app = FastAPI(
    title="Scripture Bible API",
    description="Backend API for the Scripture Bible App with Supabase integration",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "version": "1.0.0",
        "service": "Scripture Bible API"
    }


# Include routers
app.include_router(bible.router)
app.include_router(marks.router)
app.include_router(progress.router)
app.include_router(plans.router)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
