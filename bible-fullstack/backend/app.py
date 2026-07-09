from flask import Flask, jsonify, request
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

# Using free bible-api.com (no API key required)
BASE_URL = "https://bible-api.com"

@app.route('/api/versions', methods=['GET'])
def get_versions():
    """Return available versions"""
    return jsonify({
        "data": [
            {"id": "KJV", "name": "King James Version"},
            {"id": "WEB", "name": "World English Bible"}
        ]
    })

@app.route('/api/books', methods=['GET'])
def get_books():
    """Get all books of the Bible"""
    try:
        response = requests.get(f"{BASE_URL}/books")
        if response.status_code == 200:
            data = response.json()
            # Transform to match expected format
            books = []
            for book in data.get('books', []):
                testament = 'OT' if book['testament'] == 'old' else 'NT'
                books.append({
                    'id': book['book'],
                    'name': book['name'],
                    'chapters': book['chapters'],
                    'testament': testament
                })
            return jsonify({"data": books})
        return jsonify({"error": "Failed to fetch books"}), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/chapters/<book_id>/<chapter_num>', methods=['GET'])
def get_chapter(book_id, chapter_num):
    """Get a specific chapter with verses"""
    try:
        response = requests.get(f"{BASE_URL}/bible?book={book_id}&chapter={chapter_num}&translation=kjv")
        if response.status_code == 200:
            data = response.json()
            verses = []
            for verse_data in data.get('verses', []):
                verses.append({
                    'verse_start': verse_data.get('verse', 0),
                    'text': verse_data.get('text', '')
                })
            return jsonify({
                "data": {
                    "verses": verses,
                    "book": data.get('reference', {}).get('book', book_id),
                    "chapter": int(chapter_num)
                }
            })
        return jsonify({"error": "Failed to fetch chapter"}), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/audio/<book_id>/<chapter_num>', methods=['GET'])
def get_audio(book_id, chapter_num):
    """Audio not available in free API"""
    return jsonify({"data": None})

@app.route('/api/search', methods=['GET'])
def search_verses():
    """Search not available in free API"""
    return jsonify({"data": []})

@app.route('/api/verse-of-the-day', methods=['GET'])
def verse_of_the_day():
    """Get John 3:16 as verse of the day"""
    return jsonify({
        "reference": "John 3:16",
        "text": "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.",
        "book": "John",
        "chapter": 3,
        "verse": 16
    })

if __name__ == '__main__':
    print("📖 Bible API Server running on http://localhost:8080")
    app.run(debug=True, port=8080)
