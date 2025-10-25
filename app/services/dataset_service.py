import asyncio
import aiohttp
import aiofiles
import gzip
import shutil
from pathlib import Path
from typing import List, Dict, Tuple
from app.core.config import settings
from app.core.logging import logger
from app.models.schemas import DownloadResponse, ExtractResponse, FileListResponse, DeleteResponse

try:
    from app.services.blob_storage_service import BlobStorageService
    BLOB_STORAGE_AVAILABLE = True
except ImportError:
    BLOB_STORAGE_AVAILABLE = False
    logger.warning("Azure Blob Storage service not available")

class DatasetService:
    """Service for handling IMDb dataset operations"""
    
    def __init__(self):
        self.download_dir = Path(settings.download_dir)
        self.datasets = settings.imdb_datasets
        self.use_blob_storage = settings.use_azure_blob and BLOB_STORAGE_AVAILABLE
        
        if self.use_blob_storage:
            self.blob_service = BlobStorageService()
            logger.info("Using Azure Blob Storage for dataset operations")
        else:
            logger.info("Using local file storage for dataset operations")
    
    async def download_all_datasets(self) -> DownloadResponse:
        """Download all IMDb datasets concurrently"""
        if self.use_blob_storage:
            return await self.blob_service.download_all_datasets()
        else:
            return await self._download_all_datasets_local()
    
    async def extract_all_datasets(self) -> ExtractResponse:
        """Extract all downloaded .tsv.gz files"""
        if self.use_blob_storage:
            return await self.blob_service.extract_all_datasets()
        else:
            return await self._extract_all_datasets_local()
    
    async def list_files(self) -> FileListResponse:
        """List all files in the download directory or blob container"""
        if self.use_blob_storage:
            return await self.blob_service.list_files()
        else:
            return await self._list_files_local()
    
    async def delete_all_files(self) -> DeleteResponse:
        """Delete all files in the download directory or blob container"""
        if self.use_blob_storage:
            return await self.blob_service.delete_all_files()
        else:
            return await self._delete_all_files_local()
    

    async def _download_all_datasets_local(self) -> DownloadResponse:
        """Download all IMDb datasets to local storage"""
        try:
            self.download_dir.mkdir(exist_ok=True)
            
            await self._clear_existing_files()
            
            downloaded_files = []
            failed_downloads = []
            
            async with aiohttp.ClientSession() as session:
                tasks = []
                for filename, url in self.datasets.items():
                    task = self._download_file(session, filename, url)
                    tasks.append(task)
                
                results = await asyncio.gather(*tasks, return_exceptions=True)
                
                for i, result in enumerate(results):
                    filename = list(self.datasets.keys())[i]
                    if isinstance(result, Exception):
                        failed_downloads.append({"filename": filename, "error": str(result)})
                        logger.error(f"Failed to download {filename}: {result}")
                    else:
                        downloaded_files.append(filename)
                        logger.info(f"Successfully downloaded: {filename}")
            
            return DownloadResponse(
                message="Download completed",
                downloaded_files=downloaded_files,
                failed_downloads=failed_downloads,
                total_files=len(self.datasets),
                successful_downloads=len(downloaded_files)
            )
            
        except Exception as e:
            logger.error(f"Error in download_all_datasets: {e}")
            raise Exception(f"Download failed: {str(e)}")
    
    async def _extract_all_datasets_local(self) -> ExtractResponse:
        """Extract all downloaded .tsv.gz files locally"""
        try:
            if not self.download_dir.exists():
                raise Exception("Download directory not found. Please download files first.")
            
            extracted_files = []
            failed_extractions = []
            
            for filename in self.datasets.keys():
                gz_file_path = self.download_dir / filename
                tsv_file_path = self.download_dir / filename.replace('.gz', '')
                
                try:
                    if tsv_file_path.exists():
                        tsv_file_path.unlink()
                        logger.info(f"Deleted existing extracted file: {tsv_file_path.name}")
                    
                    if not gz_file_path.exists():
                        failed_extractions.append({
                            "filename": filename,
                            "error": "Compressed file not found"
                        })
                        continue
                    
                    with gzip.open(gz_file_path, 'rb') as f_in:
                        with open(tsv_file_path, 'wb') as f_out:
                            shutil.copyfileobj(f_in, f_out)
                    
                    extracted_files.append(tsv_file_path.name)
                    logger.info(f"Successfully extracted: {tsv_file_path.name}")
                    
                except Exception as e:
                    failed_extractions.append({
                        "filename": filename,
                        "error": str(e)
                    })
                    logger.error(f"Failed to extract {filename}: {e}")
            
            return ExtractResponse(
                message="Extraction completed",
                extracted_files=extracted_files,
                failed_extractions=failed_extractions,
                total_files=len(self.datasets),
                successful_extractions=len(extracted_files)
            )
            
        except Exception as e:
            logger.error(f"Error in extract_all_datasets: {e}")
            raise Exception(f"Extraction failed: {str(e)}")
    
    async def _list_files_local(self) -> FileListResponse:
        """List all files in the local download directory"""
        try:
            if not self.download_dir.exists():
                return FileListResponse(files=[], total_files=0, directory=str(self.download_dir))
            
            files = []
            for file_path in self.download_dir.iterdir():
                if file_path.is_file():
                    size_bytes = file_path.stat().st_size
                    files.append({
                        "name": file_path.name,
                        "size_bytes": size_bytes,
                        "size_mb": round(size_bytes / (1024 * 1024), 2)
                    })
            
            return FileListResponse(
                files=files,
                total_files=len(files),
                directory=str(self.download_dir)
            )
            
        except Exception as e:
            logger.error(f"Error listing files: {e}")
            raise Exception(f"Failed to list files: {str(e)}")
    
    async def _delete_all_files_local(self) -> DeleteResponse:
        """Delete all files in the local download directory"""
        try:
            if not self.download_dir.exists():
                return DeleteResponse(
                    message="Download directory does not exist",
                    deleted_files=[],
                    total_deleted=0
                )
            
            deleted_files = []
            for file_path in self.download_dir.iterdir():
                if file_path.is_file():
                    file_path.unlink()
                    deleted_files.append(file_path.name)
                    logger.info(f"Deleted file: {file_path.name}")
            
            return DeleteResponse(
                message="All files deleted successfully",
                deleted_files=deleted_files,
                total_deleted=len(deleted_files)
            )
            
        except Exception as e:
            logger.error(f"Error deleting files: {e}")
            raise Exception(f"Failed to delete files: {str(e)}")
    
    async def _download_file(self, session: aiohttp.ClientSession, filename: str, url: str) -> str:
        """Download a single file asynchronously to local storage"""
        try:
            file_path = self.download_dir / filename
            
            async with session.get(url) as response:
                if response.status == 200:
                    async with aiofiles.open(file_path, 'wb') as f:
                        async for chunk in response.content.iter_chunked(8192):
                            await f.write(chunk)
                    return filename
                else:
                    raise Exception(f"HTTP {response.status}: {response.reason}")
                    
        except Exception as e:
            raise Exception(f"Failed to download {filename}: {str(e)}")
    
    async def _clear_existing_files(self):
        """Clear existing files before downloading new ones"""
        for filename in self.datasets.keys():
            file_path = self.download_dir / filename
            if file_path.exists():
                file_path.unlink()
                logger.info(f"Deleted existing file: {filename}")