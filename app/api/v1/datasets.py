from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from app.models.schemas import (
    DownloadResponse, ExtractResponse, FileListResponse, 
    DeleteResponse, DatasetListResponse, HealthResponse
)
from app.services.dataset_service import DatasetService
from app.core.config import settings
from app.core.logging import logger


router = APIRouter()

dataset_service = DatasetService()

@router.get("/", response_model=HealthResponse)
async def root():
    """Root endpoint with basic API information"""
    return HealthResponse(
        status="healthy",
        message=f"{settings.app_name} API",
        version=settings.app_version
    )

@router.get("/datasets", response_model=DatasetListResponse)
async def list_datasets():
    """List all available IMDb datasets"""
    return DatasetListResponse(
        datasets=list(settings.imdb_datasets.keys()),
        total_count=len(settings.imdb_datasets)
    )

@router.post("/download", response_model=DownloadResponse)
async def download_all_datasets():
    """Download all IMDb datasets"""
    try:
        result = await dataset_service.download_all_datasets()
        return JSONResponse(status_code=200, content=result.dict())
    except Exception as e:
        logger.error(f"Download endpoint error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/extract", response_model=ExtractResponse)
async def extract_all_datasets():
    """Extract all downloaded .tsv.gz files"""
    try:
        result = await dataset_service.extract_all_datasets()
        return JSONResponse(status_code=200, content=result.dict())
    except Exception as e:
        logger.error(f"Extract endpoint error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/files", response_model=FileListResponse)
async def list_files():
    """List all files in the download directory"""
    try:
        result = await dataset_service.list_files()
        return result
    except Exception as e:
        logger.error(f"List files endpoint error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/files", response_model=DeleteResponse)
async def delete_all_files():
    """Delete all files in the download directory"""
    try:
        result = await dataset_service.delete_all_files()
        return result
    except Exception as e:
        logger.error(f"Delete files endpoint error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/full-process")
async def full_data_process():
    """Complete data processing: download and extract datasets"""
    try:

        download_result = await dataset_service.download_all_datasets()
        if download_result.successful_downloads == 0:
            raise Exception("No files were downloaded successfully")
        
        extract_result = await dataset_service.extract_all_datasets()
        if extract_result.successful_extractions == 0:
            raise Exception("No files were extracted successfully")
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Full data processing completed",
                "download": {
                    "downloaded_files": download_result.downloaded_files,
                    "successful_downloads": download_result.successful_downloads
                },
                "extract": {
                    "extracted_files": extract_result.extracted_files,
                    "successful_extractions": extract_result.successful_extractions
                }
            }
        )
    except Exception as e:
        logger.error(f"Full process endpoint error: {e}")
        raise HTTPException(status_code=500, detail=str(e))