from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # Supabase Configuration
    supabase_url: str = "https://your-project.supabase.co"
    supabase_key: str = "your-anon-key"
    
    # Bible Brain API Configuration
    bible_brain_api_key: str = ""
    
    # Application Settings
    debug: bool = True
    cors_origins: List[str] = ["http://localhost:3000", "http://localhost:8080"]
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
