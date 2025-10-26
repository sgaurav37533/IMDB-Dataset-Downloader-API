import asyncio
import aiohttp
import gzip
import io
from pathlib import Path
from typing import List, Dict, Optional
from azure.storage.blob import BlobServiceClient, ContainerClient
from azure.core.exceptions import ResourceNotFoundError, ResourceExistsError
from app.core.config import settings
from app.core.logging import logger
from app.models.schemas import DownloadResponse, ExtractResponse, FileListResponse, DeleteResponse

class BlobStorageService:
    """Service for handling Azure Blob Storage operations"""
    
    def __init__(self):
        self.container_name = settings.azure_container_name
        self.blob_service_client = None
        self.container_client = None
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize Azure Blob Storage client"""
        try:
            if settings.azure_storage_connection_string:
                self.blob_service_client = BlobServiceClient.from_connection_string(
                    settings.azure_storage_connection_string
                )
            elif settings.azure_storage_account_name and settings.azure_storage_account_key:
                account_url = f"https://{settings.azure_storage_account_name}.blob.core.windows.net"
                self.blob_service_client = BlobServiceClient(
                    account_url=account_url,
                    credential=settings.azure_storage_account_key
                )
            else:
                raise ValueError("Azure Storage credentials not provided")
            
            self.container_client = self.blob_service_client.get_container_client(self.container_name)
            logger.info(f"Azure Blob Storage client initialized for container: {self.container_name}")
            
        except Exception as e:
            logger.error(f"Failed to initialize Azure Blob Storage client: {e}")
            raise
    
    async def ensure_container_exists(self):
        """Ensure the blob container exists"""
        try:
            self.container_client.create_container()
            logger.info(f"Created container: {self.container_name}")
        except ResourceExistsError:
            logger.info(f"Container already exists: {self.container_name}")
        except Exception as e:
            logger.error(f"Failed to create container: {e}")
            raise
    
    async def download_all_datasets(self) -> DownloadResponse:
        """Download all IMDb datasets to Azure Blob Storage"""
        try:
            # Ensure container exists
            await self.ensure_container_exists()
            
            # Clear existing files if they exist
            await self._clear_existing_files()
            
            downloaded_files = []
            failed_downloads = []
            
            async with aiohttp.ClientSession() as session:
                tasks = []
                for filename, url in settings.imdb_datasets.items():
                    task = self._download_file_to_blob(session, filename, url)
                    tasks.append(task)
                
                results = await asyncio.gather(*tasks, return_exceptions=True)
                
                for i, result in enumerate(results):
                    filename = list(settings.imdb_datasets.keys())[i]
                    if isinstance(result, Exception):
                        failed_downloads.append({"filename": filename, "error": str(result)})
                        logger.error(f"Failed to download {filename}: {result}")
                    else:
                        downloaded_files.append(filename)
                        logger.info(f"Successfully downloaded: {filename}")
            
            return DownloadResponse(
                message="Download completed to Azure Blob Storage",
                downloaded_files=downloaded_files,
                failed_downloads=failed_downloads,
                total_files=len(settings.imdb_datasets),
                successful_downloads=len(downloaded_files)
            )
            
        except Exception as e:
            logger.error(f"Error in download_all_datasets: {e}")
            raise Exception(f"Download failed: {str(e)}")
    
    async def extract_all_datasets(self) -> ExtractResponse:
        """Extract all downloaded .tsv.gz files in Azure Blob Storage"""
        try:
            extracted_files = []
            failed_extractions = []
            
            for filename in settings.imdb_datasets.keys():
                gz_blob_name = filename
                tsv_blob_name = filename.replace('.gz', '')
                
                try:
                    # Check if compressed file exists
                    if not await self._blob_exists(gz_blob_name):
                        failed_extractions.append({
                            "filename": filename,
                            "error": "Compressed file not found in blob storage"
                        })
                        continue
                    
                    # Download compressed file
                    gz_data = await self._download_blob_to_memory(gz_blob_name)
                    
                    # Extract the gzipped data
                    tsv_data = gzip.decompress(gz_data)
                    
                    # Upload extracted file
                    await self._upload_blob_from_memory(tsv_blob_name, tsv_data)
                    
                    extracted_files.append(tsv_blob_name)
                    logger.info(f"Successfully extracted: {tsv_blob_name}")
                    
                except Exception as e:
                    failed_extractions.append({
                        "filename": filename,
                        "error": str(e)
                    })
                    logger.error(f"Failed to extract {filename}: {e}")
            
            return ExtractResponse(
                message="Extraction completed in Azure Blob Storage",
                extracted_files=extracted_files,
                failed_extractions=failed_extractions,
                total_files=len(settings.imdb_datasets),
                successful_extractions=len(extracted_files)
            )
            
        except Exception as e:
            logger.error(f"Error in extract_all_datasets: {e}")
            raise Exception(f"Extraction failed: {str(e)}")
    
    async def list_files(self) -> FileListResponse:
        """List all files in the Azure Blob Storage container"""
        try:
            files = []
            
            blob_list = self.container_client.list_blobs()
            for blob in blob_list:
                files.append({
                    "name": blob.name,
                    "size_bytes": blob.size,
                    "size_mb": round(blob.size / (1024 * 1024), 2),
                    "last_modified": blob.last_modified.isoformat() if blob.last_modified else None,
                    "content_type": blob.content_settings.content_type if blob.content_settings else None
                })
            
            return FileListResponse(
                files=files,
                total_files=len(files),
                directory=f"Azure Blob Container: {self.container_name}"
            )
            
        except Exception as e:
            logger.error(f"Error listing files: {e}")
            raise Exception(f"Failed to list files: {str(e)}")
    
    async def delete_all_files(self) -> DeleteResponse:
        """Delete all files in the Azure Blob Storage container"""
        try:
            deleted_files = []
            
            blob_list = self.container_client.list_blobs()
            for blob in blob_list:
                try:
                    self.container_client.delete_blob(blob.name)
                    deleted_files.append(blob.name)
                    logger.info(f"Deleted blob: {blob.name}")
                except Exception as e:
                    logger.error(f"Failed to delete blob {blob.name}: {e}")
            
            return DeleteResponse(
                message="All files deleted successfully from Azure Blob Storage",
                deleted_files=deleted_files,
                total_deleted=len(deleted_files)
            )
            
        except Exception as e:
            logger.error(f"Error deleting files: {e}")
            raise Exception(f"Failed to delete files: {str(e)}")
    
    async def _download_file_to_blob(self, session: aiohttp.ClientSession, filename: str, url: str) -> str:
        """Download a single file and upload it to Azure Blob Storage"""
        try:
            async with session.get(url) as response:
                if response.status == 200:
                    # Read the content
                    content = await response.read()
                    
                    # Upload to blob storage
                    await self._upload_blob_from_memory(filename, content)
                    
                    return filename
                else:
                    raise Exception(f"HTTP {response.status}: {response.reason}")
                    
        except Exception as e:
            raise Exception(f"Failed to download {filename}: {str(e)}")
    
    async def _upload_blob_from_memory(self, blob_name: str, data: bytes):
        """Upload data from memory to blob storage"""
        try:
            blob_client = self.container_client.get_blob_client(blob_name)
            blob_client.upload_blob(data, overwrite=True)
            logger.debug(f"Uploaded blob: {blob_name}")
        except Exception as e:
            logger.error(f"Failed to upload blob {blob_name}: {e}")
            raise
    
    async def _download_blob_to_memory(self, blob_name: str) -> bytes:
        """Download blob content to memory"""
        try:
            blob_client = self.container_client.get_blob_client(blob_name)
            download_stream = blob_client.download_blob()
            return download_stream.readall()
        except Exception as e:
            logger.error(f"Failed to download blob {blob_name}: {e}")
            raise
    
    async def _blob_exists(self, blob_name: str) -> bool:
        """Check if a blob exists"""
        try:
            blob_client = self.container_client.get_blob_client(blob_name)
            blob_client.get_blob_properties()
            return True
        except ResourceNotFoundError:
            return False
        except Exception as e:
            logger.error(f"Error checking if blob {blob_name} exists: {e}")
            return False
    
    async def _clear_existing_files(self):
        """Clear existing files before downloading new ones"""
        try:
            blob_list = self.container_client.list_blobs()
            for blob in blob_list:
                try:
                    self.container_client.delete_blob(blob.name)
                    logger.info(f"Deleted existing blob: {blob.name}")
                except Exception as e:
                    logger.error(f"Failed to delete existing blob {blob.name}: {e}")
        except Exception as e:
            logger.error(f"Error clearing existing files: {e}")
            raise
