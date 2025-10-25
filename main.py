"""
IMDb Dataset Downloader API - Entry Point

This is the main entry point for the application.
The actual FastAPI app is now located in app/main.py
"""

from app.main import app

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
