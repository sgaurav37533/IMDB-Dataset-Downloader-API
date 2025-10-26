import os
import shutil
from pathlib import Path
from typing import List, Dict, Any
from app.core.logging import logger

def ensure_directory_exists(directory_path: str) -> Path:
    """Ensure a directory exists, create if it doesn't"""
    path = Path(directory_path)
    path.mkdir(parents=True, exist_ok=True)
    return path

def get_file_size_mb(file_path: Path) -> float:
    """Get file size in MB"""
    try:
        size_bytes = file_path.stat().st_size
        return round(size_bytes / (1024 * 1024), 2)
    except OSError:
        return 0.0

def format_file_size(size_bytes: int) -> str:
    """Format file size in human readable format"""
    if size_bytes == 0:
        return "0 B"
    
    size_names = ["B", "KB", "MB", "GB", "TB"]
    i = 0
    while size_bytes >= 1024 and i < len(size_names) - 1:
        size_bytes /= 1024.0
        i += 1
    
    return f"{size_bytes:.2f} {size_names[i]}"

def clean_filename(filename: str) -> str:
    """Clean filename by removing invalid characters"""
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    return filename

def validate_url(url: str) -> bool:
    """Validate if URL is properly formatted"""
    return url.startswith(('http://', 'https://'))

def get_file_extension(filename: str) -> str:
    """Get file extension from filename"""
    return Path(filename).suffix.lower()

def is_compressed_file(filename: str) -> bool:
    """Check if file is compressed based on extension"""
    compressed_extensions = ['.gz', '.zip', '.rar', '.7z', '.tar']
    return get_file_extension(filename) in compressed_extensions

def safe_delete_file(file_path: Path) -> bool:
    """Safely delete a file"""
    try:
        if file_path.exists() and file_path.is_file():
            file_path.unlink()
            logger.info(f"Successfully deleted file: {file_path.name}")
            return True
        return False
    except Exception as e:
        logger.error(f"Failed to delete file {file_path}: {e}")
        return False

def get_directory_size(directory_path: Path) -> int:
    """Get total size of all files in directory"""
    total_size = 0
    try:
        for file_path in directory_path.rglob('*'):
            if file_path.is_file():
                total_size += file_path.stat().st_size
    except Exception as e:
        logger.error(f"Error calculating directory size: {e}")
    return total_size
