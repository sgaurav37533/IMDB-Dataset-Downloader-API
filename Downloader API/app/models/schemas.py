from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime

class DatasetInfo(BaseModel):
    """Information about a dataset"""
    name: str
    url: str
    description: Optional[str] = None

class FileInfo(BaseModel):
    """Information about a downloaded file"""
    name: str
    size_bytes: int
    size_mb: float

class DownloadResponse(BaseModel):
    """Response model for download operations"""
    message: str
    downloaded_files: List[str]
    failed_downloads: List[Dict[str, str]]
    total_files: int
    successful_downloads: int

class ExtractResponse(BaseModel):
    """Response model for extraction operations"""
    message: str
    extracted_files: List[str]
    failed_extractions: List[Dict[str, str]]
    total_files: int
    successful_extractions: int

class FileListResponse(BaseModel):
    """Response model for file listing"""
    files: List[FileInfo]
    total_files: int
    directory: str

class DeleteResponse(BaseModel):
    """Response model for file deletion"""
    message: str
    deleted_files: List[str]
    total_deleted: int

class DatasetListResponse(BaseModel):
    """Response model for dataset listing"""
    datasets: List[str]
    total_count: int

class ErrorResponse(BaseModel):
    """Error response model"""
    detail: str
    error_code: Optional[str] = None
    timestamp: datetime = datetime.now()

class HealthResponse(BaseModel):
    """Health check response model"""
    status: str
    message: str
    version: str
    timestamp: datetime = datetime.now()
