"""
Test suite for Scripture Bible API

Run with: pytest tests/ -v
"""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch, MagicMock
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)


class TestHealthCheck:
    """Test health check endpoint"""
    
    def test_health_check(self):
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "version" in data


class TestBibleEndpoints:
    """Test Bible content endpoints"""
    
    @patch('routes.bible.settings')
    def test_verse_of_the_day(self, mock_settings):
        mock_settings.bible_brain_api_key = "test-key"
        response = client.get("/api/bible/verse-of-the-day")
        assert response.status_code == 200
        data = response.json()
        assert "reference" in data
        assert "text" in data
    
    @patch('routes.bible.settings')
    def test_list_bibles(self, mock_settings):
        mock_settings.bible_brain_api_key = "test-key"
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"data": []}
            mock_get.return_value = mock_response
            
            response = client.get("/api/bible/bibles?language_code=en")
            assert response.status_code == 200
    
    @patch('routes.bible.settings')
    def test_search_bible(self, mock_settings):
        mock_settings.bible_brain_api_key = "test-key"
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"results": []}
            mock_get.return_value = mock_response
            
            response = client.get("/api/bible/search?query=love")
            assert response.status_code == 200


class TestMarksEndpoints:
    """Test marks (highlights/bookmarks/notes) endpoints"""
    
    @patch('routes.marks.get_supabase')
    def test_create_highlight(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.insert.return_value.execute.return_value = Mock(
            data=[{
                "id": "test-id",
                "device_id": "device-123",
                "bible_id": "KJV",
                "book_id": "JHN",
                "chapter": 3,
                "verse_start": 16,
                "verse_end": None,
                "mark_type": "highlight",
                "color": "yellow",
                "note_text": None,
                "created_at": "2025-01-01T00:00:00Z",
                "updated_at": "2025-01-01T00:00:00Z",
            }]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.post("/api/marks", json={
            "device_id": "device-123",
            "bible_id": "KJV",
            "book_id": "JHN",
            "chapter": 3,
            "verse_start": 16,
            "mark_type": "highlight",
            "color": "yellow"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == "test-id"
        assert data["mark_type"] == "highlight"
    
    @patch('routes.marks.get_supabase')
    def test_get_marks(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.execute.return_value = Mock(
            data=[{
                "id": "test-id",
                "device_id": "device-123",
                "bible_id": "KJV",
                "book_id": "JHN",
                "chapter": 3,
                "verse_start": 16,
                "mark_type": "highlight",
                "color": "yellow",
                "created_at": "2025-01-01T00:00:00Z",
                "updated_at": "2025-01-01T00:00:00Z",
            }]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.get("/api/marks?device_id=device-123")
        assert response.status_code == 200
        assert isinstance(response.json(), list)


class TestProgressEndpoints:
    """Test reading progress endpoints"""
    
    @patch('routes.progress.get_supabase')
    def test_save_progress(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = Mock(data=[])
        mock_supabase.table.return_value.insert.return_value.execute.return_value = Mock(
            data=[{
                "id": "test-id",
                "device_id": "device-123",
                "bible_id": "KJV",
                "book_id": "JHN",
                "chapter": 3,
                "verse": 16,
                "created_at": "2025-01-01T00:00:00Z",
                "updated_at": "2025-01-01T00:00:00Z",
            }]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.post("/api/progress", json={
            "device_id": "device-123",
            "bible_id": "KJV",
            "book_id": "JHN",
            "chapter": 3,
            "verse": 16
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["chapter"] == 3
    
    @patch('routes.progress.get_supabase')
    def test_get_progress_with_streak(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.limit.return_value.execute.return_value = Mock(
            data=[{
                "id": "test-id",
                "device_id": "device-123",
                "bible_id": "KJV",
                "book_id": "JHN",
                "chapter": 3,
                "updated_at": "2025-01-01T00:00:00Z",
            }]
        )
        mock_supabase.table.return_value.select.return_value.eq.return_value.gte.return_value.execute.return_value = Mock(
            data=[{"updated_at": "2025-01-01T00:00:00Z"}]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.get("/api/progress?device_id=device-123")
        assert response.status_code == 200
        data = response.json()
        assert "last_read" in data
        assert "streak" in data
        assert "current_streak" in data["streak"]


class TestPlansEndpoints:
    """Test reading plans endpoints"""
    
    def test_list_curated_plans(self):
        response = client.get("/api/plans/curated")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 6  # We defined 6 curated plans
    
    def test_get_book_options(self):
        response = client.get("/api/plans/books")
        assert response.status_code == 200
        data = response.json()
        assert "old_testament" in data
        assert "new_testament" in data
        assert len(data["old_testament"]) == 39
        assert len(data["new_testament"]) == 27
    
    @patch('routes.plans.get_supabase')
    def test_enroll_in_plan(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = Mock(data=[])
        mock_supabase.table.return_value.insert.return_value.execute.return_value = Mock(
            data=[{
                "id": "enrollment-123",
                "device_id": "device-123",
                "plan_id": "JHN",
                "plan_name": "Custom: JHN",
                "start_date": "2025-01-01",
                "duration_days": 21,
                "completed_days": [],
                "created_at": "2025-01-01T00:00:00Z",
            }]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.post("/api/plans/enroll", json={
            "device_id": "device-123",
            "name": "John in 21 days",
            "book_id": "JHN",
            "duration_days": 21
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["plan_id"] == "JHN"
    
    @patch('routes.plans.get_supabase')
    def test_list_enrollments(self, mock_get_supabase):
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.order.return_value.execute.return_value = Mock(
            data=[]
        )
        mock_get_supabase.return_value = mock_supabase
        
        response = client.get("/api/plans?device_id=device-123")
        assert response.status_code == 200
        assert isinstance(response.json(), list)


class TestIdempotency:
    """Test idempotent enrollment"""
    
    @patch('routes.plans.get_supabase')
    def test_duplicate_enrollment_returns_existing(self, mock_get_supabase):
        existing_enrollment = {
            "id": "existing-123",
            "device_id": "device-123",
            "plan_id": "nt-90-days",
            "plan_name": "New Testament in 90 Days",
            "start_date": "2025-01-01",
            "duration_days": 90,
            "completed_days": [],
            "created_at": "2025-01-01T00:00:00Z",
        }
        
        mock_supabase = Mock()
        mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = Mock(
            data=[existing_enrollment]
        )
        mock_get_supabase.return_value = mock_supabase
        
        # First enrollment
        response = client.post("/api/plans/enroll", json={
            "device_id": "device-123",
            "name": "NT in 90 days",
            "book_id": "nt-90-days",
            "duration_days": 90
        })
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == "existing-123"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
